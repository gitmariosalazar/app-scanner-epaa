import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/offline_reading.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_work_pack.dart';
import 'package:flutter_application/features/reading-routes/domain/repositories/reading_routes_repository.dart';

class SaveOfflineReadingUseCase {
  final ReadingRoutesRepository repository;

  SaveOfflineReadingUseCase(this.repository);

  Future<Either<Failure, RouteWorkPack>> call(OfflineReading reading) {
    return repository.saveOfflineReading(reading);
  }
}
