import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import '../repositories/work_order_repository.dart';
import '../entities/work_order_entity.dart';

class EditWorkOrder {
  final WorkOrderRepository repository;

  EditWorkOrder(this.repository);

  Future<Either<Failure, WorkOrderEntity>> call(EditWorkOrderParams params) {
    return repository.editWorkOrder(params);
  }
}
