import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/core/usecases/usecase.dart';
import 'package:flutter_application/features/incidents/domain/dto/request/create_incident_request.dart';
import 'package:flutter_application/features/incidents/domain/entities/incident.model.dart';
import 'package:flutter_application/features/incidents/domain/repositories/incident_repository.dart';

class CreateIncidentUseCase implements UseCase<IncidentModel, CreateIncidentRequest> {
  final IncidentRepository repository;

  CreateIncidentUseCase(this.repository);

  @override
  Future<Either<Failure, IncidentModel>> call(CreateIncidentRequest params) {
    return repository.createIncident(
      request: params,
    );
  }
}
