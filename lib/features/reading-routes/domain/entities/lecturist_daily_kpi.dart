import 'package:equatable/equatable.dart';

class LecturistDailyKpi extends Equatable {
  final String usuarioId;
  final String fecha;
  final int rutasAsignadas;
  final int totalPrediosAsignados;
  final int totalPrediosLeidos;
  final int totalNovedades;
  final int totalPendientes;
  final double porcentajeEfectividad;
  final String? horaPrimeraLectura;
  final String? horaUltimaLectura;

  const LecturistDailyKpi({
    required this.usuarioId,
    required this.fecha,
    required this.rutasAsignadas,
    required this.totalPrediosAsignados,
    required this.totalPrediosLeidos,
    required this.totalNovedades,
    required this.totalPendientes,
    required this.porcentajeEfectividad,
    this.horaPrimeraLectura,
    this.horaUltimaLectura,
  });

  factory LecturistDailyKpi.empty(String usuarioId, String fecha) {
    return LecturistDailyKpi(
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

  @override
  List<Object?> get props => [
    usuarioId,
    fecha,
    rutasAsignadas,
    totalPrediosAsignados,
    totalPrediosLeidos,
    totalNovedades,
    totalPendientes,
    porcentajeEfectividad,
    horaPrimeraLectura,
    horaUltimaLectura,
  ];
}
