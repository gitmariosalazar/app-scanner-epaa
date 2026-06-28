import 'package:flutter/foundation.dart';
import 'package:flutter_application/shared/files/domain/repositories/file_repository.dart';

class DownloadFileUseCase {
  final FileRepository repository;

  DownloadFileUseCase(this.repository);

  Future<Uint8List> execute({
    required FileCategory type,
    required String filename,
  }) async {
    if (filename.trim().isEmpty) {
      throw ArgumentError('Filename cannot be empty');
    }
    return repository.download(type: type, filename: filename);
  }
}
