import 'package:flutter/material.dart';
import 'package:flutter_application/features/form/presentation/pages/location_screen.dart';
import 'package:flutter_application/features/observations/presentation/bloc/observation_bloc.dart';
import 'package:flutter_application/features/observations/presentation/pages/observation_page.dart';
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
import 'package:flutter_application/features/form/presentation/blocs/readings/form_bloc.dart'
    as form_bloc;
import 'package:flutter_application/main.dart'; // Importa routeObserver

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    observers: [routeObserver], // <-- Añade RouteObserver aquí
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/location',
        builder: (context, state) => const LocationPage(),
      ),
      GoRoute(path: '/scan', builder: (context, state) => const ScanScreen()),
      GoRoute(
        path: '/form',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final apiResponse =
              extra['apiResponse'] as Map<String, dynamic>? ?? {};
          final mode = extra['mode'] as String? ?? 'manual';
          debugPrint('Navegando a /form con extra: $extra, mode: $mode');
          return BlocProvider(
            create: (_) {
              final bloc = di.sl<form_bloc.FormBloc>();
              debugPrint('FormBloc creado en AppRouter: $bloc');
              return bloc;
            },
            child: form.FormScreen(apiResponse: apiResponse, mode: mode),
          );
        },
      ),
      GoRoute(
        path: '/manually-entry',
        builder: (context, state) => BlocProvider(
          create: (context) => di.sl<ManuallyBloc>(),
          child: const ManualEntryScreen(),
        ),
      ),
      GoRoute(
        path: '/observations',
        builder: (context, state) {
          final connectionId = state.extra as String?; // <-- opcional
          final bloc = di.sl<ObservationBloc>();
          bloc.add(FindAllObservationsEvent());
          return BlocProvider.value(
            value: bloc,
            child: ObservationPage(connectionId: connectionId ?? ''),
          );
        },
      ),
    ],
  );
}
