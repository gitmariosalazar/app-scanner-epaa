import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/core/usecases/usecase.dart';
import 'package:flutter_application/features/incidents/domain/entities/incident_detail_row_response.dart';
import 'package:flutter_application/features/incidents/domain/repositories/incident_repository.dart';

class FindIncidentsByConnectionUseCase
    implements UseCase<List<IncidentDetailRowResponse>, String> {
  final IncidentRepository repository;

  FindIncidentsByConnectionUseCase(this.repository);

  @override
  Future<Either<Failure, List<IncidentDetailRowResponse>>> call(
    String connectionId,
  ) {
    return repository.findIncidentsByConnection(connectionId);
  }
}
