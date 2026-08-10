import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure, encrypted storage for auth credentials (access/refresh tokens).
///
/// Intentionally separate from [StorageService] (SharedPreferences) so that
/// sensitive credentials are never persisted in plain text. The caller is
/// responsible for keeping the refresher token in sync with the API.
class SecureTokenStorage {
  SecureTokenStorage._();

  static final SecureTokenStorage instance = SecureTokenStorage._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _keyAccessToken = 'auth_access_token';
  static const String _keyRefreshToken = 'auth_refresh_token';
  static const String _keyExpiresAt = 'auth_expires_at';

  /// Persists the full token set returned after login/registration/refresh.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
    await _storage.write(
      key: _keyExpiresAt,
      value: expiresAt.toIso8601String(),
    );
  }

  /// Reads the current access token, or null if none is stored.
  Future<String?> readAccessToken() async {
    return _storage.read(key: _keyAccessToken);
  }

  /// Reads the current refresh token, or null if none is stored.
  Future<String?> readRefreshToken() async {
    return _storage.read(key: _keyRefreshToken);
  }

  /// Reads the stored access-token expiry, or null if none is stored.
  Future<DateTime?> readExpiresAt() async {
    final raw = await _storage.read(key: _keyExpiresAt);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// Wipes all stored credentials.
  Future<void> clear() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyExpiresAt);
  }
}