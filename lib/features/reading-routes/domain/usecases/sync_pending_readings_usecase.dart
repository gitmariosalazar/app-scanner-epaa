import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/offline_reading.dart';
import 'package:flutter_application/features/reading-routes/domain/repositories/reading_routes_repository.dart';

class SyncPendingReadingsUseCase {
  final ReadingRoutesRepository repository;

  SyncPendingReadingsUseCase(this.repository);

  Future<Either<Failure, SyncBatchResult>> call(int assignmentId) {
    return repository.syncPendingBatch(assignmentId);
  }
}
