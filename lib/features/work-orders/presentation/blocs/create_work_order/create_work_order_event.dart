import '../../../domain/repositories/work_order_repository.dart';

abstract class CreateWorkOrderEvent {}

class CreateWorkOrderSubmitted extends CreateWorkOrderEvent {
  final CreateWorkOrderParams params;
  CreateWorkOrderSubmitted(this.params);
}
