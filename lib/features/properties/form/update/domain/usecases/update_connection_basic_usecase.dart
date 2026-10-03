import 'package:flutter_application/features/properties/form/update/data/models/dto/request/update_connection_basic_request.dart';
import 'package:flutter_application/features/properties/form/update/domain/repositories/connection_repository.dart';

class UpdateConnectionBasicUseCase {
  final ConnectionRepository repository;

  UpdateConnectionBasicUseCase(this.repository);

  Future<void> call(UpdateConnectionBasicRequest request) {
    return repository.updateConnectionBasic(request);
  }
}
