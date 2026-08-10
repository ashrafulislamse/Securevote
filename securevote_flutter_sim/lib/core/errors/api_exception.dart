/// A user-friendly wrapper around networking failures.
///
/// Carries a stable [code] (for programmatic handling) and a pre-translated
/// [message] that is safe to show directly to end users.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
  });

  /// Human-readable message suitable for display to the user.
  final String message;

  /// HTTP status code when the failure came from a server response.
  final int? statusCode;

  /// Optional stable error code (e.g. `unauthorized`, `server_error`).
  final String? code;

  bool get isUnauthorized => statusCode == 401 || code == 'unauthorized';

  @override
  String toString() => 'ApiException($statusCode): $message';
}