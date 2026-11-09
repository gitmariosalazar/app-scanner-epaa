import 'dart:convert';
import 'package:flutter_application/features/reading-routes/data/models/lecturist_daily_kpi_model.dart';
import 'package:flutter_application/features/reading-routes/data/models/route_assignment_model.dart';
import 'package:flutter_application/features/reading-routes/data/models/route_work_pack_model.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/offline_reading.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ReadingRoutesLocalDataSource {
  Future<void> cacheAssignments(
    String userKey,
    List<RouteAssignmentModel> assignments,
  );
  Future<List<RouteAssignmentModel>?> getCachedAssignments(String userKey);

  Future<void> cacheRoutePack(int assignmentId, RouteWorkPackModel pack);
  Future<RouteWorkPackModel?> getCachedRoutePack(int assignmentId);
  Future<bool> isRoutePackDownloaded(int assignmentId);

  Future<void> enqueueOfflineReading(OfflineReading reading);
  Future<List<OfflineReading>> getOfflineReadings(int assignmentId);
  Future<void> removeOfflineReadings(int assignmentId, List<int> detailIds);
  Future<int> getPendingOfflineCount(int assignmentId);

  Future<void> cacheDailyKpi(String key, LecturistDailyKpiModel kpi);
  Future<LecturistDailyKpiModel?> getCachedDailyKpi(String key);
}

class ReadingRoutesLocalDataSourceImpl implements ReadingRoutesLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _keyAssignmentsPrefix = 'RR_ASSIGNMENTS_';
  static const String _keyPackPrefix = 'RR_PACK_';
  static const String _keyQueuePrefix = 'RR_OFFLINE_QUEUE_';
  static const String _keyKpiPrefix = 'RR_KPI_';

  ReadingRoutesLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheAssignments(
    String userKey,
    List<RouteAssignmentModel> assignments,
  ) async {
    final list = assignments.map((a) => a.toJson()).toList();
    await sharedPreferences.setString(
      '$_keyAssignmentsPrefix$userKey',
      jsonEncode(list),
    );
  }

  @override
  Future<List<RouteAssignmentModel>?> getCachedAssignments(
    String userKey,
  ) async {
    final raw = sharedPreferences.getString('$_keyAssignmentsPrefix$userKey');
    if (raw == null || raw.isEmpty) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => RouteAssignmentModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheRoutePack(int assignmentId, RouteWorkPackModel pack) async {
    final jsonStr = jsonEncode(pack.toJson());
    await sharedPreferences.setString('$_keyPackPrefix$assignmentId', jsonStr);
  }

  @override
  Future<RouteWorkPackModel?> getCachedRoutePack(int assignmentId) async {
    final raw = sharedPreferences.getString('$_keyPackPrefix$assignmentId');
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final pack = RouteWorkPackModel.fromJson(json);

      // Enriquecer con lecturas pendientes de la cola local
      final queue = await getOfflineReadings(assignmentId);
      if (queue.isEmpty) return pack;

      final queueMap = {for (var r in queue) r.idDetalleAvance: r};

      final updatedAcometidas = pack.acometidas.map((item) {
        final pending = queueMap[item.idDetalle];
        if (pending != null) {
          final isNovedad = pending.novedadId != null &&
              pending.novedadId!.isNotEmpty &&
              pending.novedadId != 'NORMAL';
          return item.copyWith(
            estado: isNovedad ? 'NOVEDAD' : 'LEIDA',
            lecturaActual: pending.lecturaActual,
            fechaHoraCaptura: pending.fechaHoraCaptura,
            novedadId: pending.novedadId,
            observaciones: pending.observaciones,
            isOfflinePending: true,
          );
        }
        return item;
      }).toList();

      final total = updatedAcometidas.length;
      final leidas = updatedAcometidas.where((a) => a.estado == 'LEIDA').length;
      final novedades = updatedAcometidas.where((a) => a.estado == 'NOVEDAD').length;
      final pendientes = updatedAcometidas.where((a) => a.estado == 'PENDIENTE' || a.estado == 'SALTADA').length;
      final pct = total > 0 ? ((leidas + novedades) / total * 100.0) : 0.0;

      return pack.copyWith(
        acometidas: updatedAcometidas,
        prediosLeidos: leidas,
        prediosConNovedad: novedades,
        prediosPendientes: pendientes,
        porcentajeAvance: double.parse(pct.toStringAsFixed(2)),
        isOffline: true,
      ) as RouteWorkPackModel;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isRoutePackDownloaded(int assignmentId) async {
    return sharedPreferences.containsKey('$_keyPackPrefix$assignmentId');
  }

  @override
  Future<void> enqueueOfflineReading(OfflineReading reading) async {
    final queue = await getOfflineReadings(reading.asignacionId);
    // Eliminar si ya existía una lectura para el mismo detalle (sobrescribir con la más reciente)
    queue.removeWhere((item) => item.idDetalleAvance == reading.idDetalleAvance);
    queue.add(reading);

    final jsonList = queue.map((r) => {
      'idDetalleAvance': r.idDetalleAvance,
      'acometidaId': r.acometidaId,
      'lecturaActual': r.lecturaActual,
      'fechaHoraCaptura': r.fechaHoraCaptura.toIso8601String(),
      'latitudGps': r.latitudGps,
      'longitudGps': r.longitudGps,
      'novedadId': r.novedadId,
      'fotoEvidenciaUrl': r.fotoEvidenciaUrl,
      'observaciones': r.observaciones,
      'asignacionId': r.asignacionId,
    }).toList();

    await sharedPreferences.setString(
      '$_keyQueuePrefix${reading.asignacionId}',
      jsonEncode(jsonList),
    );

    // Actualizar también el RoutePack en caché para que quede consistente
    final currentPack = await getCachedRoutePack(reading.asignacionId);
    if (currentPack != null) {
      await cacheRoutePack(reading.asignacionId, RouteWorkPackModel.fromEntity(currentPack));
    }
  }

  @override
  Future<List<OfflineReading>> getOfflineReadings(int assignmentId) async {
    final raw = sharedPreferences.getString('$_keyQueuePrefix$assignmentId');
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((item) {
        final map = item as Map<String, dynamic>;
        return OfflineReading(
          idDetalleAvance: map['idDetalleAvance'] as int,
          acometidaId: map['acometidaId'] as String,
          lecturaActual: (map['lecturaActual'] as num).toDouble(),
          fechaHoraCaptura: DateTime.parse(map['fechaHoraCaptura'] as String),
          latitudGps: map['latitudGps'] != null ? (map['latitudGps'] as num).toDouble() : null,
          longitudGps: map['longitudGps'] != null ? (map['longitudGps'] as num).toDouble() : null,
          novedadId: map['novedadId'] as String?,
          fotoEvidenciaUrl: map['fotoEvidenciaUrl'] as String?,
          observaciones: map['observaciones'] as String?,
          asignacionId: map['asignacionId'] as int? ?? assignmentId,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> removeOfflineReadings(
    int assignmentId,
    List<int> detailIds,
  ) async {
    final queue = await getOfflineReadings(assignmentId);
    queue.removeWhere((item) => detailIds.contains(item.idDetalleAvance));

    final jsonList = queue.map((r) => {
      'idDetalleAvance': r.idDetalleAvance,
      'acometidaId': r.acometidaId,
      'lecturaActual': r.lecturaActual,
      'fechaHoraCaptura': r.fechaHoraCaptura.toIso8601String(),
      'latitudGps': r.latitudGps,
      'longitudGps': r.longitudGps,
      'novedadId': r.novedadId,
      'fotoEvidenciaUrl': r.fotoEvidenciaUrl,
      'observaciones': r.observaciones,
      'asignacionId': r.asignacionId,
    }).toList();

    await sharedPreferences.setString(
      '$_keyQueuePrefix$assignmentId',
      jsonEncode(jsonList),
    );

    // Actualizar banderas isOfflinePending en el pack guardado
    final pack = await getCachedRoutePack(assignmentId);
    if (pack != null) {
      final updatedAcometidas = pack.acometidas.map((a) {
        if (detailIds.contains(a.idDetalle)) {
          return a.copyWith(isOfflinePending: false);
        }
        return a;
      }).toList();

      final updatedPack = RouteWorkPackModel(
        idAsignacion: pack.idAsignacion,
        periodo: pack.periodo,
        fechaProgramada: pack.fechaProgramada,
        estadoAsignacion: pack.estadoAsignacion,
        totalPredios: pack.totalPredios,
        prediosLeidos: pack.prediosLeidos,
        prediosConNovedad: pack.prediosConNovedad,
        prediosPendientes: pack.prediosPendientes,
        porcentajeAvance: pack.porcentajeAvance,
        idRuta: pack.idRuta,
        codigoRuta: pack.codigoRuta,
        nombreRuta: pack.nombreRuta,
        acometidas: updatedAcometidas,
        isOffline: pack.isOffline,
      );
      await cacheRoutePack(assignmentId, updatedPack);
    }
  }

  @override
  Future<int> getPendingOfflineCount(int assignmentId) async {
    final queue = await getOfflineReadings(assignmentId);
    return queue.length;
  }

  @override
  Future<void> cacheDailyKpi(String key, LecturistDailyKpiModel kpi) async {
    await sharedPreferences.setString(
      '$_keyKpiPrefix$key',
      jsonEncode(kpi.toJson()),
    );
  }

  @override
  Future<LecturistDailyKpiModel?> getCachedDailyKpi(String key) async {
    final raw = sharedPreferences.getString('$_keyKpiPrefix$key');
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return LecturistDailyKpiModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}
