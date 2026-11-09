import 'package:flutter_application/features/reading-routes/domain/entities/route_assignment.dart';

class RouteAssignmentModel extends RouteAssignment {
  const RouteAssignmentModel({
    required super.idAsignacion,
    required super.rutaId,
    required super.codigoRuta,
    required super.nombreRuta,
    required super.sector,
    required super.usuarioId,
    required super.nombreLecturista,
    required super.empleadoId,
    required super.periodoMes,
    super.fechaProgramada,
    super.fechaInicio,
    super.fechaCierre,
    required super.estado,
    required super.totalPredios,
    required super.prediosLeidos,
    required super.prediosConNovedad,
    required super.prediosPendientes,
    required super.porcentajeAvance,
    super.isDownloadedOffline,
    super.pendingOfflineCount,
  });

  factory RouteAssignmentModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString());
    }

    return RouteAssignmentModel(
      idAsignacion: parseInt(json['idAsignacion'] ?? json['id_asignacion']),
      rutaId: parseInt(json['rutaId'] ?? json['ruta_id']),
      codigoRuta: (json['codigoRuta'] ?? json['codigo_ruta'] ?? '').toString(),
      nombreRuta: (json['nombreRuta'] ?? json['nombre_ruta'] ?? '').toString(),
      sector: parseInt(json['sector'] ?? json['sector_id']),
      usuarioId:
          (json['usuarioId'] ??
                  json['usuario_id'] ??
                  json['lecturistaId'] ??
                  '')
              .toString(),
      nombreLecturista:
          (json['nombreLecturista'] ?? json['nombre_lecturista'] ?? 'Operador')
              .toString(),
      empleadoId: (json['empleadoId'] ?? json['empleado_id'] ?? '').toString(),
      periodoMes:
          (json['periodoMes'] ?? json['periodo_mes'] ?? json['periodo'] ?? '')
              .toString(),
      fechaProgramada: parseDate(
        json['fechaProgramada'] ?? json['fecha_programada'],
      ),
      fechaInicio: parseDate(json['fechaInicio'] ?? json['fecha_inicio']),
      fechaCierre: parseDate(json['fechaCierre'] ?? json['fecha_fin']),
      estado: (json['estado'] ?? 'ASIGNADA').toString(),
      totalPredios: parseInt(
        json['totalPredios'] ??
            json['lecturas_esperadas'] ??
            json['lecturasEsperadas'],
      ),
      prediosLeidos: parseInt(
        json['prediosLeidos'] ??
            json['lecturas_completadas'] ??
            json['lecturasCompletadas'],
      ),
      prediosConNovedad: parseInt(
        json['prediosConNovedad'] ??
            json['lecturas_novedad'] ??
            json['lecturasNovedad'],
      ),
      prediosPendientes: parseInt(
        json['prediosPendientes'] ??
            json['lecturas_pendientes'] ??
            json['lecturasPendientes'],
      ),
      porcentajeAvance: parseDouble(
        json['porcentajeAvance'] ?? json['porcentaje_avance'],
      ),
      isDownloadedOffline: json['isDownloadedOffline'] == true,
      pendingOfflineCount: parseInt(json['pendingOfflineCount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idAsignacion': idAsignacion,
      'rutaId': rutaId,
      'codigoRuta': codigoRuta,
      'nombreRuta': nombreRuta,
      'sector': sector,
      'usuarioId': usuarioId,
      'nombreLecturista': nombreLecturista,
      'empleadoId': empleadoId,
      'periodoMes': periodoMes,
      'fechaProgramada': fechaProgramada?.toIso8601String(),
      'fechaInicio': fechaInicio?.toIso8601String(),
      'fechaCierre': fechaCierre?.toIso8601String(),
      'estado': estado,
      'totalPredios': totalPredios,
      'prediosLeidos': prediosLeidos,
      'prediosConNovedad': prediosConNovedad,
      'prediosPendientes': prediosPendientes,
      'porcentajeAvance': porcentajeAvance,
      'isDownloadedOffline': isDownloadedOffline,
      'pendingOfflineCount': pendingOfflineCount,
    };
  }
}
