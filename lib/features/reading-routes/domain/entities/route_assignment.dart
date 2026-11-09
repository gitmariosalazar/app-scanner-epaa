import 'package:equatable/equatable.dart';

class RouteAssignment extends Equatable {
  final int idAsignacion;
  final int rutaId;
  final String codigoRuta;
  final String nombreRuta;
  final int sector;
  final String usuarioId;
  final String nombreLecturista;
  final String empleadoId;
  final String periodoMes;
  final DateTime? fechaProgramada;
  final DateTime? fechaInicio;
  final DateTime? fechaCierre;
  final String
  estado; // 'ASIGNADA', 'EN_PROCESO', 'PAUSADA', 'COMPLETADA', 'REASIGNADA'
  final int totalPredios;
  final int prediosLeidos;
  final int prediosConNovedad;
  final int prediosPendientes;
  final double porcentajeAvance;
  final bool isDownloadedOffline;
  final int pendingOfflineCount;

  const RouteAssignment({
    required this.idAsignacion,
    required this.rutaId,
    required this.codigoRuta,
    required this.nombreRuta,
    required this.sector,
    required this.usuarioId,
    required this.nombreLecturista,
    required this.empleadoId,
    required this.periodoMes,
    this.fechaProgramada,
    this.fechaInicio,
    this.fechaCierre,
    required this.estado,
    required this.totalPredios,
    required this.prediosLeidos,
    required this.prediosConNovedad,
    required this.prediosPendientes,
    required this.porcentajeAvance,
    this.isDownloadedOffline = false,
    this.pendingOfflineCount = 0,
  });

  RouteAssignment copyWith({
    int? idAsignacion,
    int? rutaId,
    String? codigoRuta,
    String? nombreRuta,
    int? sector,
    String? usuarioId,
    String? nombreLecturista,
    String? empleadoId,
    String? periodoMes,
    DateTime? fechaProgramada,
    DateTime? fechaInicio,
    DateTime? fechaCierre,
    String? estado,
    int? totalPredios,
    int? prediosLeidos,
    int? prediosConNovedad,
    int? prediosPendientes,
    double? porcentajeAvance,
    bool? isDownloadedOffline,
    int? pendingOfflineCount,
  }) {
    return RouteAssignment(
      idAsignacion: idAsignacion ?? this.idAsignacion,
      rutaId: rutaId ?? this.rutaId,
      codigoRuta: codigoRuta ?? this.codigoRuta,
      nombreRuta: nombreRuta ?? this.nombreRuta,
      sector: sector ?? this.sector,
      usuarioId: usuarioId ?? this.usuarioId,
      nombreLecturista: nombreLecturista ?? this.nombreLecturista,
      empleadoId: empleadoId ?? this.empleadoId,
      periodoMes: periodoMes ?? this.periodoMes,
      fechaProgramada: fechaProgramada ?? this.fechaProgramada,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaCierre: fechaCierre ?? this.fechaCierre,
      estado: estado ?? this.estado,
      totalPredios: totalPredios ?? this.totalPredios,
      prediosLeidos: prediosLeidos ?? this.prediosLeidos,
      prediosConNovedad: prediosConNovedad ?? this.prediosConNovedad,
      prediosPendientes: prediosPendientes ?? this.prediosPendientes,
      porcentajeAvance: porcentajeAvance ?? this.porcentajeAvance,
      isDownloadedOffline: isDownloadedOffline ?? this.isDownloadedOffline,
      pendingOfflineCount: pendingOfflineCount ?? this.pendingOfflineCount,
    );
  }

  @override
  List<Object?> get props => [
    idAsignacion,
    rutaId,
    codigoRuta,
    nombreRuta,
    sector,
    usuarioId,
    nombreLecturista,
    empleadoId,
    periodoMes,
    fechaProgramada,
    fechaInicio,
    fechaCierre,
    estado,
    totalPredios,
    prediosLeidos,
    prediosConNovedad,
    prediosPendientes,
    porcentajeAvance,
    isDownloadedOffline,
    pendingOfflineCount,
  ];
}
