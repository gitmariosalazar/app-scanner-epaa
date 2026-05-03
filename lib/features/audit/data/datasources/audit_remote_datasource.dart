// lib/features/audit/data/datasources/audit_remote_datasource.dart
import 'dart:convert';
import 'package:flutter_application/config/environments/environment.dart';
import 'package:flutter_application/core/error/exception.dart';
import 'package:flutter_application/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:http/http.dart' as http;

/// DTO — lives only in the data layer.
class AuditSectorDto {
  final int auditId;
  final String readingMonth;
  final int sectorId;
  final int expectedTotal;
  final int completedTotal;
  final int pendingTotal;
  final double progressPercentage;
  final bool isComplete;
  final String? closureDate;
  final String? supervisorId;
  final String? observations;
  final String createdAt;
  final String updatedAt;

  const AuditSectorDto({
    required this.auditId,
    required this.readingMonth,
    required this.sectorId,
    required this.expectedTotal,
    required this.completedTotal,
    required this.pendingTotal,
    required this.progressPercentage,
    required this.isComplete,
    this.closureDate,
    this.supervisorId,
    this.observations,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AuditSectorDto.fromJson(Map<String, dynamic> json) {
    return AuditSectorDto(
      auditId: _parseInt(json['auditId']),
      readingMonth: json['readingMonth']?.toString() ?? '',
      sectorId: _parseInt(json['sectorId']),
      expectedTotal: _parseInt(json['expectedTotal']),
      completedTotal: _parseInt(json['completedTotal']),
      pendingTotal: _parseInt(json['pendingTotal']),
      progressPercentage: _parseDouble(json['progressPercentage']),
      isComplete: _parseBool(json['isComplete']),
      closureDate: json['closureDate']?.toString(),
      supervisorId: json['supervisorId']?.toString(),
      observations: json['observations']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  // Safe helpers — package-private so CloseAuditSectorDto can reuse them.
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

/// DTO returned by POST /readings/audit/close/:sector/:month
class CloseAuditSectorDto {
  final int auditId;
  final int sectorId;
  final String readingMonth;
  final bool isComplete;
  final String? closureDate;
  final String? supervisorId;
  final String? observations;

  const CloseAuditSectorDto({
    required this.auditId,
    required this.sectorId,
    required this.readingMonth,
    required this.isComplete,
    this.closureDate,
    this.supervisorId,
    this.observations,
  });

  factory CloseAuditSectorDto.fromJson(Map<String, dynamic> json) {
    // Backend wraps response in a 'data' key; handle both cases defensively.
    final d =
        (json['data'] is Map<String, dynamic>)
            ? json['data'] as Map<String, dynamic>
            : json;
    return CloseAuditSectorDto(
      auditId: AuditSectorDto._parseInt(d['auditId']),
      sectorId: AuditSectorDto._parseInt(d['sectorId']),
      readingMonth: d['readingMonth']?.toString() ?? '',
      isComplete: AuditSectorDto._parseBool(d['isComplete']),
      closureDate: d['closureDate']?.toString(),
      supervisorId: d['supervisorId']?.toString(),
      observations: d['observations']?.toString(),
    );
  }
}

// ── Abstract contract (ISP / DIP) ─────────────────────────────────────────────

abstract class AuditRemoteDataSource {
  Future<List<AuditSectorDto>> getAuditByMonth(String month);

  /// Supervised closure: POST /readings/audit/close/:sector/:month
  Future<CloseAuditSectorDto> closeSector({
    required int sectorId,
    required String month,
    required String supervisorId,
    String? observations,
  });
}

// ── Concrete implementation ───────────────────────────────────────────────────

class AuditRemoteDataSourceImpl implements AuditRemoteDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  final String _base = Environment.apiUrl;

  AuditRemoteDataSourceImpl({
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

  @override
  Future<List<AuditSectorDto>> getAuditByMonth(String month) async {
    final headers = await _headers();
    final uri = Uri.parse('$_base/readings/audit/by-month/$month');
    final response = await client.get(uri, headers: headers);

    _checkHttpStatus(response.statusCode);

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final statusCode = json['status_code'] as int? ?? response.statusCode;
    if (statusCode >= 400) {
      throw ServerException(
        (json['message'] as List?)?.join(', ') ?? 'Error al obtener auditoría',
      );
    }

    final data = json['data'];
    if (data is List) {
      return data
          .map((e) => AuditSectorDto.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<CloseAuditSectorDto> closeSector({
    required int sectorId,
    required String month,
    required String supervisorId,
    String? observations,
  }) async {
    final headers = await _headers();
    final uri = Uri.parse('$_base/readings/audit/close/$sectorId/$month');
    final body = jsonEncode({
      'supervisorId': supervisorId,
      if (observations != null && observations.isNotEmpty)
        'observaciones': observations,
    });

    final response = await client.post(uri, headers: headers, body: body);
    _checkHttpStatus(response.statusCode);

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final statusCode = json['status_code'] as int? ?? response.statusCode;
    if (statusCode >= 400) {
      throw ServerException(
        (json['message'] as List?)?.join(', ') ??
            'Error al cerrar sector de auditoría',
      );
    }

    return CloseAuditSectorDto.fromJson(json);
  }

  /// Shared HTTP-status guard — DRY.
  void _checkHttpStatus(int code) {
    if (code == 401) throw ServerException('Sesión expirada.', 401);
    if (code >= 500) throw ServerException('Error del servidor ($code)');
  }
}
