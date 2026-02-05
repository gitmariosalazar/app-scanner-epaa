import 'dart:convert';
import 'package:flutter_application/config/environments/environment.dart';
import 'package:flutter_application/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application/features/properties/form/update/data/models/dto/request/update_company_request.dart';

class CompanyRemoteDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  static final String baseUrl = Environment.apiUrl;

  CompanyRemoteDataSource({
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

  Future<void> updateCompany({
    required String companyRuc,
    required UpdateCompanyRequest request,
  }) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl/companies/update-company/$companyRuc');
    final response = await client.put(
      url,
      headers: headers,
      body: jsonEncode(request.toJson()..['companyRuc'] = companyRuc),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update company: ${response.body}');
    }
  }
}
