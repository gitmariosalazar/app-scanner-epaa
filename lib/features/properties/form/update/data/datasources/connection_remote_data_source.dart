// lib/features/properties/put/data/datasources/connection_remote_data_source.dart
import 'dart:convert';
import 'package:flutter_application/config/environments/environment.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application/features/properties/form/update/data/models/dto/request/update_connection_request.dart';
import 'package:flutter_application/features/auth/data/datasources/auth_local_datasource.dart';

class ConnectionRemoteDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  static final String baseUrl = Environment.apiUrl;

  ConnectionRemoteDataSource({
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

  Future<void> updateConnection({
    required String connectionId,
    required UpdateConnectionRequest request,
  }) async {
    final headers = await _getHeaders();
    final url = Uri.parse(
      '$baseUrl/connections/update-connection/$connectionId',
    );
    final response = await client.put(
      url,
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update connection: ${response.body}');
    }
  }
}
