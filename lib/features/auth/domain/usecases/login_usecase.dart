// lib/features/auth/domain/usecases/login_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/core/usecases/usecase.dart';
import 'package:flutter_application/features/auth/data/models/auth_response_model.dart';
import 'package:flutter_application/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase implements UseCase<AuthResponseModel, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, AuthResponseModel>> call(LoginParams params) {
    return repository.login(params.usernameOrEmail, params.password);
  }
}

class LoginParams {
  final String usernameOrEmail;
  final String password;

  LoginParams({required this.usernameOrEmail, required this.password});
}
