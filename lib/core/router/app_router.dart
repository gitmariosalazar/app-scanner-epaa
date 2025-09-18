import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application/core/di/injection.dart' as di;
import 'package:flutter_application/features/auth/presentation/pages/login_screen.dart';
import 'package:flutter_application/features/home/presentation/pages/home_screen.dart';
import 'package:flutter_application/features/manually/presentation/bloc/manually_bloc.dart';
import 'package:flutter_application/features/manually/presentation/pages/manual_entry_screen.dart';
import 'package:flutter_application/features/scan/presentation/pages/scan_screen.dart';
import 'package:flutter_application/features/form/presentation/pages/form_screen.dart'
    as form;

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/scan', builder: (context, state) => const ScanScreen()),
      GoRoute(
        path: '/form',
        builder: (context, state) => form.FormScreen(
          apiResponse: state.extra as Map<String, dynamic>? ?? {},
        ),
      ),
      GoRoute(
        path: '/manually-entry',
        builder: (context, state) => BlocProvider(
          create: (context) => di.sl<ManuallyBloc>(),
          child: const ManualEntryScreen(),
        ),
      ),
    ],
  );
}
