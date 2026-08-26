import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_application/features/auth/domain/schemas/dto/request/ChangePasswordRequest.dart';

class ChangePasswordUsecase {
  final AuthRepository repository;

  ChangePasswordUsecase({required this.repository});

  Future<Either<Failure, void>> call(
    String userId,
    ChangePasswordRequest request,
  ) async {
    return await repository.changePassword(userId, request);
  }
}
