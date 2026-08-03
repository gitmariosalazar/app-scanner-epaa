import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/incidents/domain/entities/incident_kpi.model.dart';
import 'package:flutter_application/features/incidents/domain/repositories/incident_repository.dart';

class GetIncidentDashboardKpis {
  final IncidentRepository repository;

  GetIncidentDashboardKpis(this.repository);

  Future<Either<Failure, IncidentDashboardKpiResponse>> call() async {
    return repository.getIncidentDashboardKpis();
  }
}
