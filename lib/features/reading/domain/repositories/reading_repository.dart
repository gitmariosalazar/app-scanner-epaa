// lib/features/scan/domain/repositories/reading_repository.dart
import 'package:flutter_application/features/reading/domain/entities/reading.dart';

abstract class ReadingRepository {
  Future<Reading> getReadingInfo(String cadastralKey);
}
