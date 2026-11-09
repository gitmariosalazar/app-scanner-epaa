import 'package:equatable/equatable.dart';

class RouteConnectionItem extends Equatable {
  final int idDetalle;
  final String acometidaId;
  final int orden;
  final String? cuenta;
  final String? numeroMedidor;
  final String abonado;
  final String clienteId;
  final String? direccion;
  final String? referencia;
  final double? latitud;
  final double? longitud;
  final String? ladoCalle;
  final String? pisoDepartamento;
  final String? instruccionAcceso;
  final double? lecturaAnterior;
  final double? consumoPromedio;
  final String estado; // 'PENDIENTE', 'LEIDA', 'NOVEDAD', 'OMITIDA', 'SALTADA'
  final double? lecturaActual;
  final DateTime? fechaHoraCaptura;
  final String? novedadId;
  final String? observaciones;
  final bool isOfflinePending;

  const RouteConnectionItem({
    required this.idDetalle,
    required this.acometidaId,
    required this.orden,
    this.cuenta,
    this.numeroMedidor,
    required this.abonado,
    required this.clienteId,
    this.direccion,
    this.referencia,
    this.latitud,
    this.longitud,
    this.ladoCalle,
    this.pisoDepartamento,
    this.instruccionAcceso,
    this.lecturaAnterior,
    this.consumoPromedio,
    required this.estado,
    this.lecturaActual,
    this.fechaHoraCaptura,
    this.novedadId,
    this.observaciones,
    this.isOfflinePending = false,
  });

  bool get isCompleted => estado == 'LEIDA' || estado == 'NOVEDAD';
  bool get hasCoordinates =>
      latitud != null &&
      longitud != null &&
      latitud! != 0.0 &&
      longitud! != 0.0;

  RouteConnectionItem copyWith({
    int? idDetalle,
    String? acometidaId,
    int? orden,
    String? cuenta,
    String? numeroMedidor,
    String? abonado,
    String? clienteId,
    String? direccion,
    String? referencia,
    double? latitud,
    double? longitud,
    String? ladoCalle,
    String? pisoDepartamento,
    String? instruccionAcceso,
    double? lecturaAnterior,
    double? consumoPromedio,
    String? estado,
    double? lecturaActual,
    DateTime? fechaHoraCaptura,
    String? novedadId,
    String? observaciones,
    bool? isOfflinePending,
  }) {
    return RouteConnectionItem(
      idDetalle: idDetalle ?? this.idDetalle,
      acometidaId: acometidaId ?? this.acometidaId,
      orden: orden ?? this.orden,
      cuenta: cuenta ?? this.cuenta,
      numeroMedidor: numeroMedidor ?? this.numeroMedidor,
      abonado: abonado ?? this.abonado,
      clienteId: clienteId ?? this.clienteId,
      direccion: direccion ?? this.direccion,
      referencia: referencia ?? this.referencia,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      ladoCalle: ladoCalle ?? this.ladoCalle,
      pisoDepartamento: pisoDepartamento ?? this.pisoDepartamento,
      instruccionAcceso: instruccionAcceso ?? this.instruccionAcceso,
      lecturaAnterior: lecturaAnterior ?? this.lecturaAnterior,
      consumoPromedio: consumoPromedio ?? this.consumoPromedio,
      estado: estado ?? this.estado,
      lecturaActual: lecturaActual ?? this.lecturaActual,
      fechaHoraCaptura: fechaHoraCaptura ?? this.fechaHoraCaptura,
      novedadId: novedadId ?? this.novedadId,
      observaciones: observaciones ?? this.observaciones,
      isOfflinePending: isOfflinePending ?? this.isOfflinePending,
    );
  }

  @override
  List<Object?> get props => [
    idDetalle,
    acometidaId,
    orden,
    cuenta,
    numeroMedidor,
    abonado,
    clienteId,
    direccion,
    referencia,
    latitud,
    longitud,
    ladoCalle,
    pisoDepartamento,
    instruccionAcceso,
    lecturaAnterior,
    consumoPromedio,
    estado,
    lecturaActual,
    fechaHoraCaptura,
    novedadId,
    observaciones,
    isOfflinePending,
  ];
}
