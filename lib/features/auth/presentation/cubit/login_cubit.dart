import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/core/network/jwt_utils.dart';
import 'package:flutter_application/core/network/refresh_exceptions.dart';
import 'package:flutter_application/core/network/session_event_bus.dart';
import 'package:flutter_application/core/network/token_refresh_coordinator.dart';
import 'package:flutter_application/core/services/session_watcher_service.dart';
import 'package:flutter_application/core/usecases/usecase.dart';
import 'package:flutter_application/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:flutter_application/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_application/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_application/features/auth/presentation/cubit/login_state.dart';

/// Cubit that orchestrates the full authentication lifecycle.
///
/// ── checkAuthStatus decision tree ─────────────────────────────────────────
///
///   Cache empty             → [LoginInitial]     (go to login)
///   Cache found, then:
///     NetworkRefreshException → [LoginSuccess]   (keep session, work offline)
///     AuthSessionExpiredException → [LoginInitial] (force re-login)
///     exists == true        → [LoginSuccess]     (normal session restore)
///     exists == false       → [LoginUserNotFound] (account deleted/inactive)
///
/// Session lifetime (proactive refresh + backgrounded-idle timeout) is fully
/// delegated to [SessionWatcherService]; this cubit only reacts to
/// [SessionEventBus] events to decide what to show the user, and delegates
/// every actual refresh call to the shared [TokenRefreshCoordinator] so it
/// can never race the reactive 401 retry in [AuthenticatedHttpClient].
class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final TokenRefreshCoordinator refreshCoordinator;
  final SessionWatcherService sessionWatcherService;
  final SessionEventBus sessionEventBus;

  StreamSubscription<SessionEvent>? _sessionEventSubscription;

  LoginCubit({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.checkAuthStatusUseCase,
    required this.refreshCoordinator,
    required this.sessionWatcherService,
    required this.sessionEventBus,
  }) : super(LoginInitial()) {
    _sessionEventSubscription = sessionEventBus.events.listen(_onSessionEvent);
  }

  void _onSessionEvent(SessionEvent event) {
    final currentState = state;
    if (event == SessionEvent.expired && currentState is LoginSuccess) {
      emit(LoginSessionExpired(currentState.user));
    }
  }

  Future<void> checkAuthStatus() async {
    final localResult = await checkAuthStatusUseCase(NoParams());

    await localResult.fold((_) async => emit(LoginInitial()), (
      authResponse,
    ) async {
      // Margen de 1 minuto para evitar expiraciones en tránsito
      if (!JwtUtils.isExpired(authResponse.accessToken, bufferMs: 60000)) {
        emit(LoginSuccess(authResponse.user, authResponse.accessToken));
        sessionWatcherService.start(authResponse.accessToken);
        return;
      }

      // If there's no refresh token, we can't refresh
      if (authResponse.refreshToken.isEmpty) {
        _clearLocalSession();
        emit(LoginInitial());
        return;
      }

      try {
        final session = await refreshCoordinator.refresh();
        emit(LoginSuccess(session.user, session.accessToken));
        sessionWatcherService.start(session.accessToken);
      } on NetworkRefreshException {
        // ✅ No internet — keep cached session, work offline
        emit(LoginSuccess(authResponse.user, authResponse.accessToken));
      } on AuthSessionExpiredException {
        // ⛔ Token expired or invalid → force re-login
        _clearLocalSession();
        emit(LoginInitial());
      }
    });
  }

  Future<void> login(String usernameOrEmail, String password) async {
    emit(LoginLoading());
    final result = await loginUseCase(
      LoginParams(usernameOrEmail: usernameOrEmail, password: password),
    );

    result.fold((failure) => emit(LoginFailure(failure.message)), (
      authResponse,
    ) {
      emit(LoginSuccess(authResponse.user, authResponse.accessToken));
      sessionWatcherService.start(authResponse.accessToken);
    });
  }

  Future<void> logout() async {
    emit(LoginLoading());
    sessionWatcherService.stop();
    final result = await logoutUseCase(NoParams());
    result.fold(
      (failure) => emit(LoginFailure(failure.message)),
      (_) => emit(LoginInitial()),
    );
  }

  /// Called by [SessionExpiredDialog]'s "Continuar sesión" action.
  Future<void> extendSession() async {
    try {
      final session = await refreshCoordinator.refresh();
      emit(LoginSuccess(session.user, session.accessToken));
      sessionWatcherService.start(session.accessToken);
    } catch (_) {
      await logout();
    }
  }

  void _clearLocalSession() {
    sessionWatcherService.stop();
    logoutUseCase(NoParams()).ignore();
  }

  @override
  Future<void> close() {
    _sessionEventSubscription?.cancel();
    return super.close();
  }
}
