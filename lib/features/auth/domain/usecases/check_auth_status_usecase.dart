import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/core/usecases/usecase.dart';
import 'package:flutter_application/features/auth/domain/entities/auth_response_entity.dart';
import 'package:flutter_application/features/auth/domain/repositories/auth_repository.dart';

class CheckAuthStatusUseCase implements UseCase<AuthResponseEntity, NoParams> {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResponseEntity>> call(NoParams params) {
    return repository.checkAuthStatus();
  }
}
