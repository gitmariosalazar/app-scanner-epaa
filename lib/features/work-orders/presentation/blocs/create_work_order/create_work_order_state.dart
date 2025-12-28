import '../../../domain/entities/work_order_entity.dart';

abstract class CreateWorkOrderState {}

class CreateWorkOrderInitial extends CreateWorkOrderState {}

class CreateWorkOrderLoading extends CreateWorkOrderState {}

class CreateWorkOrderSuccess extends CreateWorkOrderState {
  final WorkOrderEntity entity;
  CreateWorkOrderSuccess({required this.entity});
}

class CreateWorkOrderFailure extends CreateWorkOrderState {
  final String message;
  CreateWorkOrderFailure({required this.message});
}
