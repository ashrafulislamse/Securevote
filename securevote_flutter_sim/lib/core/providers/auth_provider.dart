import 'package:flutter/foundation.dart';

import '../../features/auth/data/auth_repository.dart';
import '../errors/api_exception.dart';
import '../models/auth_session.dart';
import '../models/user.dart';
import '../network/secure_token_storage.dart';

/// Manages authentication state for the application.
///
/// Exposes the current [User], loading/error state, and the auth actions. It
/// delegates the actual work to [AuthRepository] and keeps its own state in
/// sync via the repository's `onUserChanged` callback.
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
    : _repository = repository ?? AuthRepository() {
    _repository.onUserChanged = _onUserChanged;
  }

  final AuthRepository _repository;

  User? _user;
  bool _isLoading = false;
  String? _error;
  RegisterResult? _lastRegister;

  /// The currently authenticated user, or null when signed out.
  User? get user => _user;

  /// Whether an auth operation is in flight.
  bool get isLoading => _isLoading;

  /// The last error message, or null when there is none.
  String? get error => _error;

  /// The result of the most recent registration attempt (e.g. dev OTP).
  RegisterResult? get lastRegister => _lastRegister;

  /// Whether a user is currently authenticated.
  bool get isAuthenticated => _user != null;

  void _onUserChanged(User? user) {
    _user = user;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  /// Restores the session on app start.
  ///
  /// If an access token is present, fetches the current user via `/auth/me`.
  /// Otherwise the provider stays signed out.
  Future<void> init() async {
    final token = await SecureTokenStorage.instance.readAccessToken();
    if (token == null || token.isEmpty) {
      return;
    }
    _setLoading(true);
    try {
      await _repository.me();
    } on ApiException catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('Could not restore your session.');
    } finally {
      _setLoading(false);
    }
  }

  /// Signs the user in with email + password.
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final session = await _repository.login(email: email, password: password);
      return session;
    } on ApiException catch (e) {
      _setError(e.message);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Creates a new account. Does not establish a session.
  Future<RegisterResult> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final result = await _repository.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      _lastRegister = result;
      return result;
    } on ApiException catch (e) {
      _setError(e.message);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Verifies the OTP and completes the session.
  Future<AuthSession> verifyOtp({
    required String email,
    required String otp,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final session = await _repository.verifyOtp(email: email, otp: otp);
      return session;
    } on ApiException catch (e) {
      _setError(e.message);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Signs the user out and clears the session.
  Future<void> logout() async {
    _setLoading(true);
    _setError(null);
    try {
      await _repository.logout();
    } on ApiException catch (e) {
      _setError(e.message);
    } finally {
      _setLoading(false);
    }
  }

  /// Refreshes the current profile from the server.
  Future<User> refreshProfile() async {
    try {
      return await _repository.me();
    } on ApiException catch (e) {
      _setError(e.message);
      rethrow;
    }
  }

  /// Updates profile fields (fullName / phone).
  Future<User> updateProfile({String? fullName, String? phone}) async {
    try {
      return await _repository.updateProfile(fullName: fullName, phone: phone);
    } on ApiException catch (e) {
      _setError(e.message);
      rethrow;
    }
  }

  /// Requests a password reset link for the given email.
  ///
  /// Returns the [ForgotPasswordResult] on success, or null when the request
  /// fails (the error is captured in [error]).
  Future<ForgotPasswordResult?> forgotPassword(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      final result = await _repository.forgotPassword(email);
      return result;
    } on ApiException catch (e) {
      _setError(e.message);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Resets the password using a reset token.
  ///
  /// Returns true on success, false on failure (error captured in [error]).
  Future<bool> resetPassword(String token, String newPassword) async {
    _setLoading(true);
    _setError(null);
    try {
      final ok = await _repository.resetPassword(token, newPassword);
      return ok;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Resends the OTP to the given email.
  ///
  /// Returns a record with `ok` and the optional dev OTP; on failure `ok` is
  /// false (the error is captured in [error]).
  Future<({bool ok, String? devOtp})> resendOtp(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      final result = await _repository.resendOtp(email);
      return (ok: result.ok, devOtp: result.devOtp);
    } on ApiException catch (e) {
      _setError(e.message);
      return (ok: false, devOtp: null);
    } finally {
      _setLoading(false);
    }
  }
}
