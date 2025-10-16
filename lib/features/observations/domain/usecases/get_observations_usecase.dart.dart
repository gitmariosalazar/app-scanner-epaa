import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/core/usecases/usecase.dart';
import 'package:flutter_application/features/observations/domain/entities/observation_entity.dart';
import 'package:flutter_application/features/observations/domain/repositories/observation_repository.dart';

class FindAllObservationsUseCase
    implements UseCase<List<ObservationEntity>, NoParams> {
  final ObservationRepository repository;

  FindAllObservationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ObservationEntity>>> call(NoParams params) async {
    return await repository.findAllObservations();
  }
}

class NoParams {}
