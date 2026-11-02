// lib/features/reading/domain/usecases/get_pending_readings_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/core/usecases/usecase.dart';
import 'package:flutter_application/features/reading/domain/entities/pending_reading_connection.dart';
import 'package:flutter_application/features/reading/domain/repositories/pending_reading_repository.dart';

/// Caso de Uso: Obtener Acometidas Pendientes por Mes y Sector.
/// Cumple con Single Responsibility Principle (SRP) y Dependency Inversion (DIP).
class GetPendingReadingsUseCase
    implements UseCase<List<PendingReadingConnection>, PendingReadingsParams> {
  final PendingReadingRepository repository;

  GetPendingReadingsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PendingReadingConnection>>> call(
    PendingReadingsParams params,
  ) async {
    if (params.month.trim().isEmpty) {
      return Left(
        ValidationFailure(
          message: 'El mes de lectura es obligatorio (YYYY-MM).',
        ),
      );
    }

    return await repository.getPendingReadingsByMonth(
      month: params.month.trim(),
      sector: params.sector,
      location: params.location,
    );
  }
}

class PendingReadingsParams extends Equatable {
  final String month; // Formato esperado: YYYY-MM
  final int? sector;
  final LecturistLocation? location;

  const PendingReadingsParams({
    required this.month,
    this.sector,
    this.location,
  });

  @override
  List<Object?> get props => [month, sector, location];
}
