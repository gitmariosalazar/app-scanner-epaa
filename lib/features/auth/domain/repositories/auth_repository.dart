// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/auth/data/models/auth_response_model.dart';
import 'package:flutter_application/features/auth/domain/entities/verify_user_result.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponseModel>> login(
    String usernameOrEmail,
    String password,
  );
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, AuthResponseModel>> checkAuthStatus();
  Future<Either<Failure, AuthResponseModel>> refreshToken(String refreshToken);

  /// Verifies whether a user with the given identifier exists in the remote system.
  /// Used to guard token-cached sessions against deleted/deactivated accounts.
  Future<Either<Failure, VerifyUserResult>> verifyUser(String usernameOrEmail);
}
