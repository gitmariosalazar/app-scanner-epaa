import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/core/usecases/usecase.dart';
import 'package:flutter_application/features/auth/domain/entities/auth_response_entity.dart';
import 'package:flutter_application/features/auth/domain/repositories/auth_repository.dart';

class RefreshTokenUseCase
    implements UseCase<AuthResponseEntity, RefreshTokenParams> {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResponseEntity>> call(
    RefreshTokenParams params,
  ) async {
    return await repository.refreshToken(params.refreshToken);
  }
}

class RefreshTokenParams {
  final String refreshToken;

  RefreshTokenParams({required this.refreshToken});
}
