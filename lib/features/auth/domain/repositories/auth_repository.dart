// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/auth/domain/entities/auth_response_entity.dart';
import 'package:flutter_application/features/auth/domain/entities/verify_user_result.dart';
import 'package:flutter_application/features/auth/domain/schemas/dto/request/ChangePasswordRequest.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponseEntity>> login(
    String usernameOrEmail,
    String password,
  );
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, AuthResponseEntity>> checkAuthStatus();
  Future<Either<Failure, AuthResponseEntity>> refreshToken(String refreshToken);

  /// Verifies whether a user with the given identifier exists in the remote system.
  /// Used to guard token-cached sessions against deleted/deactivated accounts.
  Future<Either<Failure, VerifyUserResult>> verifyUser(String usernameOrEmail);

  Future<Either<Failure, void>> changePassword(
    String userId,
    ChangePasswordRequest request,
  );
}
