import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/core/usecases/usecase.dart';
import 'package:flutter_application/features/incidents/domain/dto/request/resolve_incident_request.dart';
import 'package:flutter_application/features/incidents/domain/entities/incident.model.dart';
import 'package:flutter_application/features/incidents/domain/repositories/incident_repository.dart';

class ResolveIncidentParams {
  final int incidentId;
  final String resolverUserId;
  final ResolveIncidentRequest request;

  const ResolveIncidentParams({
    required this.incidentId,
    required this.resolverUserId,
    required this.request,
  });
}

class ResolveIncidentUseCase implements UseCase<IncidentModel, ResolveIncidentParams> {
  final IncidentRepository repository;

  ResolveIncidentUseCase(this.repository);

  @override
  Future<Either<Failure, IncidentModel>> call(ResolveIncidentParams params) {
    return repository.resolveIncident(
      incidentId: params.incidentId,
      resolverUserId: params.resolverUserId,
      request: params.request,
    );
  }
}
