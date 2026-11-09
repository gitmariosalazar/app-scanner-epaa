import 'package:flutter_application/features/reading-routes/domain/entities/lecturist_daily_kpi.dart';

class LecturistDailyKpiModel extends LecturistDailyKpi {
  const LecturistDailyKpiModel({
    required super.usuarioId,
    required super.fecha,
    required super.rutasAsignadas,
    required super.totalPrediosAsignados,
    required super.totalPrediosLeidos,
    required super.totalNovedades,
    required super.totalPendientes,
    required super.porcentajeEfectividad,
    super.horaPrimeraLectura,
    super.horaUltimaLectura,
  });

  factory LecturistDailyKpiModel.empty(String usuarioId, String fecha) {
    return LecturistDailyKpiModel(
      usuarioId: usuarioId,
      fecha: fecha,
      rutasAsignadas: 0,
      totalPrediosAsignados: 0,
      totalPrediosLeidos: 0,
      totalNovedades: 0,
      totalPendientes: 0,
      porcentajeEfectividad: 0.0,
      horaPrimeraLectura: null,
      horaUltimaLectura: null,
    );
  }

  factory LecturistDailyKpiModel.fromJson(Map<String, dynamic> json) {
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

    return LecturistDailyKpiModel(
      usuarioId: (json['usuarioId'] ?? json['usuario_id'] ?? '').toString(),
      fecha: (json['fecha'] ?? '').toString(),
      rutasAsignadas: parseInt(json['rutasAsignadas'] ?? json['rutas_asignadas']),
      totalPrediosAsignados: parseInt(json['totalPrediosAsignados'] ?? json['total_predios_asignados']),
      totalPrediosLeidos: parseInt(json['totalPrediosLeidos'] ?? json['total_predios_leidos']),
      totalNovedades: parseInt(json['totalNovedades'] ?? json['total_novedades']),
      totalPendientes: parseInt(json['totalPendientes'] ?? json['total_pendientes']),
      porcentajeEfectividad: parseDouble(json['porcentajeEfectividad'] ?? json['porcentaje_efectividad']),
      horaPrimeraLectura: json['horaPrimeraLectura']?.toString(),
      horaUltimaLectura: json['horaUltimaLectura']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'fecha': fecha,
      'rutasAsignadas': rutasAsignadas,
      'totalPrediosAsignados': totalPrediosAsignados,
      'totalPrediosLeidos': totalPrediosLeidos,
      'totalNovedades': totalNovedades,
      'totalPendientes': totalPendientes,
      'porcentajeEfectividad': porcentajeEfectividad,
      'horaPrimeraLectura': horaPrimeraLectura,
      'horaUltimaLectura': horaUltimaLectura,
    };
  }
}
