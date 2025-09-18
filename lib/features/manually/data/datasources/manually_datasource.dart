import 'dart:convert';
import 'package:flutter_application/config/environments/environment.dart';
import 'package:http/http.dart' as http;

abstract class ManuallyDataSource {
  Future<Map<String, dynamic>> fetchReading(String connectionId);
}

class ManuallyDataSourceImpl implements ManuallyDataSource {
  final String apiUrl = Environment.apiUrl;

  @override
  Future<Map<String, dynamic>> fetchReading(String connectionId) async {
    final response = await http.get(
      Uri.parse('$apiUrl/Readings/find-basic-reading/$connectionId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error en la API: ${response.statusCode}');
    }
  }
}
