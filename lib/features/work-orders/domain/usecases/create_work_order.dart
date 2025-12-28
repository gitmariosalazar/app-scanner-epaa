import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import '../repositories/work_order_repository.dart';
import '../entities/work_order_entity.dart';

class CreateWorkOrderUseCase {
  final WorkOrderRepository repository;

  CreateWorkOrderUseCase(this.repository);

  Future<Either<Failure, WorkOrderEntity>> call(CreateWorkOrderParams params) {
    return repository.createWorkOrder(params);
  }
}
