import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import '../repositories/work_order_repository.dart';
import '../entities/work_order_entity.dart';

class GetWorkOrderDetails {
  final WorkOrderRepository repository;

  GetWorkOrderDetails(this.repository);

  Future<Either<Failure, WorkOrderEntity>> call(
    GetWorkOrderDetailsParams params,
  ) {
    return repository.getWorkOrderDetails(params);
  }
}
