import 'package:flutter_application/features/observations/data/models/observation_model.dart';
import 'package:flutter_application/features/observations/data/datasources/observations_datasource.dart';
import 'package:flutter_application/features/observations/domain/repositories/observation_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';

class ObservationRepositoryImpl implements ObservationRepository {
  final ObservationsDataSource dataSource;

  ObservationRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<ObservationModel>>> findAllObservations() async {
    try {
      final observations = await dataSource.fetchAllObservations();
      return Right(observations);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ObservationModel>>>
  findObservationsByCadastralKey(String connectionId) async {
    try {
      final observations = await dataSource.fetchObservationsByCadastralKey(
        connectionId,
      );
      return Right(observations);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
