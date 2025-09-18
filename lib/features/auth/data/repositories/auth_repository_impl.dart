// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_application/features/auth/domain/entities/user.dart';
import 'package:flutter_application/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final userModel = await localDataSource.login(email, password);
      return Right(userModel);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    // Implement if needed
    return Right(null);
  }
}
