// lib/features/dashboard/data/datasources/dashboard_remote_datasource.dart
import 'dart:convert';
import 'package:flutter_application/config/environments/environment.dart';
import 'package:flutter_application/core/error/exception.dart';
import 'package:flutter_application/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:http/http.dart' as http;

// ── Response Models (data layer only) ─────────────────────────────────────────

class DashboardMetricsDto {
  final int totalReadingsToday;
  final int pendingReadingsToday;
  final int readingsWithNoveltyToday;
  final double efficiencyPercentage;
  final List<Map<String, dynamic>> noveltyDistribution;

  const DashboardMetricsDto({
    required this.totalReadingsToday,
    required this.pendingReadingsToday,
    required this.readingsWithNoveltyToday,
    required this.efficiencyPercentage,
    required this.noveltyDistribution,
  });

  factory DashboardMetricsDto.fromJson(Map<String, dynamic> json) {
    return DashboardMetricsDto(
      totalReadingsToday: _parseInt(json['totalReadingsToday']),
      pendingReadingsToday: _parseInt(json['pendingReadingsToday']),
      readingsWithNoveltyToday: _parseInt(json['readingsWithNoveltyToday']),
      efficiencyPercentage: _parseDouble(json['efficiencyPercentage']),
      noveltyDistribution:
          (json['noveltyDistribution'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}

class AdvancedReadingReportDto {
  final int sector;
  final int totalConnections;
  final int readingsCompleted;
  final int missingReadings;
  final double progressPercentage;
  final int auditTotalEsperado;
  final int auditTotalCompletadas;
  final double auditAvancePorcentaje;
  final bool auditCompleto;

  const AdvancedReadingReportDto({
    required this.sector,
    required this.totalConnections,
    required this.readingsCompleted,
    required this.missingReadings,
    required this.progressPercentage,
    required this.auditTotalEsperado,
    required this.auditTotalCompletadas,
    required this.auditAvancePorcentaje,
    required this.auditCompleto,
  });

  factory AdvancedReadingReportDto.fromJson(Map<String, dynamic> json) {
    return AdvancedReadingReportDto(
      sector: _parseInt(json['sector']),
      totalConnections: _parseInt(json['totalConnections']),
      readingsCompleted: _parseInt(json['readingsCompleted']),
      missingReadings: _parseInt(json['missingReadings']),
      progressPercentage: _parseDouble(json['progressPercentage']),
      auditTotalEsperado: _parseInt(json['auditTotalEsperado']),
      auditTotalCompletadas: _parseInt(json['auditTotalCompletadas']),
      auditAvancePorcentaje: _parseDouble(json['auditAvancePorcentaje']),
      auditCompleto: _parseBool(json['auditCompleto']),
    );
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static bool _parseBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v != 0;
    return v.toString().toLowerCase() == 'true';
  }
}

// ── Abstract contract (ISP: interface per concern) ────────────────────────────

abstract class DashboardRemoteDataSource {
  Future<DashboardMetricsDto> getDashboardMetrics(String date);
  Future<List<AdvancedReadingReportDto>> getAdvancedMonthlyReport(String month);
}

// ── Concrete implementation ────────────────────────────────────────────────────

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  final String _base = Environment.apiUrl;

  DashboardRemoteDataSourceImpl({
    required this.client,
    required this.authLocalDataSource,
  });

  Future<Map<String, String>> _headers() async {
    final token = await authLocalDataSource.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode == 401) {
      throw ServerException('Sesión expirada. Por favor inicia sesión nuevamente.', 401);
    }
    if (response.statusCode >= 500) {
      throw ServerException('Error del servidor (${response.statusCode})');
    }
  }

  @override
  Future<DashboardMetricsDto> getDashboardMetrics(String date) async {
    final headers = await _headers();
    final uri = Uri.parse(
      '$_base/Readings-Report-Dashboard/report/dashboard?date=$date',
    );
    final response = await client.get(uri, headers: headers);
    _checkStatus(response);

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final statusCode = json['status_code'] as int? ?? response.statusCode;
    if (statusCode >= 400) {
      throw ServerException(
        (json['message'] as List?)?.join(', ') ?? 'Error al obtener métricas',
      );
    }

    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return DashboardMetricsDto.fromJson(data);
    }
    if (data is List && data.isNotEmpty) {
      return DashboardMetricsDto.fromJson(data.first as Map<String, dynamic>);
    }
    throw ServerException('Respuesta de dashboard inválida');
  }

  @override
  Future<List<AdvancedReadingReportDto>> getAdvancedMonthlyReport(
    String month,
  ) async {
    final headers = await _headers();
    final uri = Uri.parse(
      '$_base/Readings-Report-Dashboard/report/advanced-monthly/$month',
    );
    final response = await client.get(uri, headers: headers);
    _checkStatus(response);

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final statusCode = json['status_code'] as int? ?? response.statusCode;
    if (statusCode >= 400) {
      throw ServerException(
        (json['message'] as List?)?.join(', ') ?? 'Error al obtener reporte',
      );
    }

    final data = json['data'];
    if (data is List) {
      return data
          .map((e) => AdvancedReadingReportDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
