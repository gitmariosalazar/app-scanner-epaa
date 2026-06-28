import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/core/usecases/usecase.dart';
import 'package:flutter_application/features/incidents/domain/entities/incident_detail_row_response.dart';
import 'package:flutter_application/features/incidents/domain/repositories/incident_repository.dart';

class FindIncidentsParams {
  final String? connectionId;
  final String? status;
  final String? priority;
  final int? incidentTypeId;

  const FindIncidentsParams({
    this.connectionId,
    this.status,
    this.priority,
    this.incidentTypeId,
  });
}

class FindIncidentsUseCase
    implements UseCase<List<IncidentDetailRowResponse>, FindIncidentsParams> {
  final IncidentRepository repository;

  FindIncidentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<IncidentDetailRowResponse>>> call(
    FindIncidentsParams params,
  ) {
    return repository.findIncidents(
      connectionId: params.connectionId,
      status: params.status,
      priority: params.priority,
      incidentTypeId: params.incidentTypeId,
    );
  }
}
