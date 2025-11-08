// lib/features/scan/data/datasources/remote_reading_data_source.dart
import 'dart:convert';
import 'package:flutter_application/config/environments/environment.dart';
import 'package:flutter_application/shared/api/response/api_response.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application/features/reading/data/model/reading_info_response.dart';

abstract class RemoteReadingDataSource {
  Future<ReadingInfoResponse> getReadingInfo(String cadastralKey);
}

class RemoteReadingDataSourceImpl implements RemoteReadingDataSource {
  final http.Client client;
  final String baseUrl = Environment.apiUrl;

  RemoteReadingDataSourceImpl(this.client);

  @override
  Future<ReadingInfoResponse> getReadingInfo(String cadastralKey) async {
    final response = await client.get(
      Uri.parse('$baseUrl/Readings/find-reading-info/$cadastralKey'),
      headers: {'Content-Type': 'application/json'},
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    // Usar ApiResponse para parsear
    final apiResponse = ApiResponse<ReadingInfoResponse>.fromJson(
      json,
      ReadingInfoResponse.fromJson,
    );

    // Manejar errores
    if (apiResponse.statusCode >= 400) {
      throw Exception(apiResponse.message.join(', '));
    }

    if (apiResponse.data.isEmpty) {
      throw Exception('No se encontró lectura para $cadastralKey');
    }

    // Devolver la primera lectura (la más reciente)
    return apiResponse.data.first;
  }
}
