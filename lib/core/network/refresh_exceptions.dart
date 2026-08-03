/// Thrown when a refresh attempt fails because the session is genuinely
/// invalid (missing, expired, or revoked refresh token). The user must log
/// in again — there is nothing to retry.
class AuthSessionExpiredException implements Exception {
  final String message;
  AuthSessionExpiredException([this.message = 'La sesión ha expirado']);

  @override
  String toString() => 'AuthSessionExpiredException: $message';
}

/// Thrown when a refresh attempt fails purely due to connectivity issues.
/// The session itself may still be valid — callers should NOT force logout,
/// only retry later (e.g. on the next app resume or user action).
class NetworkRefreshException implements Exception {
  final String message;
  NetworkRefreshException([this.message = 'Sin conexión a Internet']);

  @override
  String toString() => 'NetworkRefreshException: $message';
}
