// lib/features/observations/data/datasources/observations_datasource.dart

import 'package:flutter_application/config/environments/environment.dart';
import 'package:flutter_application/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_application/features/observations/data/models/observation_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class ObservationsDataSource {
  Future<List<ObservationModel>> fetchObservationsByCadastralKey(
    String connectionId,
  );
  Future<List<ObservationModel>> fetchAllObservations();
}

class ObservationsDataSourceImpl implements ObservationsDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  final String apiUrl = Environment.apiUrl;

  ObservationsDataSourceImpl({
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

  @override
  Future<List<ObservationModel>> fetchObservationsByCadastralKey(
    String connectionId,
  ) async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse(
        '$apiUrl/observations/get-observation-details-by-cadastral-key/$connectionId',
      ),
      headers: headers,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);

      // Verificar que 'data' exista y sea lista
      final data = decoded['data'];
      if (data is! List) {
        throw Exception(
          'La respuesta de la API no contiene una lista en "data"',
        );
      }

      return data.map((item) => ObservationModel.fromJson(item)).toList();
    } else {
      throw Exception('Error en la API: ${response.statusCode}');
    }
  }

  @override
  Future<List<ObservationModel>> fetchAllObservations() async {
    final headers = await _getHeaders();
    final response = await client.get(
      Uri.parse('$apiUrl/observations/get-observations'),
      headers: headers,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);

      final data = decoded['data'];
      if (data is! List) {
        throw Exception(
          'La respuesta de la API no contiene una lista en "data"',
        );
      }

      return data.map((item) => ObservationModel.fromJson(item)).toList();
    } else {
      throw Exception('Error en la API: ${response.statusCode}');
    }
  }
}
