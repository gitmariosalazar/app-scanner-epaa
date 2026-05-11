import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/core/usecases/usecase.dart';
import 'package:flutter_application/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:flutter_application/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_application/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_application/features/auth/domain/usecases/verify_user_usecase.dart';
import 'package:flutter_application/features/auth/presentation/cubit/login_state.dart';

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

  /// Checks local cache first. If a session exists, verifies the cached user
  /// against the remote backend — this call is MANDATORY.
  ///
  /// ✅ Backend confirms user exists & active  → [LoginSuccess]
  /// ⛔ Backend says user not found / inactive → [LoginUserNotFound] + clear cache
  /// ⛔ Backend unreachable / any server error  → [LoginInitial] + clear cache
  Future<void> checkAuthStatus() async {
    // Step 1: Check local cache
    final localResult = await checkAuthStatusUseCase(NoParams());

    await localResult.fold(
      // No local session at all → go to login
      (_) async => emit(LoginInitial()),

      // Local session found → MUST verify against backend
      (user) async {
        final verifyResult = await verifyUserUseCase(
          VerifyUserParams(usernameOrEmail: user.username),
        );

        verifyResult.fold(
          // ⛔ Backend unreachable / error → clear session, force login
          (failure) {
            _clearLocalSession();
            emit(LoginInitial());
          },

          (verifyData) {
            if (verifyData.exists) {
              // ✅ User confirmed in backend → restore session
              emit(LoginSuccess(user));
            } else {
              // ⛔ User deleted or deactivated → clear session, notify user
              _clearLocalSession();
              emit(
                const LoginUserNotFound(
                  'Tu cuenta ya no existe o fue desactivada. Por favor inicia sesión nuevamente.',
                ),
              );
            }
          },
        );
      },
    );
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

  /// Clears local cache silently — fire-and-forget, errors are swallowed.
  void _clearLocalSession() {
    logoutUseCase(NoParams()).ignore();
  }
}

