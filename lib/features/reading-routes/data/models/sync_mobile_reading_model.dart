import 'package:flutter_application/features/reading-routes/domain/entities/offline_reading.dart';

class SyncMobileReadingItemModel {
  final int idDetalleAvance;
  final String acometidaId;
  final double lecturaActual;
  final String fechaHoraCaptura; // ISO-8601
  final double? latitudGps;
  final double? longitudGps;
  final String? novedadId;
  final String? fotoEvidenciaUrl;
  final String? observaciones;

  const SyncMobileReadingItemModel({
    required this.idDetalleAvance,
    required this.acometidaId,
    required this.lecturaActual,
    required this.fechaHoraCaptura,
    this.latitudGps,
    this.longitudGps,
    this.novedadId,
    this.fotoEvidenciaUrl,
    this.observaciones,
  });

  factory SyncMobileReadingItemModel.fromEntity(OfflineReading entity) {
    return SyncMobileReadingItemModel(
      idDetalleAvance: entity.idDetalleAvance,
      acometidaId: entity.acometidaId,
      lecturaActual: entity.lecturaActual,
      fechaHoraCaptura: entity.fechaHoraCaptura.toUtc().toIso8601String(),
      latitudGps: entity.latitudGps,
      longitudGps: entity.longitudGps,
      novedadId: entity.novedadId,
      fotoEvidenciaUrl: entity.fotoEvidenciaUrl,
      observaciones: entity.observaciones,
    );
  }

  factory SyncMobileReadingItemModel.fromJson(Map<String, dynamic> json) {
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

    double? parseDoubleNullable(dynamic val) {
      if (val == null) return null;
      if (val is double) return val;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    return SyncMobileReadingItemModel(
      idDetalleAvance: parseInt(json['idDetalleAvance'] ?? json['id_detalle']),
      acometidaId: (json['acometidaId'] ?? '').toString(),
      lecturaActual: parseDouble(json['lecturaActual']),
      fechaHoraCaptura: (json['fechaHoraCaptura'] ?? DateTime.now().toIso8601String()).toString(),
      latitudGps: parseDoubleNullable(json['latitudGps']),
      longitudGps: parseDoubleNullable(json['longitudGps']),
      novedadId: json['novedadId']?.toString(),
      fotoEvidenciaUrl: json['fotoEvidenciaUrl']?.toString(),
      observaciones: json['observaciones']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idDetalleAvance': idDetalleAvance,
      'acometidaId': acometidaId,
      'lecturaActual': lecturaActual,
      'fechaHoraCaptura': fechaHoraCaptura,
      if (latitudGps != null) 'latitudGps': latitudGps,
      if (longitudGps != null) 'longitudGps': longitudGps,
      if (novedadId != null && novedadId!.isNotEmpty) 'novedadId': novedadId,
      if (fotoEvidenciaUrl != null) 'fotoEvidenciaUrl': fotoEvidenciaUrl,
      if (observaciones != null && observaciones!.isNotEmpty) 'observaciones': observaciones,
    };
  }
}

class SyncMobileReadingsBatchRequestModel {
  final int asignacionId;
  final List<SyncMobileReadingItemModel> lecturas;

  const SyncMobileReadingsBatchRequestModel({
    required this.asignacionId,
    required this.lecturas,
  });

  Map<String, dynamic> toJson() {
    return {
      'asignacionId': asignacionId,
      'lecturas': lecturas.map((e) => e.toJson()).toList(),
    };
  }
}

class SyncBatchResultModel extends SyncBatchResult {
  const SyncBatchResultModel({
    required super.success,
    required super.totalSincronizados,
    required super.totalExitosos,
    required super.totalFallidos,
    super.errores,
  });

  factory SyncBatchResultModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    List<String> parseErrors(dynamic val) {
      if (val == null) return [];
      if (val is List) {
        return val.map((e) {
          if (e is Map) return '${e['acometidaId'] ?? ''}: ${e['error'] ?? ''}';
          return e.toString();
        }).toList();
      }
      return [val.toString()];
    }

    return SyncBatchResultModel(
      success: json['success'] == true,
      totalSincronizados: parseInt(json['totalSincronizados'] ?? json['total_sincronizados']),
      totalExitosos: parseInt(json['totalExitosos'] ?? json['total_exitosos']),
      totalFallidos: parseInt(json['totalFallidos'] ?? json['total_fallidos']),
      errores: parseErrors(json['errores'] ?? json['errors']),
    );
  }
}
