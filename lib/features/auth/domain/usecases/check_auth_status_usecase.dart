import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/core/usecases/usecase.dart';
import 'package:flutter_application/features/auth/data/models/auth_response_model.dart';
import 'package:flutter_application/features/auth/domain/repositories/auth_repository.dart';

class CheckAuthStatusUseCase implements UseCase<AuthResponseModel, NoParams> {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResponseModel>> call(NoParams params) {
    return repository.checkAuthStatus();
  }
}
