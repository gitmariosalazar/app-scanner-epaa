import 'package:equatable/equatable.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_connection_item.dart';

class RouteWorkPack extends Equatable {
  final int idAsignacion;
  final String periodo;
  final String fechaProgramada;
  final String estadoAsignacion;
  final int totalPredios;
  final int prediosLeidos;
  final int prediosConNovedad;
  final int prediosPendientes;
  final double porcentajeAvance;
  final int idRuta;
  final String codigoRuta;
  final String nombreRuta;
  final List<RouteConnectionItem> acometidas;
  final bool isOffline;

  const RouteWorkPack({
    required this.idAsignacion,
    required this.periodo,
    required this.fechaProgramada,
    required this.estadoAsignacion,
    required this.totalPredios,
    required this.prediosLeidos,
    required this.prediosConNovedad,
    required this.prediosPendientes,
    required this.porcentajeAvance,
    required this.idRuta,
    required this.codigoRuta,
    required this.nombreRuta,
    required this.acometidas,
    this.isOffline = false,
  });

  RouteConnectionItem? get nextPendingInSequence {
    for (final item in acometidas) {
      if (item.estado == 'PENDIENTE' || item.estado == 'SALTADA') {
        return item;
      }
    }
    return null;
  }

  int get pendingOfflineReadingsCount {
    return acometidas.where((a) => a.isOfflinePending).length;
  }

  RouteWorkPack copyWith({
    int? idAsignacion,
    String? periodo,
    String? fechaProgramada,
    String? estadoAsignacion,
    int? totalPredios,
    int? prediosLeidos,
    int? prediosConNovedad,
    int? prediosPendientes,
    double? porcentajeAvance,
    int? idRuta,
    String? codigoRuta,
    String? nombreRuta,
    List<RouteConnectionItem>? acometidas,
    bool? isOffline,
  }) {
    return RouteWorkPack(
      idAsignacion: idAsignacion ?? this.idAsignacion,
      periodo: periodo ?? this.periodo,
      fechaProgramada: fechaProgramada ?? this.fechaProgramada,
      estadoAsignacion: estadoAsignacion ?? this.estadoAsignacion,
      totalPredios: totalPredios ?? this.totalPredios,
      prediosLeidos: prediosLeidos ?? this.prediosLeidos,
      prediosConNovedad: prediosConNovedad ?? this.prediosConNovedad,
      prediosPendientes: prediosPendientes ?? this.prediosPendientes,
      porcentajeAvance: porcentajeAvance ?? this.porcentajeAvance,
      idRuta: idRuta ?? this.idRuta,
      codigoRuta: codigoRuta ?? this.codigoRuta,
      nombreRuta: nombreRuta ?? this.nombreRuta,
      acometidas: acometidas ?? this.acometidas,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [
    idAsignacion,
    periodo,
    fechaProgramada,
    estadoAsignacion,
    totalPredios,
    prediosLeidos,
    prediosConNovedad,
    prediosPendientes,
    porcentajeAvance,
    idRuta,
    codigoRuta,
    nombreRuta,
    acometidas,
    isOffline,
  ];
}
