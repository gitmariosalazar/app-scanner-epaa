import 'dart:convert';
import 'package:flutter_application/config/environments/environment.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application/features/properties/form/update/data/models/dto/request/update_customer_request.dart';
import 'package:flutter_application/features/auth/data/datasources/auth_local_datasource.dart';

class CustomerRemoteDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  static final String baseUrl = Environment.apiUrl;

  CustomerRemoteDataSource({
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

  Future<void> updateCustomer({
    required String customerId,
    required UpdateCustomerRequest request,
  }) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl/Customers/update-customer/$customerId');
    final response = await client.put(
      url,
      headers: headers,
      body: jsonEncode(
        request.toJson()..['customerId'] = int.tryParse(customerId) ?? 0,
      ), // Include customerId in body if required
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update customer: ${response.body}');
    }
  }
}
