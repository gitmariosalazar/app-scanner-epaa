import 'package:flutter_application/features/reading/data/model/create_reading_request.dart';
import 'package:flutter_application/features/reading/domain/entities/reading_result.dart';
import 'package:flutter_application/features/reading/domain/repositories/reading_repository.dart';

class CreateReadingUseCase {
  final ReadingRepository repository;

  CreateReadingUseCase(this.repository);

  Future<ReadingResult> call(CreateReadingRequest request) async {
    return await repository.createReading(request);
  }
}
