import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/core/usecases/usecase.dart';
import 'package:flutter_application/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:flutter_application/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_application/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_application/features/auth/domain/usecases/verify_user_usecase.dart';
import 'package:flutter_application/features/auth/presentation/cubit/login_state.dart';

/// Cubit that orchestrates the full authentication lifecycle.
///
/// ── checkAuthStatus decision tree ─────────────────────────────────────────
///
///   Cache empty             → [LoginInitial]     (go to login)
///   Cache found, then:
///     NetworkFailure        → [LoginSuccess]     (keep session, work offline) ✅ FIX
///     ServerFailure (other) → [LoginInitial]     (force re-login)
///     exists == true        → [LoginSuccess]     (normal session restore)
///     exists == false       → [LoginUserNotFound] (account deleted/inactive)
class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final VerifyUserUseCase verifyUserUseCase;

  LoginCubit({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.checkAuthStatusUseCase,
    required this.verifyUserUseCase,
  }) : super(LoginInitial());

  Future<void> checkAuthStatus() async {
    final localResult = await checkAuthStatusUseCase(NoParams());

    await localResult.fold((_) async => emit(LoginInitial()), (user) async {
      final verifyResult = await verifyUserUseCase(
        VerifyUserParams(usernameOrEmail: user.username),
      );

      verifyResult.fold(
        (failure) {
          if (failure is NetworkFailure) {
            // ✅ No internet — keep cached session, work offline
            emit(LoginSuccess(user));
          } else {
            // ⛔ Unexpected server error → force re-login
            _clearLocalSession();
            emit(LoginInitial());
          }
        },

        (verifyData) {
          if (verifyData.exists) {
            emit(LoginSuccess(user));
          } else {
            _clearLocalSession();
            emit(
              const LoginUserNotFound(
                'Tu cuenta ya no existe o fue desactivada. '
                'Por favor inicia sesión nuevamente.',
              ),
            );
          }
        },
      );
    });
  }

  Future<void> login(String usernameOrEmail, String password) async {
    emit(LoginLoading());
    final result = await loginUseCase(
      LoginParams(usernameOrEmail: usernameOrEmail, password: password),
    );
    result.fold(
      (failure) => emit(LoginFailure(failure.message)),
      (user) => emit(LoginSuccess(user)),
    );
  }

  Future<void> logout() async {
    emit(LoginLoading());
    final result = await logoutUseCase(NoParams());
    result.fold(
      (failure) => emit(LoginFailure(failure.message)),
      (_) => emit(LoginInitial()),
    );
  }

  void _clearLocalSession() {
    logoutUseCase(NoParams()).ignore();
  }
}
