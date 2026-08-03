import 'package:flutter/material.dart';
import 'package:flutter_application/components/messages/session_expired_dialog.dart';
import 'package:flutter_application/config/environments/environment.dart';
import 'package:flutter_application/core/theme/app_theme.dart';
import 'package:flutter_application/features/form/presentation/blocs/photo-readings/photo_reading_bloc.dart';
import 'package:flutter_application/features/theme/presentation/cubit/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/core/di/injection.dart' as di;
import 'package:flutter_application/core/router/app_router.dart';
import 'package:flutter_application/features/auth/presentation/cubit/login_cubit.dart';
import 'package:flutter_application/features/auth/presentation/cubit/login_state.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application/features/location_enforcer/presentation/cubit/location_enforcer_cubit.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'develop');
final envFile = flavor == 'prod' ? '.env.production' : '.env.dev';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);

  // 4. Carga el entorno correcto (API_URL desde .env.production o .env.dev)
  final envType = flavor == 'develop'
      ? EnvironmentType.dev
      : EnvironmentType.prod;

  await Environment.init(env: envType);

  // 5. Solo en dev: imprime config
  if (flavor == 'develop') {
    Environment.printConfig();
  }

  // 6. Inyección de dependencias
  await di.init();

  // 7. Inicializar tema persistido antes del primer frame
  await di.sl<ThemeCubit>().init();

  runApp(
    const ProviderScope(
      // ← Agrega esto
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<LoginCubit>()..checkAuthStatus()),
        BlocProvider(create: (_) => di.sl<PhotoReadingBloc>()),
        BlocProvider.value(value: di.sl<ThemeCubit>()),
        BlocProvider.value(value: di.sl<LocationEnforcerCubit>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state is LoginInitial) {
                AppRouter.router.go('/login');
              } else if (state is LoginSuccess) {
                AppRouter.router.go('/home');
              } else if (state is LoginSessionExpired) {
                final cubit = context.read<LoginCubit>();
                final dialogContext = AppRouter.navigatorKey.currentContext;
                if (dialogContext != null) {
                  SessionExpiredDialog.show(
                    dialogContext,
                    onExtend: cubit.extendSession,
                    onLogout: cubit.logout,
                  );
                }
              }
            },
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp.router(
              title: 'EPAA-AA Scanner',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              routerConfig: AppRouter.router,
            );
          },
        ),
      ),
    );
  }
}
