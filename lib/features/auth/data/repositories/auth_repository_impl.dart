import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application/core/error/exception.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_application/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_application/features/auth/domain/entities/user.dart';
import 'package:flutter_application/features/auth/domain/entities/verify_user_result.dart';
import 'package:flutter_application/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_application/core/services/websocket_service.dart';
import 'package:flutter_application/config/environments/environment.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final WebSocketService webSocketService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.webSocketService,
  });

  @override
  Future<Either<Failure, User>> login(
    String username_or_email,
    String password,
  ) async {
    try {
      final authResponse = await remoteDataSource.login(
        username_or_email,
        password,
      );
      debugPrint('AuthResponse: $authResponse');
      await localDataSource.cacheToken(authResponse.accessToken);
      await localDataSource.cacheUser(authResponse.user);

      // ── Reconectar WebSocket con el token del usuario autenticado ──────────────
      // disconnect() limpia el socket anterior (sin token o con token viejo)
      // y connect() crea uno nuevo autenticado.
      webSocketService.disconnect();
      webSocketService.connect(Environment.apiUrl, token: authResponse.accessToken);

      return Right(authResponse.user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    // ── Desconectar WebSocket limpiamente ANTES de limpiar la sesión ─────────
    // disconnect() detiene la reconexion automática de socket.io.
    // Sin esto, el socket se reconectaría sin token mostrando
    // "Client connected without authentication" en el backend.
    webSocketService.disconnect();

    try {
      await remoteDataSource.logout();
    } catch (e) {
      // Ignore remote logout failure, ensure local cleanup
    }
    try {
      await localDataSource.clearToken();
      await localDataSource.clearUser();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Could not safe logout'));
    }
  }

  @override
  Future<Either<Failure, User>> checkAuthStatus() async {
    try {
      final token = await localDataSource.getToken();
      final user = await localDataSource.getUser();
      if (token != null && token.isNotEmpty && user != null) {
        return Right(user);
      }
      return Left(CacheFailure(message: 'No active session'));
    } catch (e) {
      return Left(CacheFailure(message: 'Error checking session'));
    }
  }

  @override
  Future<Either<Failure, VerifyUserResult>> verifyUser(
    String usernameOrEmail,
  ) async {
    try {
      final result = await remoteDataSource.verifyUser(usernameOrEmail);
      // Treat inactive accounts as non-existent for security
      if (!result.exists || result.isActive == false) {
        return Right(
          VerifyUserResult(
            exists: false,
            userId: result.userId,
            username: result.username,
            email: result.email,
            isActive: result.isActive,
          ),
        );
      }
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

