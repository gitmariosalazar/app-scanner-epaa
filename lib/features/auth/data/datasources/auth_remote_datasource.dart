import 'dart:convert';
import 'package:flutter_application/config/environments/environment.dart';
import 'package:flutter_application/core/error/exception.dart';
import 'package:flutter_application/features/auth/data/models/auth_response_model.dart';
import 'package:flutter_application/features/auth/domain/entities/verify_user_result.dart';
import 'package:http/http.dart' as http;

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String username_or_email, String password);
  Future<void> logout();

  /// Throws [NetworkException] if offline. Throws [ServerException] if server errors.
  Future<VerifyUserResult> verifyUser(String usernameOrEmail);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final String baseUrl = Environment.apiUrl;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<AuthResponseModel> login(
    String username_or_email,
    String password,
  ) async {
    return guardNetwork(() async {
      final uri = Uri.parse('$baseUrl/auth/signin');
      final response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username_or_email': username_or_email,
          'password': password,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body);
        final data = json['data'];
        if (data == null) {
          throw ServerException('Invalid response: missing data');
        }
        if (data is Map<String, dynamic>) {
          print('✅✅✅✅✅✅ Data: ${data}');
          return AuthResponseModel.fromJson(data);
        }
        throw ServerException('Invalid response: data is not an object');
      } else {
        try {
          final json = jsonDecode(response.body);
          throw ServerException(
            json['message']?.toString() ?? 'Login failed',
            response.statusCode,
          );
        } catch (e) {
          if (e is ServerException) rethrow;
          throw ServerException(
            'Login failed with status code ${response.statusCode}',
            response.statusCode,
          );
        }
      }
    });
  }

  @override
  Future<void> logout() async {
    try {
      final uri = Uri.parse('$baseUrl/auth/signout');
      await client.post(uri, headers: {'Content-Type': 'application/json'});
    } catch (_) {
      // Logout is best-effort — never block the UI
    }
  }

  @override
  Future<VerifyUserResult> verifyUser(String usernameOrEmail) async {
    return guardNetwork(() async {
      final uri = Uri.parse('$baseUrl/auth/verify');
      final response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username_or_email': usernameOrEmail}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final data = json['data'];
        if (data == null) {
          throw ServerException('Invalid verify response: missing data');
        }
        return VerifyUserResult.fromJson(data as Map<String, dynamic>);
      } else {
        try {
          final json = jsonDecode(response.body);
          throw ServerException(
            json['message']?.toString() ?? 'User verification failed',
            response.statusCode,
          );
        } catch (e) {
          if (e is ServerException) rethrow;
          throw ServerException(
            'User verification failed with status ${response.statusCode}',
            response.statusCode,
          );
        }
      }
    });
  }
}
