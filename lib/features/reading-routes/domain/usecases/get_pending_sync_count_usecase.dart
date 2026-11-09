import 'package:flutter_application/features/reading-routes/domain/repositories/reading_routes_repository.dart';

class GetPendingSyncCountUseCase {
  final ReadingRoutesRepository repository;

  GetPendingSyncCountUseCase(this.repository);

  Future<int> call(int assignmentId) {
    return repository.getPendingSyncCount(assignmentId);
  }
}
