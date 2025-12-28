import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import '../repositories/work_order_repository.dart';
import '../entities/work_order_entity.dart';

class AssignWorkOrder {
  final WorkOrderRepository repository;

  AssignWorkOrder(this.repository);

  Future<Either<Failure, WorkOrderEntity>> call(AssignWorkOrderParams params) {
    return repository.assignWorkOrder(params);
  }
}
