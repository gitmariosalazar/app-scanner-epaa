import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/core/network/refresh_exceptions.dart';
import 'package:flutter_application/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_application/features/auth/domain/entities/auth_response_entity.dart';
import 'package:flutter_application/features/auth/domain/repositories/auth_repository.dart';

/// Single-flight guard around `POST /auth/refresh`.
///
/// The backend rotates refresh tokens (single-use): each successful refresh
/// invalidates the previous one. Both the reactive 401 retry
/// ([AuthenticatedHttpClient]) and the proactive timer
/// ([SessionWatcherService]) can independently decide to refresh at nearly
/// the same time; without coordination the second call would race against
/// an already-rotated token and fail. Concurrent callers instead await the
/// same in-flight request.
class TokenRefreshCoordinator {
  final AuthRepository authRepository;
  final AuthLocalDataSource authLocalDataSource;

  TokenRefreshCoordinator({
    required this.authRepository,
    required this.authLocalDataSource,
  });

  Future<AuthResponseEntity>? _inFlight;

  Future<AuthResponseEntity> refresh() {
    return _inFlight ??= _performRefresh().whenComplete(() {
      _inFlight = null;
    });
  }

  Future<AuthResponseEntity> _performRefresh() async {
    final storedRefreshToken = await authLocalDataSource.getRefreshToken();
    if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
      throw AuthSessionExpiredException('No refresh token found');
    }

    final result = await authRepository.refreshToken(storedRefreshToken);
    return result.fold(
      (failure) => throw _toException(failure),
      (session) => session,
    );
  }

  Exception _toException(Failure failure) {
    if (failure is NetworkFailure) {
      return NetworkRefreshException(failure.message);
    }
    return AuthSessionExpiredException(failure.message);
  }
}
