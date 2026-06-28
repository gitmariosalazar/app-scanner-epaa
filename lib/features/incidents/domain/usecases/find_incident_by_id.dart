import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/core/usecases/usecase.dart';
import 'package:flutter_application/features/incidents/domain/entities/incident.model.dart';
import 'package:flutter_application/features/incidents/domain/repositories/incident_repository.dart';

class FindIncidentByIdUseCase implements UseCase<IncidentModel, int> {
  final IncidentRepository repository;

  FindIncidentByIdUseCase(this.repository);

  @override
  Future<Either<Failure, IncidentModel>> call(int incidentId) {
    return repository.findById(incidentId);
  }
}
