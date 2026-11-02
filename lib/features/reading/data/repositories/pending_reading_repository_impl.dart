// lib/features/reading/data/repositories/pending_reading_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/exception.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/reading/data/datasources/pending_reading_remote_datasource.dart';
import 'package:flutter_application/features/reading/domain/entities/pending_reading_connection.dart';
import 'package:flutter_application/features/reading/domain/repositories/pending_reading_repository.dart';

/// Implementación de infraestructura para el repositorio de acometidas pendientes.
/// Maneja mapeo DTO -> Entidad y transforma excepciones en Failures de dominio.
class PendingReadingRepositoryImpl implements PendingReadingRepository {
  final PendingReadingRemoteDataSource remoteDataSource;

  PendingReadingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PendingReadingConnection>>>
  getPendingReadingsByMonth({
    required String month,
    int? sector,
    LecturistLocation? location,
  }) async {
    try {
      final models = await remoteDataSource.getPendingReadingsByMonth(
        month,
        sector: sector,
        lat: location?.latitude,
        lng: location?.longitude,
      );
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Error inesperado al cargar acometidas pendientes: $e',
        ),
      );
    }
  }
}
