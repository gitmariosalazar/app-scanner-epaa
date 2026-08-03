import 'package:flutter/material.dart';
import 'package:flutter_application/features/audit/presentation/pages/audit_screen.dart';
import 'package:flutter_application/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:flutter_application/features/form/presentation/pages/location_screen.dart';
import 'package:flutter_application/features/home/presentation/pages/lecturas_screen.dart';
import 'package:flutter_application/features/home/presentation/pages/shell_navigator.dart';
import 'package:flutter_application/features/home/presentation/pages/welcome_screen.dart';
import 'package:flutter_application/features/incidents/presentation/cubit/incident_cubit.dart';
import 'package:flutter_application/features/incidents/presentation/page/create_incident_form.dart';
import 'package:flutter_application/features/incidents/presentation/page/incident_history_page.dart';
import 'package:flutter_application/features/incidents/presentation/pages/solve_incident_screen.dart';
import 'package:flutter_application/features/observations/presentation/bloc/observation_bloc.dart';
import 'package:flutter_application/features/observations/presentation/pages/observation_page.dart';
import 'package:flutter_application/features/properties/form/presentation/screen/map_picker_screen.dart';
import 'package:flutter_application/features/properties/form/presentation/screen/update_form_screen.dart';
import 'package:flutter_application/features/profile/presentation/pages/profile_screen.dart';
import 'package:flutter_application/features/properties/list/domain/entities/connection.dart';
import 'package:flutter_application/features/properties/list/presentation/manually/blocs/index.dart';
import 'package:flutter_application/features/public/presentation/cubit/public_incidents_map_cubit.dart';
import 'package:flutter_application/features/public/presentation/pages/public_incidents_dashboard_screen.dart';
import 'package:flutter_application/features/public/presentation/pages/public_incidents_map_screen.dart';
import 'package:flutter_application/features/reading/domain/entities/reading.dart';
import 'package:flutter_application/features/reading/presentation/manually/blocs/index.dart';
import 'package:flutter_application/features/reading/presentation/scan/bloc/index.dart';
import 'package:flutter_application/features/settings/presentation/pages/settings_screen.dart';
import 'package:flutter_application/features/work-orders/presentation/screen/add_work_order_form_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application/core/di/injection.dart' as di;
import 'package:flutter_application/features/auth/presentation/cubit/login_cubit.dart';
import 'package:flutter_application/features/auth/presentation/cubit/login_state.dart';
import 'package:flutter_application/features/auth/presentation/pages/login_screen.dart';
import 'package:flutter_application/features/reading/presentation/scan/pages/scan_screen.dart';
import 'package:flutter_application/features/reading/presentation/manually/pages/manually_screen.dart';
import 'package:flutter_application/features/form/presentation/pages/form_screen.dart'
    as form;
import 'package:flutter_application/features/form/presentation/blocs/readings/form_bloc.dart'
    as form_bloc;
import 'package:flutter_application/main.dart';
import 'package:flutter_application/features/properties/search/presentation/info/pages/SearchConnectionPage.dart';
import 'package:flutter_application/features/properties/search/presentation/offline/pages/offline_preload_screen.dart';
import 'package:flutter_application/features/properties/search/presentation/info/cubit/search_connection_cubit.dart';
import 'package:flutter_application/features/properties/search/domain/entities/connection.dart'
    as search_connection;
import 'package:flutter_application/features/properties/list/domain/entities/person.dart'
    as list_person;
import 'package:flutter_application/features/properties/list/domain/entities/company.dart'
    as list_company;

class AppRouter {
  /// Exposes a [BuildContext] that is always inside the Navigator/
  /// Localizations tree, for callers (e.g. the root session-expired
  /// listener in `main.dart`) that need to show a dialog from outside the
  /// widget tree that owns the current route's context.
  static final navigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/login',
    observers: [routeObserver],
    // GoRouter 16.x resolves the platform URI before initialLocation;
    // redirect '/' to '/login' so unmatched root never throws.
    redirect: (context, state) {
      final authState = di.sl<LoginCubit>().state;
      final isAuthenticated = authState is LoginSuccess;

      if (state.uri.path == '/') {
        return isAuthenticated ? '/home' : '/login';
      }

      if (state.uri.path == '/login' && isAuthenticated) {
        return '/home';
      }

      return null;
    },
    routes: [
      // ── Auth (no shell) ──────────────────────────────────────────
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // ── Shell: tabs con bottom nav ───────────────────────────────
      ShellRoute(
        builder: (context, state, child) => ShellNavigator(child: child),
        routes: [
          GoRoute(path: '/inicio', builder: (_, __) => const WelcomeScreen()),
          GoRoute(path: '/home', builder: (_, __) => const DashboardScreen()),
          GoRoute(
            path: '/lecturas',
            builder: (_, __) => const LecturasScreen(),
          ),
          GoRoute(path: '/auditoria', builder: (_, __) => const AuditScreen()),
          GoRoute(
            path: '/settings',
            builder: (_, __) => const SettingsScreen(),
          ),
        ],
      ),

      // ── Full-screen routes (sin bottom nav) ──────────────────────
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
          final connectionId = state.extra as String?;
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
              context.go('/inicio');
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
          } else if (connectionData
              is search_connection.ConnectionWithPropertiesEntity) {
            connection = ConnectionEntity(
              connectionId: connectionData.connectionId,
              clientId: connectionData.clientId,
              connectionRateId: connectionData.connectionRateId,
              connectionRateName: connectionData.connectionRateName,
              connectionMeterNumber: connectionData.connectionMeterNumber,
              connectionSector: connectionData.connectionSector,
              connectionAccount: connectionData.connectionAccount,
              connectionCadastralKey: connectionData.connectionCadastralKey,
              connectionContractNumber: connectionData.connectionContractNumber,
              connectionSewerage: connectionData.connectionSewerage,
              connectionStatus: connectionData.connectionStatus,
              connectionAddress: connectionData.connectionAddress,
              connectionInstallationDate:
                  connectionData.connectionInstallationDate,
              connectionPeopleNumber: connectionData.connectionPeopleNumber,
              connectionZone: connectionData.connectionZone,
              connectionCoordinates: connectionData.connectionCoordinates,
              connectionReference: connectionData.connectionReference,
              connectionMetadata: connectionData.connectionMetadata,
              connectionAltitude: connectionData.connectionAltitude,
              connectionPrecision: connectionData.connectionPrecision,
              connectionGeolocationDate:
                  connectionData.connectionGeolocationDate,
              connectionGeometricZone: connectionData.connectionGeometricZone,
              propertyCadastralKey: connectionData.propertyCadastralKey,
              zoneId: connectionData.zoneId,
              zoneCode: connectionData.zoneCode,
              zoneName: connectionData.zoneName,
              person: connectionData.person != null
                  ? list_person.PersonEntity(
                      personId: connectionData.person!.personId,
                      firstName: connectionData.person!.firstName,
                      lastName: connectionData.person!.lastName,
                      address: connectionData.person!.address,
                      country: connectionData.person!.country,
                      genderId: connectionData.person!.genderId,
                      parishId: connectionData.person!.parishId,
                      birthDate: connectionData.person!.birthDate,
                      isDeceased: connectionData.person!.isDeceased,
                      professionId: connectionData.person!.professionId,
                      civilStatus: connectionData.person!.civilStatus,
                      emails: const [],
                      phones: const [],
                    )
                  : null,
              company: connectionData.company != null
                  ? list_company.CompanyEntity(
                      companyId: connectionData.company!.companyId,
                      businessName: connectionData.company!.businessName,
                      commercialName: connectionData.company!.commercialName,
                      ruc: connectionData.company!.ruc,
                      address: connectionData.company!.address,
                      country: connectionData.company!.country,
                      clientId: connectionData.company!.clientId,
                      parishId: connectionData.company!.parishId,
                      emails: const [],
                      phones: const [],
                    )
                  : null,
              properties: const [],
            );
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error: Tipo de datos de conexión inválido'),
                  backgroundColor: Colors.red,
                ),
              );
              context.go('/inicio');
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
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // INCIDENTS
      GoRoute(
        path: '/create-incident',
        builder: (context, state) {
          final connectionId = state.extra as String?;
          return BlocProvider(
            create: (_) => di.sl<IncidentCubit>(),
            child: CreateIncidentForm(connectionId: connectionId ?? ''),
          );
        },
      ),
      GoRoute(
        path: '/solve-incident',
        builder: (context, state) {
          final incidentData = state.extra as Map<String, dynamic>;
          final incidentId = incidentData['incidentId'] as String;
          final incidentCode = incidentData['incidentCode'] as String;
          return BlocProvider(
            create: (_) => di.sl<IncidentCubit>(),
            child: SolveIncidentScreen(
              incidentId: incidentId,
              incidentCode: incidentCode,
            ),
          );
        },
      ),
      GoRoute(
        path: '/incidents-history',
        builder: (context, state) => BlocProvider(
          create: (_) => di.sl<IncidentCubit>(),
          child: const IncidentHistoryPage(),
        ),
      ),
      GoRoute(
        path: '/search-connection',
        builder: (context, state) => BlocProvider(
          create: (_) => di.sl<SearchConnectionCubit>(),
          child: const SearchConnectionPage(),
        ),
      ),
      GoRoute(
        path: '/offline-preload',
        builder: (context, state) => const OfflinePreloadScreen(),
      ),
      GoRoute(
        path: '/public-incidents-dashboard',
        builder: (context, state) => const PublicIncidentsDashboardScreen(),
      ),
      GoRoute(
        path: '/public-incidents-map',
        builder: (context, state) => BlocProvider(
          create: (_) => di.sl<PublicIncidentsMapCubit>()..loadMapIncidents(),
          child: const PublicIncidentsMapScreen(),
        ),
      ),
    ],
  );
}
