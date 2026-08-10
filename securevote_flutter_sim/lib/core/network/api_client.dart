import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../errors/api_exception.dart';
import 'secure_token_storage.dart';

/// Central HTTP client for the SecureVote backend API.
///
/// Responsibilities:
///  - Hold the base URL (from the `API_BASE_URL` Dart define).
///  - Attach the current access token on every request.
///  - On a 401, transparently refresh the token once and retry the request.
///  - Translate [DioException] into a user-friendly [ApiException].
class ApiClient {
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: const {'Accept': 'application/json'},
      ),
    );
    _dio.interceptors
      ..add(_authInterceptor)
      ..add(_errorInterceptor);
  }

  static final ApiClient instance = ApiClient._();

  /// Base URL injected at build time via `--dart-define=API_BASE_URL=...`.
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8787',
  );

  late final Dio _dio;

  /// Whether a token refresh is currently in flight, to avoid fan-out.
  bool _refreshing = false;

  /// Queue of requests waiting for a refresh to complete.
  final List<Completer<void>> _pendingRefresh = [];

  /// The raw [Dio] instance for direct/custom calls when needed.
  Dio get dio => _dio;

  /// Public accessor for the configured base URL.
  static String get baseUrl => _baseUrl;

  /// Shortcut for calling out to the API and decoding a JSON body.
  Future<dynamic> getApi(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final Response<dynamic> res = await _dio.get<dynamic>(
      path,
      queryParameters: query,
    );
    return res.data;
  }

  Future<dynamic> postApi(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) async {
    final Response<dynamic> res = await _dio.post<dynamic>(
      path,
      data: data,
      queryParameters: query,
    );
    return res.data;
  }

  Future<dynamic> patchApi(
    String path, {
    Object? data,
  }) async {
    final Response<dynamic> res = await _dio.patch<dynamic>(path, data: data);
    return res.data;
  }

  /// Adds the `Authorization: Bearer <token>` header when a token is present.
  final InterceptorsWrapper _authInterceptor = InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await SecureTokenStorage.instance.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
  );

  /// Handles 401 responses by attempting a single token refresh + retry.
  late final InterceptorsWrapper _errorInterceptor = InterceptorsWrapper(
    onError: (error, handler) async {
      final requestOptions = error.requestOptions;

      // Only attempt refresh for real 401s on authenticated requests.
      final isAuthError = error.response?.statusCode == 401;
      final hadAuthHeader = requestOptions.headers['Authorization'] != null;

      if (!isAuthError ||
          !hadAuthHeader ||
          requestOptions.path == '/api/auth/refresh' ||
          requestOptions.path == '/api/auth/login' ||
          requestOptions.path == '/api/auth/register' ||
          requestOptions.path == '/api/auth/verify-otp') {
        handler.next(error);
        return;
      }

      try {
        if (!await _tryRefresh()) {
          // Refresh failed — session is dead. Bail with the original error.
          handler.next(error);
          return;
        }
      } on ApiException {
        // Token clearing already handled inside refresh; surface original err.
        handler.next(error);
        return;
      }

      // Retry the original request once with the fresh token.
      try {
        final newToken =
            await SecureTokenStorage.instance.readAccessToken();
        requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final retryResponse = await _dio.fetch<dynamic>(requestOptions);
        handler.resolve(retryResponse);
      } on DioException {
        handler.next(error);
      }
    },
  );

  /// Refreshes the access token using the stored refresh token.
  ///
  /// Returns `true` when a new access token was stored, `false` when there is
  /// no refresh token to use. Throws [ApiException] when the refresh itself
  /// fails (and clears the stored credentials).
  Future<bool> _tryRefresh() async {
    final refreshToken = await SecureTokenStorage.instance.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    // Single-flight: if a refresh is already running, wait for it.
    if (_refreshing) {
      final completer = Completer<void>();
      _pendingRefresh.add(completer);
      await completer.future;
      return true;
    }

    _refreshing = true;
    try {
      final response = await _dio.post<dynamic>(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final body = response.data as Map<String, dynamic>;
      final Map<String, dynamic>? userJson = body['user'];
      final String accessToken = body['accessToken'] as String;
      final String? newRefreshToken =
          (body['refreshToken'] as String?) ?? refreshToken;
      final DateTime expiresAt = _parseExpiresAt(body);

      await SecureTokenStorage.instance.saveTokens(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
        expiresAt: expiresAt,
      );

      // Keep any cached user in sync if the refresh rotates it.
      if (userJson != null) {
        _notifyUserUpdated(userJson);
      }

      return true;
    } on DioException catch (e) {
      await SecureTokenStorage.instance.clear();
      throw _mapError(e);
    } finally {
      _refreshing = false;
      for (final completer in _pendingRefresh) {
        completer.complete();
      }
      _pendingRefresh.clear();
    }
  }

  /// Callback (set by the auth layer) to push fresh user data post-refresh.
  @visibleForTesting
  void Function(Map<String, dynamic> user)? onUserRefreshed;

  void _notifyUserUpdated(Map<String, dynamic> userJson) {
    onUserRefreshed?.call(userJson);
  }

  static DateTime _parseExpiresAt(Map<String, dynamic> body) {
    final raw = body['expiresAt'];
    if (raw is String) {
      return DateTime.tryParse(raw) ??
          DateTime.now().add(const Duration(hours: 12));
    }
    if (raw is num) {
      return DateTime.now().add(Duration(seconds: raw.toInt()));
    }
    return DateTime.now().add(const Duration(hours: 12));
  }

  /// Converts a [DioException] into a user-friendly [ApiException].
  ApiException _mapError(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode;

    // Try to surface a backend-provided message if present.
    final data = response?.data;
    String? serverMessage;
    if (data is Map<String, dynamic>) {
      final msg = data['message'];
      if (msg is String && msg.isNotEmpty) {
        serverMessage = msg;
      }
    } else if (data is String && data.isNotEmpty) {
      serverMessage = data;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'The request timed out. Please check your connection and '
              'try again.',
          statusCode: statusCode,
          code: 'timeout',
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Could not reach the server. Please check your internet '
              'connection.',
          statusCode: statusCode,
          code: 'network',
        );
      case DioExceptionType.badResponse:
        final message = serverMessage ??
            _messageForStatus(statusCode) ??
            'Something went wrong. Please try again.';
        return ApiException(
          message: message,
          statusCode: statusCode,
          code: _codeForStatus(statusCode),
        );
      case DioExceptionType.cancel:
        return ApiException(
          message: 'The request was cancelled.',
          statusCode: statusCode,
          code: 'cancelled',
        );
      case DioExceptionType.badCertificate:
        return ApiException(
          message: 'Secure connection could not be established.',
          statusCode: statusCode,
          code: 'bad_certificate',
        );
      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: serverMessage ??
              'Something unexpected went wrong. Please try again.',
          statusCode: statusCode,
          code: 'unknown',
        );
    }
  }

  String? _messageForStatus(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'The request was invalid. Please review your details.';
      case 401:
        return 'Your session has expired. Please sign in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource could not be found.';
      case 409:
        return 'This conflicts with an existing record.';
      case 429:
        return 'Too many attempts. Please slow down and try again.';
      case 500:
      case 502:
      case 503:
      case 504:
        return 'The server is having trouble. Please try again shortly.';
      default:
        return null;
    }
  }

  String? _codeForStatus(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'bad_request';
      case 401:
        return 'unauthorized';
      case 403:
        return 'forbidden';
      case 404:
        return 'not_found';
      case 409:
        return 'conflict';
      case 429:
        return 'rate_limited';
      case 500:
        return 'server_error';
      default:
        return null;
    }
  }

  /// Re-exports the error mapping so callers can map stray DioExceptions.
  static ApiException mapError(DioException error) => ApiClient.instance
      ._mapError(error);

  /// Convenience for parsing JSON bodies that are raw strings.
  static Map<String, dynamic> decodeMap(String source) =>
      jsonDecode(source) as Map<String, dynamic>;
}