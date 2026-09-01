// lib/features/properties/put/data/datasources/connection_remote_data_source.dart
import 'dart:convert';
import 'package:flutter_application/config/environments/environment.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_application/features/properties/form/update/data/models/dto/request/update_connection_request.dart';
import 'package:flutter_application/features/properties/form/update/data/models/dto/request/change_meter_request.dart';
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

  Future<void> changeMeter(ChangeMeterRequest request) async {
    final token = await authLocalDataSource.getToken();
    final url = Uri.parse(
      '$baseUrl/connections/change-meter-by-reader/${request.connectionId}',
    );

    var requestMultipart = http.MultipartRequest('POST', url);

    if (token != null) {
      requestMultipart.headers['Authorization'] = 'Bearer $token';
    } else {
      // app-scanner-epaa doesn't have publicAppApiKey in Environment by default usually, but we'll try
      requestMultipart.headers['Authorization'] = 'Bearer $token';
    }

    requestMultipart.fields['changeDetail'] = jsonEncode(
      request.changeDetail.toJson(),
    );

    if (request.imageDescriptions.isNotEmpty) {
      requestMultipart.fields['imageDescriptions'] = jsonEncode(
        request.imageDescriptions,
      );
    }

    for (var file in request.images) {
      final fileBytes = await file.readAsBytes();
      final extension = file.path.split('.').last.toLowerCase();

      http.MediaType contentType;
      switch (extension) {
        case 'png':
          contentType = http.MediaType('image', 'png');
          break;
        case 'webp':
          contentType = http.MediaType('image', 'webp');
          break;
        case 'gif':
          contentType = http.MediaType('image', 'gif');
          break;
        case 'jpg':
        case 'jpeg':
        default:
          contentType = http.MediaType('image', 'jpeg');
      }

      final multipartFile = http.MultipartFile.fromBytes(
        'images',
        fileBytes,
        filename: file.path.split('/').last,
        contentType: contentType,
      );
      requestMultipart.files.add(multipartFile);
    }

    final response = await client.send(requestMultipart);
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to change meter: $responseBody');
    }
  }
}
