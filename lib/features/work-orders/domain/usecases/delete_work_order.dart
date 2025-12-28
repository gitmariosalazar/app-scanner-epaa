import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import '../repositories/work_order_repository.dart';

class DeleteWorkOrder {
  final WorkOrderRepository repository;

  DeleteWorkOrder(this.repository);

  Future<Either<Failure, void>> call(DeleteWorkOrderParams params) {
    return repository.deleteWorkOrder(params);
  }
}
