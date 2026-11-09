import 'package:flutter_application/features/reading-routes/data/models/route_connection_item_model.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_work_pack.dart';

class RouteWorkPackModel extends RouteWorkPack {
  const RouteWorkPackModel({
    required super.idAsignacion,
    required super.periodo,
    required super.fechaProgramada,
    required super.estadoAsignacion,
    required super.totalPredios,
    required super.prediosLeidos,
    required super.prediosConNovedad,
    required super.prediosPendientes,
    required super.porcentajeAvance,
    required super.idRuta,
    required super.codigoRuta,
    required super.nombreRuta,
    required super.acometidas,
    super.isOffline,
  });

  factory RouteWorkPackModel.fromJson(Map<String, dynamic> json) {
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

    List<RouteConnectionItemModel> acometidasList = [];
    final rawAcometidas = json['acometidas'];
    if (rawAcometidas is List) {
      acometidasList = rawAcometidas
          .map((item) => RouteConnectionItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return RouteWorkPackModel(
      idAsignacion: parseInt(json['idAsignacion'] ?? json['id_asignacion']),
      periodo: (json['periodo'] ?? json['periodo_mes'] ?? '').toString(),
      fechaProgramada: (json['fechaProgramada'] ?? json['fecha_programada'] ?? '').toString(),
      estadoAsignacion: (json['estadoAsignacion'] ?? json['estado'] ?? 'ASIGNADA').toString(),
      totalPredios: parseInt(json['totalPredios'] ?? json['lecturas_esperadas']),
      prediosLeidos: parseInt(json['prediosLeidos'] ?? json['lecturas_completadas']),
      prediosConNovedad: parseInt(json['prediosConNovedad'] ?? json['lecturas_novedad']),
      prediosPendientes: parseInt(json['prediosPendientes'] ?? json['lecturas_pendientes']),
      porcentajeAvance: parseDouble(json['porcentajeAvance'] ?? json['porcentaje_avance']),
      idRuta: parseInt(json['idRuta'] ?? json['ruta_id']),
      codigoRuta: (json['codigoRuta'] ?? json['codigo_ruta'] ?? '').toString(),
      nombreRuta: (json['nombreRuta'] ?? json['nombre_ruta'] ?? '').toString(),
      acometidas: acometidasList,
      isOffline: json['isOffline'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idAsignacion': idAsignacion,
      'periodo': periodo,
      'fechaProgramada': fechaProgramada,
      'estadoAsignacion': estadoAsignacion,
      'totalPredios': totalPredios,
      'prediosLeidos': prediosLeidos,
      'prediosConNovedad': prediosConNovedad,
      'prediosPendientes': prediosPendientes,
      'porcentajeAvance': porcentajeAvance,
      'idRuta': idRuta,
      'codigoRuta': codigoRuta,
      'nombreRuta': nombreRuta,
      'acometidas': acometidas
          .map((a) => RouteConnectionItemModel.fromEntity(a).toJson())
          .toList(),
      'isOffline': isOffline,
    };
  }

  factory RouteWorkPackModel.fromEntity(RouteWorkPack entity) {
    return RouteWorkPackModel(
      idAsignacion: entity.idAsignacion,
      periodo: entity.periodo,
      fechaProgramada: entity.fechaProgramada,
      estadoAsignacion: entity.estadoAsignacion,
      totalPredios: entity.totalPredios,
      prediosLeidos: entity.prediosLeidos,
      prediosConNovedad: entity.prediosConNovedad,
      prediosPendientes: entity.prediosPendientes,
      porcentajeAvance: entity.porcentajeAvance,
      idRuta: entity.idRuta,
      codigoRuta: entity.codigoRuta,
      nombreRuta: entity.nombreRuta,
      acometidas: entity.acometidas,
      isOffline: entity.isOffline,
    );
  }
}
