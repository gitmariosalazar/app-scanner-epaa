// lib/features/form/data/datasources/photo_reading_datasource.dart
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import 'package:flutter_application/config/environments/environment.dart';
import 'package:flutter_application/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:mime/mime.dart' as mime;
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/form/data/models/photo_reading_model.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';

class PhotoReadingDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  static final String baseUrl = Environment.apiUrl;

  PhotoReadingDataSource({
    required this.client,
    required this.authLocalDataSource,
  });

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await authLocalDataSource.getToken();
    return {if (token != null) 'Authorization': 'Bearer $token'};
  }

  Future<Either<Failure, List<PhotoReadingModel>>> createPhotoReadings({
    required List<File> images,
    required int readingId,
    required String cadastralKey,
    String? description,
  }) async {
    if (images.isEmpty) {
      return Left(ServerFailure(message: 'At least one image is required.'));
    }

    // Validación adicional: Verificar que los archivos existan y sean accesibles
    for (var image in images) {
      if (!await image.exists()) {
        return Left(
          ServerFailure(message: 'Image file not found: ${image.path}'),
        );
      }
      final fileSize = await image.length();
      if (fileSize > 10 * 1024 * 1024) {
        // 10MB límite
        return Left(
          ServerFailure(
            message:
                'Image too large: ${image.path} (${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB)',
          ),
        );
      }
      developer.log(
        'File validated: ${image.path}, size: ${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB',
      );
    }

    final headers = await _getAuthHeaders();
    final uri = Uri.parse('$baseUrl/photo-reading/create-photo-readings');
    var request = http.MultipartRequest('POST', uri);

    // Add Auth header only
    request.headers.addAll(headers);

    // Añadir campos de formulario
    request.fields['readingId'] = readingId.toString();
    request.fields['cadastralKey'] = cadastralKey;
    if (description != null && description.isNotEmpty) {
      request.fields['description'] = description;
    }

    developer.log(
      'Fields added: readingId=$readingId, cadastralKey=$cadastralKey',
    );

    // Añadir archivos con MIME type explícito
    for (var image in images) {
      try {
        // Detectar el MIME type basado en la extensión del archivo
        final fileName = image.path.split('/').last;
        final mimeType = mime.lookupMimeType(fileName) ?? 'image/jpeg';
        final fileSize = await image.length();

        developer.log(
          'Adding file: ${image.path}, filename: $fileName, mimeType: $mimeType, size: ${(fileSize / 1024).toStringAsFixed(0)}KB',
        );

        request.files.add(
          await http.MultipartFile.fromPath(
            'images', // Coincide con el campo esperado en el backend
            image.path,
            contentType: MediaType.parse(
              mimeType,
            ), // Especificar explícitamente el MIME type
          ),
        );
      } catch (e) {
        developer.log('Error adding file ${image.path}: $e');
        return Left(
          ServerFailure(
            message: 'Failed to add image: ${image.path}. Error: $e',
          ),
        );
      }
    }

    developer.log(
      'MultipartRequest built successfully with ${images.length} files. Sending to $uri...',
    );

    try {
      // Use client.send if possible, but MultipartRequest.send() creates its own client internally or uses a provided one?
      // http.MultipartRequest inherits from BaseRequest. BaseRequest.send() opens a connection.
      // If we want to use the injected client, we should use client.send(request).
      // However, client.send expects a BaseRequest.

      final streamedResponse = await client.send(request);

      final responseBody = await streamedResponse.stream.bytesToString();
      developer.log('Response status: ${streamedResponse.statusCode}');
      developer.log(
        'Response body preview: ${responseBody.substring(0, responseBody.length > 200 ? 200 : responseBody.length)}...',
      );

      if (streamedResponse.statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
        final List<dynamic> data = jsonResponse['data'] ?? [];
        if (data.isEmpty) {
          // Returning empty list is better than error if success 201
          return const Right([]);
        }
        final List<PhotoReadingModel> models = data
            .map((json) => PhotoReadingModel.fromJson(json))
            .toList();
        developer.log('Parsed ${models.length} models successfully.');
        return Right(models);
      } else if (streamedResponse.statusCode == 401) {
        return Left(
          ServerFailure(message: 'Unauthorized: Please login again.'),
        );
      } else if (streamedResponse.statusCode == 500) {
        developer.log('Server internal error (500): $responseBody');
        return Left(ServerFailure(message: 'Server error: $responseBody'));
      } else if (streamedResponse.statusCode == 413) {
        return Left(
          ServerFailure(
            message:
                'Request too large. Please reduce image size or contact admin.',
          ),
        );
      } else {
        developer.log('Server error response: $responseBody');
        return Left(
          ServerFailure(
            message:
                'Server returned ${streamedResponse.statusCode}: $responseBody',
          ),
        );
      }
    } catch (e) {
      developer.log('Network or parsing error: $e');
      return Left(NetworkFailure(message: 'Network error: $e'));
    }
  }
}
