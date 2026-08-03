import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application/core/error/exception.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_application/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_application/features/auth/data/models/auth_response_model.dart';
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
  Future<Either<Failure, AuthResponseModel>> login(
    String username_or_email,
    String password,
  ) async {
    try {
      final authResponse = await remoteDataSource.login(
        username_or_email,
        password,
      );
      debugPrint('AuthResponse: $authResponse');

      // Validar si el usuario tiene el rol permitido para usar esta aplicación móvil.
      // Permitimos acceso a 'LECTURISTA CAMPO' y opcionalmente a 'SUPER ADMINISTRADOR'.
      final hasAccess = authResponse.user.roles.any((role) {
        final upperRole = role.toUpperCase();
        return upperRole == 'LECTURISTA CAMPO' ||
            upperRole == 'SUPER ADMINISTRADOR';
      });

      if (!hasAccess) {
        // No almacenamos el token ni sesión si no tiene el rol necesario.
        return Left(
          ServerFailure(
            message:
                'Acceso denegado. Esta aplicación es exclusiva para el personal de toma de lecturas.',
          ),
        );
      }

      await localDataSource.cacheToken(authResponse.accessToken);
      await localDataSource.cacheRefreshToken(authResponse.refreshToken);
      await localDataSource.cacheUser(authResponse.user);

      webSocketService.disconnect();
      webSocketService.connect(
        Environment.apiUrl,
        token: authResponse.accessToken,
      );
      print('✅✅✅✅✅✅ Token Repository Impl: ${authResponse.accessToken}');
      print('✅✅✅✅✅✅ URL Repository Impl: ${Environment.apiUrl}');

      return Right(authResponse);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponseModel>> refreshToken(
    String refreshToken,
  ) async {
    try {
      final authResponse = await remoteDataSource.refreshToken(refreshToken);
      debugPrint('RefreshTokenResponse: $authResponse');

      await localDataSource.cacheToken(authResponse.accessToken);
      // Backend rotates refresh tokens (single-use) — persist the new one.
      await localDataSource.cacheRefreshToken(authResponse.refreshToken);
      await localDataSource.cacheUser(authResponse.user);

      // Update WebSocket with new token
      webSocketService.disconnect();
      webSocketService.connect(
        Environment.apiUrl,
        token: authResponse.accessToken,
      );

      return Right(authResponse);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    webSocketService.disconnect();

    try {
      await remoteDataSource.logout();
    } catch (_) {
      // Ignore remote logout failure
    }
    try {
      await localDataSource.clearToken();
      await localDataSource.clearRefreshToken();
      await localDataSource.clearUser();
      return const Right(null);
    } catch (_) {
      return Left(CacheFailure(message: 'Could not safe logout'));
    }
  }

  @override
  Future<Either<Failure, AuthResponseModel>> checkAuthStatus() async {
    try {
      final token = await localDataSource.getToken();
      final authResponse = await localDataSource.getAuthResponse();
      if (token != null && token.isNotEmpty && authResponse != null) {
        return Right(authResponse);
      }
      return Left(CacheFailure(message: 'No active session'));
    } catch (_) {
      return Left(CacheFailure(message: 'Error checking session'));
    }
  }

  @override
  Future<Either<Failure, VerifyUserResult>> verifyUser(
    String usernameOrEmail,
  ) async {
    try {
      final result = await remoteDataSource.verifyUser(usernameOrEmail);
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
    } on NetworkException catch (e) {
      // Device is offline — propagate as NetworkFailure so the cubit
      // can keep the session alive instead of clearing it.
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
