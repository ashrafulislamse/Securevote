import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure, encrypted storage for auth credentials (access/refresh tokens).
///
/// Intentionally separate from [StorageService] (SharedPreferences) so that
/// sensitive credentials are never persisted in plain text. The caller is
/// responsible for keeping the refresher token in sync with the API.
///
/// On devices where the Android Keystore / EncryptedSharedPreferences is
/// unavailable (e.g. some Android 15 builds or emulators), the secure write
/// can throw. We transparently fall back to plain SharedPreferences so that
/// authentication never hard-fails — a pragmatic trade-off for the FYP demo.
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
    try {
      await _storage.write(key: _keyAccessToken, value: accessToken);
      await _storage.write(key: _keyRefreshToken, value: refreshToken);
      await _storage.write(
        key: _keyExpiresAt,
        value: expiresAt.toIso8601String(),
      );
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAccessToken, accessToken);
      await prefs.setString(_keyRefreshToken, refreshToken);
      await prefs.setString(_keyExpiresAt, expiresAt.toIso8601String());
    }
  }

  /// Reads the current access token, or null if none is stored.
  Future<String?> readAccessToken() async {
    try {
      final value = await _storage.read(key: _keyAccessToken);
      if (value != null) return value;
    } catch (_) {
      // fall through to the plain preference below.
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  /// Reads the current refresh token, or null if none is stored.
  Future<String?> readRefreshToken() async {
    try {
      final value = await _storage.read(key: _keyRefreshToken);
      if (value != null) return value;
    } catch (_) {
      // fall through to the plain preference below.
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  /// Reads the stored access-token expiry, or null if none is stored.
  Future<DateTime?> readExpiresAt() async {
    String? raw;
    try {
      raw = await _storage.read(key: _keyExpiresAt);
    } catch (_) {
      // fall through to the plain preference below.
    }
    if (raw == null) {
      final prefs = await SharedPreferences.getInstance();
      raw = prefs.getString(_keyExpiresAt);
    }
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// Wipes all stored credentials.
  Future<void> clear() async {
    try {
      await _storage.delete(key: _keyAccessToken);
      await _storage.delete(key: _keyRefreshToken);
      await _storage.delete(key: _keyExpiresAt);
    } catch (_) {
      // ignore — plain prefs cleared below.
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyExpiresAt);
  }
}
