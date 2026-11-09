import 'package:flutter_application/features/reading-routes/domain/entities/route_connection_item.dart';

class RouteConnectionItemModel extends RouteConnectionItem {
  const RouteConnectionItemModel({
    required super.idDetalle,
    required super.acometidaId,
    required super.orden,
    super.cuenta,
    super.numeroMedidor,
    required super.abonado,
    required super.clienteId,
    super.direccion,
    super.referencia,
    super.latitud,
    super.longitud,
    super.ladoCalle,
    super.pisoDepartamento,
    super.instruccionAcceso,
    super.lecturaAnterior,
    super.consumoPromedio,
    required super.estado,
    super.lecturaActual,
    super.fechaHoraCaptura,
    super.novedadId,
    super.observaciones,
    super.isOfflinePending,
  });

  factory RouteConnectionItemModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    double? parseDoubleNullable(dynamic val) {
      if (val == null) return null;
      if (val is double) return val;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString());
    }

    return RouteConnectionItemModel(
      idDetalle: parseInt(json['idDetalle'] ?? json['id_detalle']),
      acometidaId: (json['acometidaId'] ?? json['acometida_id'] ?? '')
          .toString(),
      clienteId: (json['clienteId'] ??
              json['cliente_id'] ??
              json['clientId'] ??
              json['client_id'] ??
              json['cardId'] ??
              json['card_id'] ??
              json['cedula'] ??
              json['identificacion'] ??
              '')
          .toString(),
      orden: parseInt(json['orden'] ?? json['orden_secuencia']),
      cuenta: json['cuenta']?.toString(),
      numeroMedidor: (json['numeroMedidor'] ?? json['numero_medidor'])
          ?.toString(),
      abonado: (json['abonado'] ?? json['nombre_abonado'] ?? 'SIN NOMBRE')
          .toString(),
      direccion: json['direccion']?.toString(),
      referencia: json['referencia']?.toString(),
      latitud: parseDoubleNullable(json['latitud']),
      longitud: parseDoubleNullable(json['longitud']),
      ladoCalle: (json['ladoCalle'] ?? json['lado_calle'])?.toString(),
      pisoDepartamento: (json['pisoDepartamento'] ?? json['piso_departamento'])
          ?.toString(),
      instruccionAcceso:
          (json['instruccionAcceso'] ?? json['instruccion_acceso'])?.toString(),
      lecturaAnterior: parseDoubleNullable(
        json['lecturaAnterior'] ?? json['lectura_anterior'],
      ),
      consumoPromedio: parseDoubleNullable(
        json['consumoPromedio'] ?? json['consumo_promedio'],
      ),
      estado: (json['estado'] ?? json['estado_lectura'] ?? 'PENDIENTE')
          .toString(),
      lecturaActual: parseDoubleNullable(
        json['lecturaActual'] ?? json['lectura_actual'],
      ),
      fechaHoraCaptura: parseDate(
        json['fechaHoraCaptura'] ?? json['fecha_captura'],
      ),
      novedadId: (json['novedadId'] ?? json['novedad'])?.toString(),
      observaciones: json['observaciones']?.toString(),
      isOfflinePending: json['isOfflinePending'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idDetalle': idDetalle,
      'acometidaId': acometidaId,
      'orden': orden,
      'cuenta': cuenta,
      'numeroMedidor': numeroMedidor,
      'abonado': abonado,
      'clienteId': clienteId,
      'direccion': direccion,
      'referencia': referencia,
      'latitud': latitud,
      'longitud': longitud,
      'ladoCalle': ladoCalle,
      'pisoDepartamento': pisoDepartamento,
      'instruccionAcceso': instruccionAcceso,
      'lecturaAnterior': lecturaAnterior,
      'consumoPromedio': consumoPromedio,
      'estado': estado,
      'lecturaActual': lecturaActual,
      'fechaHoraCaptura': fechaHoraCaptura?.toIso8601String(),
      'novedadId': novedadId,
      'observaciones': observaciones,
      'isOfflinePending': isOfflinePending,
    };
  }

  factory RouteConnectionItemModel.fromEntity(RouteConnectionItem entity) {
    return RouteConnectionItemModel(
      idDetalle: entity.idDetalle,
      acometidaId: entity.acometidaId,
      orden: entity.orden,
      cuenta: entity.cuenta,
      numeroMedidor: entity.numeroMedidor,
      abonado: entity.abonado,
      clienteId: entity.clienteId,
      direccion: entity.direccion,
      referencia: entity.referencia,
      latitud: entity.latitud,
      longitud: entity.longitud,
      ladoCalle: entity.ladoCalle,
      pisoDepartamento: entity.pisoDepartamento,
      instruccionAcceso: entity.instruccionAcceso,
      lecturaAnterior: entity.lecturaAnterior,
      consumoPromedio: entity.consumoPromedio,
      estado: entity.estado,
      lecturaActual: entity.lecturaActual,
      fechaHoraCaptura: entity.fechaHoraCaptura,
      novedadId: entity.novedadId,
      observaciones: entity.observaciones,
      isOfflinePending: entity.isOfflinePending,
    );
  }
}
