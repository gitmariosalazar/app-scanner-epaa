import 'package:flutter_application/core/network/network_info.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/offline_reading.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_connection_item.dart';
import 'package:flutter_application/features/reading-routes/domain/usecases/get_route_work_pack_usecase.dart';
import 'package:flutter_application/features/reading-routes/domain/usecases/save_offline_reading_usecase.dart';
import 'package:flutter_application/features/reading-routes/domain/usecases/sync_pending_readings_usecase.dart';
import 'package:flutter_application/features/reading-routes/presentation/cubit/route_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RouteDetailCubit extends Cubit<RouteDetailState> {
  final GetRouteWorkPackUseCase getRouteWorkPackUseCase;
  final SaveOfflineReadingUseCase saveOfflineReadingUseCase;
  final SyncPendingReadingsUseCase syncPendingReadingsUseCase;
  final NetworkInfo networkInfo;

  RouteDetailCubit({
    required this.getRouteWorkPackUseCase,
    required this.saveOfflineReadingUseCase,
    required this.syncPendingReadingsUseCase,
    required this.networkInfo,
  }) : super(const RouteDetailInitial());

  Future<void> loadRoutePack(
    int assignmentId, {
    bool forceDownload = false,
  }) async {
    emit(const RouteDetailLoading());

    final isConnected = await networkInfo.isConnected;
    final result = await getRouteWorkPackUseCase(
      assignmentId,
      forceDownload: forceDownload,
    );

    result.fold(
      (failure) => emit(RouteDetailError(failure.message)),
      (pack) {
        final filtered = _applyFilter(pack.acometidas, 'TODAS', '');
        emit(
          RouteDetailLoaded(
            pack: pack,
            filteredAcometidas: filtered,
            selectedFilter: 'TODAS',
            searchQuery: '',
            isOnline: isConnected,
            activeConnection: pack.nextPendingInSequence,
          ),
        );
      },
    );
  }

  void filterAcometidas(String filter) {
    if (state is! RouteDetailLoaded) return;
    final s = state as RouteDetailLoaded;

    final filtered = _applyFilter(s.pack.acometidas, filter, s.searchQuery);
    emit(s.copyWith(selectedFilter: filter, filteredAcometidas: filtered));
  }

  void searchAcometidas(String query) {
    if (state is! RouteDetailLoaded) return;
    final s = state as RouteDetailLoaded;

    final filtered = _applyFilter(s.pack.acometidas, s.selectedFilter, query);
    emit(s.copyWith(searchQuery: query, filteredAcometidas: filtered));
  }

  void selectAcometida(RouteConnectionItem? item) {
    if (state is! RouteDetailLoaded) return;
    final s = state as RouteDetailLoaded;
    emit(s.copyWith(activeConnection: item));
  }

  Future<bool> takeReading(OfflineReading reading) async {
    if (state is! RouteDetailLoaded) return false;
    final s = state as RouteDetailLoaded;

    final result = await saveOfflineReadingUseCase(reading);

    return result.fold(
      (failure) {
        emit(s.copyWith(syncMessage: 'Error al registrar lectura: ${failure.message}'));
        return false;
      },
      (updatedPack) {
        final filtered = _applyFilter(
          updatedPack.acometidas,
          s.selectedFilter,
          s.searchQuery,
        );

        emit(
          s.copyWith(
            pack: updatedPack,
            filteredAcometidas: filtered,
            activeConnection: updatedPack.nextPendingInSequence,
            syncMessage: 'Lectura guardada localmente (pendiente de sincronización)',
          ),
        );

        // Si hay conexión de red, intentamos sincronización inmediata automática en segundo plano
        _tryAutoSync(updatedPack.idAsignacion);

        return true;
      },
    );
  }

  Future<void> _tryAutoSync(int assignmentId) async {
    if (await networkInfo.isConnected) {
      await syncBatch();
    }
  }

  Future<void> syncBatch() async {
    if (state is! RouteDetailLoaded) return;
    final s = state as RouteDetailLoaded;

    if (s.isSyncing) return;

    emit(s.copyWith(isSyncing: true, clearSyncMessage: true));

    final result = await syncPendingReadingsUseCase(s.pack.idAsignacion);

    result.fold(
      (failure) {
        emit(
          s.copyWith(
            isSyncing: false,
            syncMessage: 'No se pudo sincronizar: ${failure.message}',
          ),
        );
      },
      (syncResult) async {
        // Recargar el paquete actualizado
        final reloadResult = await getRouteWorkPackUseCase(s.pack.idAsignacion);
        reloadResult.fold(
          (_) {
            emit(
              s.copyWith(
                isSyncing: false,
                syncMessage: syncResult.totalExitosos > 0
                    ? '¡Sincronizadas ${syncResult.totalExitosos} lecturas correctamente!'
                    : 'No había lecturas pendientes para enviar.',
              ),
            );
          },
          (reloadedPack) {
            final filtered = _applyFilter(
              reloadedPack.acometidas,
              s.selectedFilter,
              s.searchQuery,
            );
            emit(
              s.copyWith(
                pack: reloadedPack,
                filteredAcometidas: filtered,
                isSyncing: false,
                activeConnection: reloadedPack.nextPendingInSequence,
                syncMessage: syncResult.totalExitosos > 0
                    ? '¡Sincronizadas ${syncResult.totalExitosos} lecturas con el servidor!'
                    : 'Todas las lecturas están al día.',
              ),
            );
          },
        );
      },
    );
  }

  List<RouteConnectionItem> _applyFilter(
    List<RouteConnectionItem> items,
    String filter,
    String query,
  ) {
    var result = items;

    // Filtro por estado
    switch (filter) {
      case 'PENDIENTES':
        result = result.where((a) => a.estado == 'PENDIENTE' || a.estado == 'SALTADA').toList();
        break;
      case 'LEIDAS':
        result = result.where((a) => a.estado == 'LEIDA').toList();
        break;
      case 'NOVEDADES':
        result = result.where((a) => a.estado == 'NOVEDAD').toList();
        break;
      default:
        // 'TODAS'
        break;
    }

    // Filtro de búsqueda
    if (query.isNotEmpty) {
      final q = query.toLowerCase().trim();
      result = result.where((a) {
        final id = a.acometidaId.toLowerCase();
        final cta = a.cuenta?.toLowerCase() ?? '';
        final med = a.numeroMedidor?.toLowerCase() ?? '';
        final abo = a.abonado.toLowerCase();
        final dir = a.direccion?.toLowerCase() ?? '';
        return id.contains(q) || cta.contains(q) || med.contains(q) || abo.contains(q) || dir.contains(q);
      }).toList();
    }

    return result;
  }
}
