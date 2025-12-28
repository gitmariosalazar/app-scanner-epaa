import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import '../../domain/entities/work_order_entity.dart';
import '../../domain/repositories/work_order_repository.dart';
import '../datasources/work_order_remote_datasource.dart';
import '../mappers/work_order_mapper.dart';

class WorkOrderRepositoryImpl implements WorkOrderRepository {
  final WorkOrderRemoteDataSource remoteDataSource;

  WorkOrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, WorkOrderEntity>> createWorkOrder(
    CreateWorkOrderParams params,
  ) async {
    try {
      final model = await remoteDataSource.createWorkOrder(params.request);
      final entity = WorkOrderMapper.fromWorkOrderResponseToWorkOrderEntity(
        model,
      );
      return Right(entity);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkOrderEntity>> assignWorkOrder(
    AssignWorkOrderParams params,
  ) {
    // TODO: implement assignWorkOrder
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deleteWorkOrder(DeleteWorkOrderParams params) {
    // TODO: implement deleteWorkOrder
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, WorkOrderEntity>> editWorkOrder(
    EditWorkOrderParams params,
  ) {
    // TODO: implement editWorkOrder
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, WorkOrderEntity>> getWorkOrderDetails(
    GetWorkOrderDetailsParams params,
  ) {
    // TODO: implement getWorkOrderDetails
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<WorkOrderEntity>>> listWorkOrders(
    ListWorkOrdersParams params,
  ) {
    // TODO: implement listWorkOrders
    throw UnimplementedError();
  }

  // TODO: Implement other methods similarly (edit, delete, assign, list, details)
}
