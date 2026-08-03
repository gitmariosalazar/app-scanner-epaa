import 'package:flutter_application/features/location_enforcer/domain/entities/location_status.dart';
import 'package:flutter_application/features/location_enforcer/domain/repositories/location_enforcer_repository.dart';

class RequestLocationPermissionUseCase {
  final LocationEnforcerRepository repository;

  RequestLocationPermissionUseCase(this.repository);

  Future<LocationStatus> call() async {
    return await repository.requestPermission();
  }
}
