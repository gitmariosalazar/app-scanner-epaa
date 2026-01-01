import 'package:flutter/material.dart';
import 'package:flutter_application/features/form/presentation/pages/location_screen.dart';
import 'package:flutter_application/features/observations/presentation/bloc/observation_bloc.dart';
import 'package:flutter_application/features/observations/presentation/pages/observation_page.dart';
import 'package:flutter_application/features/properties/form/presentation/screen/map_picker_screen.dart';
import 'package:flutter_application/features/properties/form/presentation/screen/update_form_screen.dart';
import 'package:flutter_application/features/properties/list/domain/entities/connection.dart';
import 'package:flutter_application/features/properties/list/presentation/manually/blocs/index.dart';
import 'package:flutter_application/features/reading/domain/entities/reading.dart';
import 'package:flutter_application/features/reading/presentation/manually/blocs/index.dart';
import 'package:flutter_application/features/reading/presentation/scan/bloc/index.dart';
import 'package:flutter_application/features/work-orders/presentation/screen/add_work_order_form_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application/core/di/injection.dart' as di;
import 'package:flutter_application/features/auth/presentation/pages/login_screen.dart';
import 'package:flutter_application/features/home/presentation/pages/home_screen.dart';
import 'package:flutter_application/features/reading/presentation/scan/pages/scan_screen.dart';
import 'package:flutter_application/features/reading/presentation/manually/pages/manually_screen.dart';
import 'package:flutter_application/features/form/presentation/pages/form_screen.dart'
    as form;
import 'package:flutter_application/features/form/presentation/blocs/readings/form_bloc.dart'
    as form_bloc;
import 'package:flutter_application/main.dart'; // Importa routeObserver

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    observers: [routeObserver],
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/location',
        builder: (context, state) => const LocationPage(),
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => BlocProvider(
          create: (_) => di.sl<ReadingScanBloc>(),
          child: const ScanPage(),
        ),
      ),
      GoRoute(
        path: '/form',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final reading = extra['reading'] as List<Reading>? ?? [];
          final mode = extra['mode'] as String? ?? 'manual';

          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => di.sl<form_bloc.FormBloc>()),
              BlocProvider(
                create: (_) => di.sl<ManuallyConnectionWithPropertiesBloc>(),
              ),
            ],
            child: form.FormScreen(reading: reading, mode: mode),
          );
        },
      ),
      GoRoute(
        path: '/manually-entry',
        builder: (context, state) => BlocProvider(
          create: (_) => di.sl<ReadingManuallyBloc>(),
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
      GoRoute(
        path: '/add-work-order',
        builder: (context, state) => const AddWorkOrderFormScreen(),
      ),

      GoRoute(
        path: '/update-form',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;

          if (extra == null ||
              !extra.containsKey('connection') ||
              extra['connection'] == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error: Datos de conexión no proporcionados'),
                  backgroundColor: Colors.red,
                ),
              );
              context.go('/home');
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final connectionData = extra['connection'];
          final mode = extra['mode'] as String? ?? 'manual';

          ConnectionEntity connection;

          if (connectionData is ConnectionEntity) {
            connection = connectionData;
          } else if (connectionData is Map<String, dynamic>) {
            connection = ConnectionEntity.fromJson(connectionData);
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error: Tipo de datos de conexión inválido'),
                  backgroundColor: Colors.red,
                ),
              );
              context.go('/home');
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return UpdateConnectionFormScreen(connection: connection, mode: mode);
        },
      ),
      GoRoute(
        path: '/map-picker',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;

          final initialLat = extra['initialLat'] as double;
          final initialLng = extra['initialLng'] as double;

          return MapPickerScreen(
            initialLat: initialLat,
            initialLng: initialLng,
            onLocationPicked: (lat, lng) {
              context.pop({'lat': lat, 'lng': lng});
            },
          );
        },
      ),
    ],
  );
}
