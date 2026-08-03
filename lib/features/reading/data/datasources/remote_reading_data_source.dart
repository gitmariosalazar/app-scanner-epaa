// lib/features/scan/data/datasources/remote_reading_data_source.dart
import 'dart:convert';
import 'package:flutter_application/config/environments/environment.dart';
import 'package:flutter_application/core/error/exception.dart';
import 'package:flutter_application/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_application/features/reading/data/model/create_reading_request.dart';
import 'package:flutter_application/features/reading/data/model/reading_basic_info_response.dart';
import 'package:flutter_application/features/reading/data/model/reading_info_response.dart';
import 'package:flutter_application/features/reading/data/model/reading_response.dart';
import 'package:flutter_application/features/reading/data/model/update_reading_request.dart';
import 'package:flutter_application/shared/api/response/api_response.dart';
import 'package:http/http.dart' as http;

abstract class RemoteReadingDataSource {
  Future<List<ReadingInfoResponse>> getReadingInfo(String cadastralKey);
  Future<List<ReadingBasicInfoResponse>> findBasicReading(String catastralCode);
  Future<ReadingResponse> updateCurrentReading(
    String readingId,
    UpdateReadingRequest request,
  );
  Future<ReadingResponse> createReading(CreateReadingRequest request);
}

class RemoteReadingDataSourceImpl implements RemoteReadingDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  final String baseUrl = Environment.apiUrl;

  RemoteReadingDataSourceImpl(this.client, this.authLocalDataSource);

  Future<Map<String, String>> _getHeaders() async {
    final token = await authLocalDataSource.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<ReadingInfoResponse>> getReadingInfo(String cadastralKey) async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('$baseUrl/Readings/find-reading-info/$cadastralKey'),
      headers: headers,
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (json["status_code"] == 404) {
      throw ServerException(
        'No se encontró lectura para la clave catastral: $cadastralKey',
      );
    }

    // Check for 401 Unauthorized
    if (response.statusCode == 401) {
      throw ServerException('Unauthorized: Please login again', 401);
    }

    if (json.isEmpty) {
      throw ServerException('Respuesta vacía del servidor');
    }

    final apiResponse = ApiResponse<dynamic>.fromJson(
      json,
      (data) => data,
    );

    if (apiResponse.statusCode >= 400) {
      throw ServerException(apiResponse.message.join(', '));
    }

    final rawData = apiResponse.data;
    if (rawData == null) {
      throw ServerException('No se encontró lectura para $cadastralKey');
    }

    List<ReadingInfoResponse> results = [];
    if (rawData is List) {
      results = rawData
          .map((e) => ReadingInfoResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (rawData is Map<String, dynamic>) {
      results = [ReadingInfoResponse.fromJson(rawData)];
    } else {
      throw ServerException('Formato de datos de lectura desconocido');
    }

    if (results.isEmpty) {
      throw ServerException('No se encontró lectura para $cadastralKey');
    }
    return results;
  }

  @override
  Future<List<ReadingBasicInfoResponse>> findBasicReading(
    String catastralCode,
  ) async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('$baseUrl/Readings/find-basic-reading/$catastralCode'),
      headers: headers,
    );

    if (response.statusCode == 401) {
      throw ServerException('Unauthorized: Please login again', 401);
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = ApiResponse<dynamic>.fromJson(
      json,
      (data) => data,
    );

    if (apiResponse.statusCode >= 400) {
      throw ServerException(apiResponse.message.join(', '));
    }

    final rawData = apiResponse.data;
    if (rawData == null) {
      return [];
    }

    List<ReadingBasicInfoResponse> results = [];
    if (rawData is List) {
      results = rawData
          .map((e) => ReadingBasicInfoResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (rawData is Map<String, dynamic>) {
      results = [ReadingBasicInfoResponse.fromJson(rawData)];
    } else {
      throw ServerException('Formato de datos de lectura básico desconocido');
    }

    return results;
  }

  Map<String, dynamic> _sanitizeReadingResponseData(Map<String, dynamic> json) {
    final Map<String, dynamic> sanitized = Map.from(json);
    final fieldsToConvert = [
      'readingValue',
      'sewerRate',
      'previousReading',
      'currentReading',
      'readingId',
      'sector',
      'account',
      'rentalIncomeCode',
      'incomeCode',
    ];
    for (final field in fieldsToConvert) {
      if (sanitized[field] is String) {
        sanitized[field] = num.tryParse(sanitized[field]);
      }
    }
    return sanitized;
  }

  @override
  Future<ReadingResponse> updateCurrentReading(
    String readingId,
    UpdateReadingRequest request,
  ) async {
    final headers = await _getHeaders();
    final response = await client.put(
      Uri.parse('$baseUrl/Readings/update-current-reading/$readingId'),
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 401) {
      throw ServerException('Unauthorized: Please login again', 401);
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    final data = json['data'];
    if (data is List) {
      if (data.isEmpty) throw ServerException('Empty response data');
      return ReadingResponse.fromJson(_sanitizeReadingResponseData(data.first as Map<String, dynamic>));
    } else if (data is Map<String, dynamic>) {
      return ReadingResponse.fromJson(_sanitizeReadingResponseData(data));
    } else {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        throw ServerException('Invalid response format');
      }
      throw ServerException(json['message']?.toString() ?? 'Update failed');
    }
  }

  @override
  Future<ReadingResponse> createReading(CreateReadingRequest request) async {
    final headers = await _getHeaders();
    final requestBody = jsonEncode(request.toJson());
    
    // Imprimir lo que se está enviando al backend
    print("🚀🚀🚀 ENVIANDO REQUEST A BACKEND: $requestBody");

    final response = await client.post(
      Uri.parse('$baseUrl/Readings/create-reading'),
      headers: headers,
      body: requestBody,
    );

    if (response.statusCode == 401) {
      throw ServerException('Unauthorized: Please login again', 401);
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    print("JSON CREARLECTURA: $json");

    // Similar handling as update
    final data = json['data'];
    if (data is List) {
      if (data.isEmpty) throw ServerException('Empty response data');
      return ReadingResponse.fromJson(_sanitizeReadingResponseData(data.first as Map<String, dynamic>));
    } else if (data is Map<String, dynamic>) {
      return ReadingResponse.fromJson(_sanitizeReadingResponseData(data));
    } else {
      throw ServerException(json['message']?.toString() ?? 'Create failed');
    }
  }
}
