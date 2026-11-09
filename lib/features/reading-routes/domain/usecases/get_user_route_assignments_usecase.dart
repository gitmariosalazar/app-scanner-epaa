import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_assignment.dart';
import 'package:flutter_application/features/reading-routes/domain/repositories/reading_routes_repository.dart';

class GetUserRouteAssignmentsUseCase {
  final ReadingRoutesRepository repository;

  GetUserRouteAssignmentsUseCase(this.repository);

  Future<Either<Failure, List<RouteAssignment>>> call({
    String? periodoMes,
    String? fecha,
    bool forceRefresh = false,
  }) {
    return repository.getUserAssignments(
      periodoMes: periodoMes,
      fecha: fecha,
      forceRefresh: forceRefresh,
    );
  }
}
