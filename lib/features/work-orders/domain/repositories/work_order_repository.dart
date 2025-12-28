import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import '../entities/work_order_entity.dart';
import '../../data/models/create_work_order_request.dart';
import '../../data/models/update_work_order_request.dart';
import '../../data/models/assign_work_order_request.dart';

abstract class WorkOrderRepository {
  Future<Either<Failure, WorkOrderEntity>> createWorkOrder(
    CreateWorkOrderParams params,
  );
  Future<Either<Failure, WorkOrderEntity>> editWorkOrder(
    EditWorkOrderParams params,
  );
  Future<Either<Failure, void>> deleteWorkOrder(DeleteWorkOrderParams params);
  Future<Either<Failure, WorkOrderEntity>> assignWorkOrder(
    AssignWorkOrderParams params,
  );
  Future<Either<Failure, List<WorkOrderEntity>>> listWorkOrders(
    ListWorkOrdersParams params,
  );
  Future<Either<Failure, WorkOrderEntity>> getWorkOrderDetails(
    GetWorkOrderDetailsParams params,
  );
}

// Parameter wrappers (simple)
class CreateWorkOrderParams {
  final CreateWorkOrderRequest request;
  CreateWorkOrderParams(this.request);
}

class EditWorkOrderParams {
  final String id;
  final UpdateWorkOrderRequest request;
  EditWorkOrderParams(this.id, this.request);
}

class DeleteWorkOrderParams {
  final String id;
  DeleteWorkOrderParams(this.id);
}

class AssignWorkOrderParams {
  final String id;
  final AssignWorkOrderRequest request;
  AssignWorkOrderParams(this.id, this.request);
}

class ListWorkOrdersParams {
  final int page;
  final int pageSize;
  ListWorkOrdersParams({this.page = 1, this.pageSize = 20});
}

class GetWorkOrderDetailsParams {
  final String id;
  GetWorkOrderDetailsParams(this.id);
}
