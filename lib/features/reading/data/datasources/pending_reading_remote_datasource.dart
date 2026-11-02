// lib/features/reading/data/datasources/pending_reading_remote_datasource.dart
import 'dart:convert';
import 'package:flutter_application/config/environments/environment.dart';
import 'package:flutter_application/core/error/exception.dart';
import 'package:flutter_application/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_application/features/reading/data/model/pending_reading_connection_model.dart';
import 'package:flutter_application/shared/api/response/api_response.dart';
import 'package:http/http.dart' as http;

abstract class PendingReadingRemoteDataSource {
  /// Consulta las acometidas pendientes de lectura por mes (YYYY-MM), sector opcional
  /// y coordenadas opcionales para ordenar por proximidad.
  Future<List<PendingReadingConnectionModel>> getPendingReadingsByMonth(
    String month, {
    int? sector,
    double? lat,
    double? lng,
  });
}

class PendingReadingRemoteDataSourceImpl
    implements PendingReadingRemoteDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  final String baseUrl = Environment.apiUrl;

  PendingReadingRemoteDataSourceImpl({
    required this.client,
    required this.authLocalDataSource,
  });

  Future<Map<String, String>> _getHeaders() async {
    final token = await authLocalDataSource.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<PendingReadingConnectionModel>> getPendingReadingsByMonth(
    String month, {
    int? sector,
    double? lat,
    double? lng,
  }) async {
    return await guardNetwork(() async {
      final headers = await _getHeaders();

      // Construcción del path
      final sectorSegment = sector != null ? '/$sector' : '';
      final path =
          '/Readings/get-pending-readings-by-month/$month$sectorSegment';

      // Parámetros de query para la ubicación
      final queryParams = <String, String>{};
      if (lat != null && lng != null) {
        queryParams['lat'] = lat.toString();
        queryParams['lng'] = lng.toString();
      }

      // Se usa replace para añadir los queryParameters de forma segura
      final uri = Uri.parse(
        '$baseUrl$path',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await client.get(uri, headers: headers);

      if (response.statusCode == 401) {
        throw ServerException('Sesión expirada o no autorizada', 401);
      }

      if (response.body.isEmpty) {
        return <PendingReadingConnectionModel>[];
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw ServerException('Formato de respuesta inválido del servidor');
      }

      final json = decoded;

      // Usar ApiResponse compartido si está presente la envoltura estándar
      if (json.containsKey('data')) {
        final apiResponse = ApiResponse<dynamic>.fromJson(json, (data) => data);

        if (apiResponse.statusCode >= 400) {
          final errorMsg = apiResponse.message.isNotEmpty
              ? apiResponse.message.join(', ')
              : 'Error al consultar lecturas pendientes';
          throw ServerException(errorMsg, apiResponse.statusCode);
        }

        final rawData = apiResponse.data;
        if (rawData == null) {
          return <PendingReadingConnectionModel>[];
        }

        if (rawData is List) {
          return rawData
              .whereType<Map<String, dynamic>>()
              .map((item) => PendingReadingConnectionModel.fromJson(item))
              .toList();
        } else if (rawData is Map<String, dynamic>) {
          return [PendingReadingConnectionModel.fromJson(rawData)];
        }
      }

      // Si la lista viene directamente o en otra clave
      if (json['data'] is List) {
        final list = json['data'] as List;
        return list
            .whereType<Map<String, dynamic>>()
            .map((item) => PendingReadingConnectionModel.fromJson(item))
            .toList();
      }

      return <PendingReadingConnectionModel>[];
    });
  }
}
