import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/lecturist_daily_kpi.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/offline_reading.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_assignment.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_work_pack.dart';

abstract class ReadingRoutesRepository {
  /// Obtener las asignaciones de rutas del lecturista.
  /// Si está online las consulta de red y las almacena localmente.
  /// Si está offline las recupera de caché local.
  Future<Either<Failure, List<RouteAssignment>>> getUserAssignments({
    String? periodoMes,
    String? fecha,
    bool forceRefresh = false,
  });

  /// Obtener el paquete de trabajo de una asignación específica.
  /// Incluye todas las acometidas en secuencia.
  /// Si forceDownload = true, descarga del backend y sobrescribe la versión local.
  Future<Either<Failure, RouteWorkPack>> getRouteWorkPack(
    int assignmentId, {
    bool forceDownload = false,
  });

  /// Guardar una lectura tomada offline. Actualiza el estado local de la
  /// acometida y encola el item para sincronización por lotes.
  Future<Either<Failure, RouteWorkPack>> saveOfflineReading(
    OfflineReading reading,
  );

  /// Sincronizar el lote de lecturas pendientes para una asignación específica o todas.
  Future<Either<Failure, SyncBatchResult>> syncPendingBatch(int assignmentId);

  /// Consultar el KPI diario del lecturista autenticado.
  Future<Either<Failure, LecturistDailyKpi>> getDailyKpi({String? fecha});

  /// Cantidad de lecturas offline pendientes de sincronizar para una asignación.
  Future<int> getPendingSyncCount(int assignmentId);

  /// Comprobar si una asignación está descargada localmente para trabajar offline.
  Future<bool> isRouteDownloaded(int assignmentId);
}
