import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_work_pack.dart';
import 'package:flutter_application/features/reading-routes/domain/repositories/reading_routes_repository.dart';

class GetRouteWorkPackUseCase {
  final ReadingRoutesRepository repository;

  GetRouteWorkPackUseCase(this.repository);

  Future<Either<Failure, RouteWorkPack>> call(
    int assignmentId, {
    bool forceDownload = false,
  }) {
    return repository.getRouteWorkPack(
      assignmentId,
      forceDownload: forceDownload,
    );
  }
}
