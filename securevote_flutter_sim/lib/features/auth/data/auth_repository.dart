import 'dart:async';

import '../../../core/errors/api_exception.dart';
import '../../../core/models/auth_session.dart';
import '../../../core/models/user.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/secure_token_storage.dart';

/// Result of a register/verify-otp call before a session is established.
class RegisterResult {
  const RegisterResult({
    required this.ok,
    required this.message,
    this.devOtp,
    this.expiresInSeconds,
  });

  final bool ok;
  final String message;
  final String? devOtp;
  final int? expiresInSeconds;

  factory RegisterResult.fromJson(Map<String, dynamic> json) => RegisterResult(
        ok: json['ok'] as bool? ?? false,
        message: json['message'] as String? ?? '',
        devOtp: json['devOtp'] as String?,
        expiresInSeconds: json['expiresInSeconds'] as int?,
      );
}

/// Data access for all authentication endpoints.
///
/// Owns token persistence (via [SecureTokenStorage]) and the currently
/// authenticated [User]. The `onUserChanged` callback lets the UI layer
/// (e.g. `AuthProvider`) stay in sync whenever the user is set or cleared.
class AuthRepository {
  AuthRepository({ApiClient? api, SecureTokenStorage? tokenStorage})
      : _api = api ?? ApiClient.instance,
        _tokenStorage = tokenStorage ?? SecureTokenStorage.instance {
    _api.onUserRefreshed = _applyRefreshedUser;
  }

  final ApiClient _api;
  final SecureTokenStorage _tokenStorage;

  /// The currently authenticated user, or null when signed out.
  User? currentUser;

  /// Fired whenever [currentUser] changes (set or cleared).
  void Function(User? user)? onUserChanged;

  /// Whether a session is currently active.
  bool get isAuthenticated => currentUser != null;

  void _setUser(User? user) {
    currentUser = user;
    onUserChanged?.call(user);
  }

  /// Keeps the in-memory user in sync after a background token refresh.
  void _applyRefreshedUser(Map<String, dynamic> userJson) {
    _setUser(User.fromJson(userJson));
  }

  /// Registers a new account. Does NOT establish a session.
  Future<RegisterResult> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    final data = await _api.postApi(
      '/api/auth/register',
      data: {
        'email': email,
        'password': password,
        'fullName': fullName,
        if (phone != null) 'phone': phone,
      },
    );
    return RegisterResult.fromJson(data as Map<String, dynamic>);
  }

  /// Verifies the OTP and establishes a session.
  Future<AuthSession> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final data = await _api.postApi(
      '/api/auth/verify-otp',
      data: {'email': email, 'otp': otp},
    );
    return _establishSession(data as Map<String, dynamic>);
  }

  /// Signs in an existing user and establishes a session.
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.postApi(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );
    return _establishSession(data as Map<String, dynamic>);
  }

  /// Explicitly refreshes the access token using the stored refresh token.
  ///
  /// Updates the persisted tokens and keeps [currentUser] unchanged. Returns
  /// the new access token, or throws [ApiException] when no refresh token is
  /// available or the refresh fails.
  Future<String> refresh() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw const ApiException(message: 'No refresh token available.');
    }
    final data = await _api.postApi(
      '/api/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    final json = data as Map<String, dynamic>;
    final accessToken = json['accessToken'] as String;
    final expiresAt = _parseExpiresAt(json['expiresAt']);

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
    return accessToken;
  }

  /// Signs the user out, invalidating the refresh token on the server.
  Future<void> logout() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    try {
      await _api.postApi(
        '/api/auth/logout',
        data: {if (refreshToken != null) 'refreshToken': refreshToken},
      );
    } on ApiException {
      // Best-effort: always clear local state even if the server call fails.
    }
    await _tokenStorage.clear();
    _setUser(null);
  }

  /// Fetches the current user profile from the server.
  Future<User> me() async {
    final data = await _api.getApi('/api/auth/me');
    final user = User.fromJson((data as Map<String, dynamic>)['user']!);
    _setUser(user);
    return user;
  }

  /// Updates profile fields (fullName / phone) for the current user.
  Future<User> updateProfile({String? fullName, String? phone}) async {
    final data = await _api.patchApi(
      '/api/auth/profile',
      data: {
        if (fullName != null) 'fullName': fullName,
        if (phone != null) 'phone': phone,
      },
    );
    final user = User.fromJson((data as Map<String, dynamic>)['user']!);
    _setUser(user);
    return user;
  }

  /// Changes the current user's password.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _api.postApi(
      '/api/auth/change-password',
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }

  /// Establishes a session from an auth response body (login / verify-otp).
  AuthSession _establishSession(Map<String, dynamic> json) {
    final session = AuthSession(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: _parseExpiresAt(json['expiresAt']),
    );

    // Persist tokens so the interceptor can attach them on later requests.
    _tokenStorage.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      expiresAt: session.expiresAt,
    );

    _setUser(session.user);
    return session;
  }

  static DateTime _parseExpiresAt(Object? raw) {
    if (raw is String) {
      return DateTime.tryParse(raw) ??
          DateTime.now().add(const Duration(hours: 12));
    }
    if (raw is num) {
      return DateTime.now().add(Duration(seconds: raw.toInt()));
    }
    return DateTime.now().add(const Duration(hours: 12));
  }
}