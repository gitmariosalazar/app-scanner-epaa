import 'package:flutter_application/features/location_enforcer/domain/entities/location_status.dart';
import 'package:flutter_application/features/location_enforcer/domain/repositories/location_enforcer_repository.dart';

class CheckLocationStatusUseCase {
  final LocationEnforcerRepository repository;

  CheckLocationStatusUseCase(this.repository);

  Future<LocationStatus> call() async {
    return await repository.checkStatus();
  }
}
