import 'package:flutter_application/features/auth/domain/entities/user.dart';

class AuthResponseEntity {
  final String accessToken;
  final String refreshToken;
  final User user;

  const AuthResponseEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
}
