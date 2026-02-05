// lib/features/scan/domain/repositories/reading_repository.dart
import 'package:flutter_application/features/reading/data/model/create_reading_request.dart';
import 'package:flutter_application/features/reading/data/model/update_reading_request.dart';
import 'package:flutter_application/features/reading/domain/entities/reading.dart';
import 'package:flutter_application/features/reading/domain/entities/reading_basic_info.dart';
import 'package:flutter_application/features/reading/domain/entities/reading_result.dart';

abstract class ReadingRepository {
  Future<List<Reading>> getReadingInfo(String cadastralKey);
  Future<List<ReadingBasicInfo>> findBasicReading(String catastralCode);
  Future<ReadingResult> updateCurrentReading(
    String readingId,
    UpdateReadingRequest request,
  );
  Future<ReadingResult> createReading(CreateReadingRequest request);
}
