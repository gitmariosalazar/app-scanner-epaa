import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/observations/domain/entities/observation_entity.dart';

abstract class ObservationRepository {
  Future<Either<Failure, List<ObservationEntity>>> findAllObservations();
  Future<Either<Failure, List<ObservationEntity>>>
  findObservationsByCadastralKey(String connectionId);
}
