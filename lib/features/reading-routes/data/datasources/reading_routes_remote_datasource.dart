import 'dart:convert';
import 'package:flutter_application/config/environments/environment.dart';
import 'package:flutter_application/core/error/exception.dart';
import 'package:flutter_application/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_application/features/reading-routes/data/models/lecturist_daily_kpi_model.dart';
import 'package:flutter_application/features/reading-routes/data/models/route_assignment_model.dart';
import 'package:flutter_application/features/reading-routes/data/models/route_work_pack_model.dart';
import 'package:flutter_application/features/reading-routes/data/models/sync_mobile_reading_model.dart';
import 'package:flutter_application/shared/api/response/api_response.dart';
import 'package:http/http.dart' as http;

abstract class ReadingRoutesRemoteDataSource {
  Future<List<RouteAssignmentModel>> getMyAssignedRoutes({
    String? periodoMes,
    String? fecha,
  });

  Future<List<RouteAssignmentModel>> getLiveTrackingAssignments({
    String? periodoMes,
    String? fecha,
  });

  Future<RouteWorkPackModel> getMobileWorkPack(int assignmentId);

  Future<SyncBatchResultModel> syncReadingsBatch(
    SyncMobileReadingsBatchRequestModel request,
  );

  Future<LecturistDailyKpiModel> getMyDailyKpi({String? fecha});

  Future<Map<String, dynamic>?> getRouteGeoJson({int? sectorId});
}

class ReadingRoutesRemoteDataSourceImpl implements ReadingRoutesRemoteDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  final String baseUrl = Environment.apiUrl;

  ReadingRoutesRemoteDataSourceImpl({
    required this.client,
    required this.authLocalDataSource,
  });

  Future<Map<String, String>> _getHeaders() async {
    final token = await authLocalDataSource.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<RouteAssignmentModel>> getMyAssignedRoutes({
    String? periodoMes,
    String? fecha,
  }) async {
    final headers = await _getHeaders();
    final queryParams = <String, String>{};
    if (periodoMes != null && periodoMes.isNotEmpty) {
      queryParams['periodo'] = periodoMes;
    }
    if (fecha != null && fecha.isNotEmpty) {
      queryParams['fecha'] = fecha;
    }

    final uri = Uri.parse('$baseUrl/mobile/reading-routes/my-routes')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await client.get(uri, headers: headers);

    if (response.statusCode == 401) {
      throw ServerException('Sesión expirada o no autorizada', 401);
    }

    if (response.statusCode >= 400) {
      throw ServerException(
        'Error al consultar mis rutas asignadas: ${response.statusCode}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = ApiResponse<dynamic>.fromJson(json, (d) => d);

    final rawData = apiResponse.data;
    if (rawData == null) return [];

    if (rawData is List) {
      return rawData
          .map((e) => RouteAssignmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (rawData is Map<String, dynamic>) {
      return [RouteAssignmentModel.fromJson(rawData)];
    }

    return [];
  }

  @override
  Future<List<RouteAssignmentModel>> getLiveTrackingAssignments({
    String? periodoMes,
    String? fecha,
  }) async {
    final headers = await _getHeaders();
    final queryParams = <String, String>{};
    if (periodoMes != null && periodoMes.isNotEmpty) {
      queryParams['periodo'] = periodoMes;
    }
    if (fecha != null && fecha.isNotEmpty) {
      queryParams['fecha'] = fecha;
    }

    final uri = Uri.parse('$baseUrl/route-assignments/live-tracking')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await client.get(uri, headers: headers);

    if (response.statusCode == 401) {
      throw ServerException('Sesión expirada o no autorizada', 401);
    }

    if (response.statusCode >= 400) {
      throw ServerException('Error al consultar asignaciones de ruta: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = ApiResponse<dynamic>.fromJson(json, (d) => d);

    final rawData = apiResponse.data;
    if (rawData == null) return [];

    if (rawData is List) {
      return rawData
          .map((e) => RouteAssignmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (rawData is Map<String, dynamic>) {
      return [RouteAssignmentModel.fromJson(rawData)];
    }

    return [];
  }

  @override
  Future<RouteWorkPackModel> getMobileWorkPack(int assignmentId) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/mobile/reading-routes/pack/$assignmentId');

    final response = await client.get(uri, headers: headers);

    if (response.statusCode == 401) {
      throw ServerException('Sesión expirada o no autorizada', 401);
    }

    if (response.statusCode == 404) {
      throw ServerException('Asignación de ruta $assignmentId no encontrada');
    }

    if (response.statusCode >= 400) {
      throw ServerException('Error al descargar paquete de ruta: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = ApiResponse<dynamic>.fromJson(json, (d) => d);

    final rawData = apiResponse.data;
    if (rawData == null || rawData is! Map<String, dynamic>) {
      throw ServerException('Formato de paquete de trabajo inválido recibido del servidor');
    }

    return RouteWorkPackModel.fromJson(rawData);
  }

  @override
  Future<SyncBatchResultModel> syncReadingsBatch(
    SyncMobileReadingsBatchRequestModel request,
  ) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/mobile/reading-routes/sync-batch');

    final response = await client.post(
      uri,
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 401) {
      throw ServerException('Sesión expirada o no autorizada', 401);
    }

    if (response.statusCode >= 400) {
      throw ServerException('Error al sincronizar lote de lecturas: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = ApiResponse<dynamic>.fromJson(json, (d) => d);

    final rawData = apiResponse.data;
    if (rawData is Map<String, dynamic>) {
      return SyncBatchResultModel.fromJson(rawData);
    }

    return SyncBatchResultModel(
      success: true,
      totalSincronizados: request.lecturas.length,
      totalExitosos: request.lecturas.length,
      totalFallidos: 0,
    );
  }

  @override
  Future<LecturistDailyKpiModel> getMyDailyKpi({String? fecha}) async {
    final headers = await _getHeaders();
    final queryParams = <String, String>{};
    if (fecha != null && fecha.isNotEmpty) {
      queryParams['fecha'] = fecha;
    }

    final uri = Uri.parse('$baseUrl/mobile/reading-routes/my-daily-kpi')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await client.get(uri, headers: headers);

    if (response.statusCode == 401) {
      throw ServerException('Sesión expirada o no autorizada', 401);
    }

    if (response.statusCode >= 400) {
      throw ServerException('Error al consultar KPI del lecturista: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = ApiResponse<dynamic>.fromJson(json, (d) => d);

    final rawData = apiResponse.data;
    if (rawData is Map<String, dynamic>) {
      return LecturistDailyKpiModel.fromJson(rawData);
    }

    return LecturistDailyKpiModel.empty('', fecha ?? '');
  }

  @override
  Future<Map<String, dynamic>?> getRouteGeoJson({int? sectorId}) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{};
      if (sectorId != null) {
        queryParams['sectorId'] = sectorId.toString();
      }
      queryParams['activa'] = 'true';

      final uri = Uri.parse('$baseUrl/reading-routes/geojson')
          .replace(queryParameters: queryParams);

      final response = await client.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final apiResponse = ApiResponse<dynamic>.fromJson(json, (d) => d);
        if (apiResponse.data is Map<String, dynamic>) {
          return apiResponse.data as Map<String, dynamic>;
        }
      }
    } catch (_) {}
    return null;
  }
}
