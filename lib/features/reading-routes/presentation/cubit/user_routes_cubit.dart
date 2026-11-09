import 'package:flutter_application/core/network/network_info.dart';
import 'package:flutter_application/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/lecturist_daily_kpi.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_assignment.dart';
import 'package:flutter_application/features/reading-routes/domain/usecases/get_lecturist_kpi_usecase.dart';
import 'package:flutter_application/features/reading-routes/domain/usecases/get_route_work_pack_usecase.dart';
import 'package:flutter_application/features/reading-routes/domain/usecases/get_user_route_assignments_usecase.dart';
import 'package:flutter_application/features/reading-routes/presentation/cubit/user_routes_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserRoutesCubit extends Cubit<UserRoutesState> {
  final GetUserRouteAssignmentsUseCase getUserRouteAssignmentsUseCase;
  final GetLecturistKpiUseCase getLecturistKpiUseCase;
  final GetRouteWorkPackUseCase getRouteWorkPackUseCase;
  final NetworkInfo networkInfo;
  final AuthLocalDataSource authLocalDataSource;

  UserRoutesCubit({
    required this.getUserRouteAssignmentsUseCase,
    required this.getLecturistKpiUseCase,
    required this.getRouteWorkPackUseCase,
    required this.networkInfo,
    required this.authLocalDataSource,
  }) : super(const UserRoutesInitial());

  Future<void> loadRoutes({
    bool forceRefresh = false,
    String? periodoMes,
    String? fecha,
  }) async {
    emit(const UserRoutesLoading());

    final isConnected = await networkInfo.isConnected;
    String? currentUserId;
    try {
      final authResponse = await authLocalDataSource.getAuthResponse();
      currentUserId = authResponse?.user.id;
    } catch (_) {}

    // Fetch assignments and KPI concurrently
    final assignmentsResult = await getUserRouteAssignmentsUseCase(
      periodoMes: periodoMes,
      fecha: fecha,
      forceRefresh: forceRefresh,
    );

    final kpiResult = await getLecturistKpiUseCase(fecha: fecha);

    assignmentsResult.fold(
      (failure) {
        emit(UserRoutesError(failure.message));
      },
      (routes) {
        // Las rutas ya vienen filtradas por el backend con el endpoint /my-routes.
        // Como capa adicional de defensa, normalizamos IDs para asegurar coincidencia exacta:
        final normalizedCurrentId = currentUserId?.toLowerCase().trim();
        final userFilteredRoutes = (normalizedCurrentId != null &&
                normalizedCurrentId.isNotEmpty &&
                routes.any((r) =>
                    r.usuarioId.toLowerCase().trim() == normalizedCurrentId))
            ? routes
                .where((r) =>
                    r.usuarioId.toLowerCase().trim() == normalizedCurrentId)
                .toList()
            : routes;

        final kpi = kpiResult.fold(
          (_) => LecturistDailyKpi.empty(currentUserId ?? '', fecha ?? ''),
          (data) => data,
        );

        final initialFiltered = _applyFilter(
          userFilteredRoutes,
          'TODAS',
          '',
        );

        emit(
          UserRoutesLoaded(
            allRoutes: userFilteredRoutes,
            filteredRoutes: initialFiltered,
            kpi: kpi,
            selectedFilter: 'TODAS',
            searchQuery: '',
            isOnline: isConnected,
          ),
        );
      },
    );
  }

  void filterByStatus(String filter) {
    if (state is! UserRoutesLoaded) return;
    final s = state as UserRoutesLoaded;

    final filtered = _applyFilter(s.allRoutes, filter, s.searchQuery);
    emit(s.copyWith(selectedFilter: filter, filteredRoutes: filtered));
  }

  void search(String query) {
    if (state is! UserRoutesLoaded) return;
    final s = state as UserRoutesLoaded;

    final filtered = _applyFilter(s.allRoutes, s.selectedFilter, query);
    emit(s.copyWith(searchQuery: query, filteredRoutes: filtered));
  }

  Future<void> downloadRoutePack(int assignmentId) async {
    if (state is! UserRoutesLoaded) return;
    final s = state as UserRoutesLoaded;

    emit(s.copyWith(downloadingAssignmentId: assignmentId));

    final result = await getRouteWorkPackUseCase(
      assignmentId,
      forceDownload: true,
    );

    result.fold(
      (failure) {
        emit(
          s.copyWith(
            clearDownloading: true,
            successMessage: 'Error al descargar ruta: ${failure.message}',
          ),
        );
      },
      (pack) {
        // Marcar la asignación como descargada localmente
        final updatedAll = s.allRoutes.map((r) {
          if (r.idAsignacion == assignmentId) {
            return r.copyWith(isDownloadedOffline: true);
          }
          return r;
        }).toList();

        final updatedFiltered = _applyFilter(
          updatedAll,
          s.selectedFilter,
          s.searchQuery,
        );

        emit(
          s.copyWith(
            allRoutes: updatedAll,
            filteredRoutes: updatedFiltered,
            clearDownloading: true,
            successMessage: 'Paquete de trabajo descargado con éxito (${pack.totalPredios} predios)',
          ),
        );
      },
    );
  }

  List<RouteAssignment> _applyFilter(
    List<RouteAssignment> routes,
    String filter,
    String query,
  ) {
    var result = routes;

    // Filtro por estado
    if (filter == 'PENDIENTES') {
      result = result
          .where((r) => r.estado != 'COMPLETADA')
          .toList();
    } else if (filter == 'COMPLETADAS') {
      result = result
          .where((r) => r.estado == 'COMPLETADA' || r.porcentajeAvance >= 100.0)
          .toList();
    }

    // Filtro por texto de búsqueda
    if (query.isNotEmpty) {
      final q = query.toLowerCase().trim();
      result = result.where((r) {
        final cod = r.codigoRuta.toLowerCase();
        final nom = r.nombreRuta.toLowerCase();
        final sec = 'sector ${r.sector}'.toLowerCase();
        return cod.contains(q) || nom.contains(q) || sec.contains(q);
      }).toList();
    }

    return result;
  }
}
