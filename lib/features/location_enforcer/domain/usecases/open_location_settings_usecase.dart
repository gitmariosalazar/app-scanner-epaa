import 'package:flutter_application/features/location_enforcer/domain/repositories/location_enforcer_repository.dart';

class OpenLocationSettingsUseCase {
  final LocationEnforcerRepository repository;

  OpenLocationSettingsUseCase(this.repository);

  Future<void> call() async {
    return await repository.openSettings();
  }
}
