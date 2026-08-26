import 'package:flutter_application/features/auth/domain/entities/auth_response_entity.dart';
import 'package:flutter_application/features/auth/data/models/user_model.dart';

class AuthResponseModel extends AuthResponseEntity {
  const AuthResponseModel({
    required String accessToken,
    required String refreshToken,
    required UserModel user,
  }) : super(accessToken: accessToken, refreshToken: refreshToken, user: user);

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String? ?? '',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': (user as UserModel).toJson(),
    };
  }
}

/*
export interface ChangePasswordRequest {
  oldPassword: string;
  newPassword: string;
  confirmNewPassword: string;
}
*/
