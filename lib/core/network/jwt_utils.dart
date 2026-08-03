import 'dart:convert';

/// Pure utility to read the `exp` claim out of a JWT without verifying its
/// signature — signature verification is the backend's responsibility, this
/// is only used client-side to decide when to proactively refresh.
class JwtUtils {
  const JwtUtils._();

  /// Returns the `exp` claim in milliseconds since epoch, or null if the
  /// token is malformed or has no `exp` claim.
  static int? getExpirationMs(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }

      final payloadMap = json.decode(utf8.decode(base64Url.decode(payload)));
      if (payloadMap is! Map<String, dynamic> ||
          !payloadMap.containsKey('exp')) {
        return null;
      }
      return (payloadMap['exp'] as int) * 1000;
    } catch (_) {
      return null;
    }
  }

  /// True if the token is expired, or will expire within [bufferMs].
  /// A token with no readable `exp` claim is treated as expired (fail-safe).
  static bool isExpired(String token, {int bufferMs = 0}) {
    final expMs = getExpirationMs(token);
    if (expMs == null) return true;
    return DateTime.now().millisecondsSinceEpoch >= (expMs - bufferMs);
  }
}
