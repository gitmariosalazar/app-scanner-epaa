// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, void>> logout();
}
