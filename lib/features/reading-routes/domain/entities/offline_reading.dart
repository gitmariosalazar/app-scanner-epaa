import 'package:equatable/equatable.dart';

class OfflineReading extends Equatable {
  final int idDetalleAvance;
  final String acometidaId;
  final double lecturaActual;
  final DateTime fechaHoraCaptura;
  final double? latitudGps;
  final double? longitudGps;
  final String? novedadId;
  final String? fotoEvidenciaUrl;
  final String? observaciones;
  final int asignacionId;

  const OfflineReading({
    required this.idDetalleAvance,
    required this.acometidaId,
    required this.lecturaActual,
    required this.fechaHoraCaptura,
    this.latitudGps,
    this.longitudGps,
    this.novedadId,
    this.fotoEvidenciaUrl,
    this.observaciones,
    required this.asignacionId,
  });

  @override
  List<Object?> get props => [
    idDetalleAvance,
    acometidaId,
    lecturaActual,
    fechaHoraCaptura,
    latitudGps,
    longitudGps,
    novedadId,
    fotoEvidenciaUrl,
    observaciones,
    asignacionId,
  ];
}

class SyncBatchResult extends Equatable {
  final bool success;
  final int totalSincronizados;
  final int totalExitosos;
  final int totalFallidos;
  final List<String> errores;

  const SyncBatchResult({
    required this.success,
    required this.totalSincronizados,
    required this.totalExitosos,
    required this.totalFallidos,
    this.errores = const [],
  });

  @override
  List<Object?> get props => [
    success,
    totalSincronizados,
    totalExitosos,
    totalFallidos,
    errores,
  ];
}
