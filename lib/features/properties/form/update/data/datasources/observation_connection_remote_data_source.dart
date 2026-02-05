import 'dart:convert';
import 'package:flutter_application/config/environments/environment.dart';
import 'package:flutter_application/features/properties/form/update/data/models/dto/request/create_observation_request.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application/features/auth/data/datasources/auth_local_datasource.dart';

class ObservationConnectionRemoteDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  static final String baseUrl = Environment.apiUrl;

  ObservationConnectionRemoteDataSource({
    required this.client,
    required this.authLocalDataSource,
  });

  Future<Map<String, String>> _getHeaders() async {
    final token = await authLocalDataSource.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> addObservationConnection({
    required CreateObservationRequest request,
  }) async {
    final headers = await _getHeaders();
    final url = Uri.parse(
      '$baseUrl/observation-connection/create-observation-connection',
    );
    final response = await client.post(
      url,
      headers: headers,
      body: jsonEncode(request),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Failed to create observation connection: ${response.body}',
      );
    }
  }
}
