import 'dart:convert';
import 'package:flutter_application/config/environments/environment.dart';
import 'package:flutter_application/core/error/exception.dart';
import 'package:flutter_application/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_application/features/incidents/domain/dto/request/create_incident_request.dart';
import 'package:flutter_application/features/incidents/domain/dto/request/resolve_incident_request.dart';
import 'package:flutter_application/features/incidents/domain/entities/incident-category.model.dart';
import 'package:flutter_application/features/incidents/domain/entities/incident.model.dart';
import 'package:flutter_application/features/incidents/domain/entities/incident_detail_row_response.dart';
import 'package:http/http.dart' as http;

abstract class IncidentRemoteDataSource {
  Future<IncidentModel> createIncident({
    required CreateIncidentRequest request,
  });

  Future<IncidentModel> resolveIncident({
    required int incidentId,
    required String resolverUserId,
    required ResolveIncidentRequest request,
  });

  Future<List<IncidentDetailRowResponse>> findIncidentsByConnection(
    String connectionId,
  );

  Future<IncidentModel> findById(int incidentId);

  Future<List<IncidentDetailRowResponse>> findIncidents({
    String? connectionId,
    String? status,
    String? priority,
    int? incidentTypeId,
  });

  Future<List<IncidentCategoryModel>> findIncidentCategories();
}

class IncidentRemoteDataSourceImpl implements IncidentRemoteDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  final String _baseUrl = Environment.apiUrl;

  IncidentRemoteDataSourceImpl({
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

  void _checkHttpStatus(int statusCode, String errorBody) {
    if (statusCode == 401) {
      throw ServerException(
        'Sesión expirada. Por favor, inicie sesión de nuevo.',
        401,
      );
    }
    if (statusCode >= 400) {
      String errorMessage = 'Error del servidor ($statusCode)';
      try {
        final Map<String, dynamic> json = jsonDecode(errorBody);
        if (json.containsKey('message')) {
          if (json['message'] is List) {
            errorMessage = (json['message'] as List).join(', ');
          } else {
            errorMessage = json['message'].toString();
          }
        }
      } catch (_) {}
      throw ServerException(errorMessage, statusCode);
    }
  }

  @override
  Future<IncidentModel> createIncident({
    required CreateIncidentRequest request,
  }) async {
    try {
      final token = await authLocalDataSource.getToken();

      final uri = Uri.parse('$_baseUrl/incidents/create-incident');

      var requestMultipart = http.MultipartRequest('POST', uri);

      requestMultipart.headers.addAll({'Authorization': 'Bearer $token'});

      // Campos de texto
      if (request.connectionId != null) {
        requestMultipart.fields['connectionId'] = request.connectionId!;
      }
      if (request.readingId != null) {
        requestMultipart.fields['readingId'] = request.readingId.toString();
      }
      requestMultipart.fields['incidentTypeId'] = request.incidentTypeId
          .toString();
      requestMultipart.fields['reportDescription'] = request.reportDescription;
      requestMultipart.fields['referenceAddress'] = request.referenceAddress;
      requestMultipart.fields['reportOrigin'] = request.reportOrigin;
      requestMultipart.fields['priority'] = request.priority;
      requestMultipart.fields['latitude'] = request.latitude.toString();
      requestMultipart.fields['longitude'] = request.longitude.toString();

      // Archivos (imágenes) - Soporta JPG, PNG, WEBP, GIF, etc.
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

      final streamedResponse = await requestMultipart.send();
      final response = await http.Response.fromStream(streamedResponse);

      _checkHttpStatus(response.statusCode, response.body);

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final data = jsonResponse['data'] as Map<String, dynamic>?;

      if (data == null) {
        throw ServerException(
          'La respuesta no contiene datos válidos del incidente.',
        );
      }

      return IncidentModel.fromJson(data);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<IncidentModel> resolveIncident({
    required int incidentId,
    required String resolverUserId,
    required ResolveIncidentRequest request,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_baseUrl/incidents/resolve-incident/$incidentId');
    final response = await client.put(
      uri,
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    _checkHttpStatus(response.statusCode, response.body);

    final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
    final data = jsonResponse['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw ServerException(
        'La respuesta no contiene datos válidos del incidente.',
      );
    }
    return IncidentModel.fromJson(data);
  }

  @override
  Future<List<IncidentDetailRowResponse>> findIncidentsByConnection(
    String connectionId,
  ) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
      '$_baseUrl/incidents/find-by-connection/$connectionId',
    );
    final response = await client.get(uri, headers: headers);

    _checkHttpStatus(response.statusCode, response.body);

    final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
    final data = jsonResponse['data'];
    if (data is List) {
      return data
          .map(
            (e) =>
                IncidentDetailRowResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    }
    return [];
  }

  @override
  Future<IncidentModel> findById(int incidentId) async {
    throw UnimplementedError(
      'El endpoint de búsqueda individual por ID no está expuesto en el gateway.',
    );
  }

  @override
  Future<List<IncidentDetailRowResponse>> findIncidents({
    String? connectionId,
    String? status,
    String? priority,
    int? incidentTypeId,
  }) async {
    final headers = await _getHeaders();

    final queryParams = <String, String>{};
    if (connectionId != null) queryParams['connectionId'] = connectionId;
    if (status != null) queryParams['status'] = status;
    if (priority != null) queryParams['priority'] = priority;
    if (incidentTypeId != null) {
      queryParams['incidentTypeId'] = incidentTypeId.toString();
    }

    final uri = Uri.parse(
      '$_baseUrl/incidents/search',
    ).replace(queryParameters: queryParams);
    final response = await client.get(uri, headers: headers);

    _checkHttpStatus(response.statusCode, response.body);

    final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
    final data = jsonResponse['data'];
    if (data is List) {
      return data
          .map(
            (e) =>
                IncidentDetailRowResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    }
    return [];
  }

  @override
  Future<List<IncidentCategoryModel>> findIncidentCategories() async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_baseUrl/incidents/categories');
    final response = await client.get(uri, headers: headers);

    _checkHttpStatus(response.statusCode, response.body);

    final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
    final data = jsonResponse['data'];
    if (data is List) {
      return data
          .map((e) => IncidentCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
