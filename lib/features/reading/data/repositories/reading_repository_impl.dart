// lib/features/scan/data/repositories/reading_repository_impl.dart
import 'package:flutter_application/features/reading/data/datasources/remote_reading_data_source.dart';
import 'package:flutter_application/features/reading/data/mappers/reading_mapper.dart';
import 'package:flutter_application/features/reading/domain/entities/reading.dart';
import 'package:flutter_application/features/reading/domain/repositories/reading_repository.dart';

class ReadingRepositoryImpl implements ReadingRepository {
  final RemoteReadingDataSource dataSource;

  ReadingRepositoryImpl(this.dataSource);

  @override
  Future<List<Reading>> getReadingInfo(String cadastralKey) async {
    final dto = await dataSource.getReadingInfo(cadastralKey);
    return dto.map((e) => e.toEntity()).toList();
  }
}
