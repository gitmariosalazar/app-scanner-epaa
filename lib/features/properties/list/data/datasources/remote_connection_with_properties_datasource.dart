import 'package:flutter_application/config/environments/environment.dart';
import 'package:flutter_application/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_application/features/properties/list/data/model/schemas/dto/response/connection_with_properties_response.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application/shared/api/response/api_response.dart';
import 'dart:convert';

abstract class RemoteConnectionWithPropertiesDataSource {
  Future<ConnectionWithPropertiesResponse>
  fetchConnectionWithPropertiesByCadastralKey(String cadastralKey);
}

class RemoteConnectionWithPropertiesDataSourceImpl
    implements RemoteConnectionWithPropertiesDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  final String baseUrl = Environment.apiUrl;

  RemoteConnectionWithPropertiesDataSourceImpl(
    this.client,
    this.authLocalDataSource,
  );

  Future<Map<String, String>> _getHeaders() async {
    final token = await authLocalDataSource.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<ConnectionWithPropertiesResponse>
  fetchConnectionWithPropertiesByCadastralKey(String cadastralKey) async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse(
        '$baseUrl/connections/find-connection-with-property-by-cadastral-key/$cadastralKey',
      ),
      headers: headers,
    );

    if (response.statusCode == 401) {
      throw Exception('Unauthorized: Please login again');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error HTTP ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    final rawData = json['data'];

    List<ConnectionWithPropertiesResponse> dataList = [];

    if (rawData is List) {
      dataList = rawData
          .map(
            (e) => ConnectionWithPropertiesResponse.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList();
    } else if (rawData is Map<String, dynamic>) {
      dataList = [ConnectionWithPropertiesResponse.fromJson(rawData)];
    } else {
      throw Exception('Formato de data inesperado');
    }

    final apiResponse = ApiResponse<ConnectionWithPropertiesResponse>(
      statusCode: json['status_code'] as int,
      time: json['time'] as String,
      message: List<String>.from(json['message'] as List),
      url: json['url'] as String,
      data: dataList,
    );

    if (apiResponse.statusCode < 200 || apiResponse.statusCode >= 300) {
      throw Exception(apiResponse.message.join(', '));
    }

    if (apiResponse.data.isEmpty) {
      throw Exception(
        'No se encontró conexión para la clave catastral: $cadastralKey',
      );
    }

    return apiResponse.data.first;
  }
}
