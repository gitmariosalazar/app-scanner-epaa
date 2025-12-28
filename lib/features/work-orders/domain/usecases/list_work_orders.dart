import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import '../repositories/work_order_repository.dart';
import '../entities/work_order_entity.dart';

class ListWorkOrders {
  final WorkOrderRepository repository;

  ListWorkOrders(this.repository);

  Future<Either<Failure, List<WorkOrderEntity>>> call(
    ListWorkOrdersParams params,
  ) {
    return repository.listWorkOrders(params);
  }
}
