// lib/features/reading/domain/repositories/pending_reading_repository.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/reading/domain/entities/pending_reading_connection.dart';

/// Contrato de repositorio de dominio para acometidas pendientes (ISP).
abstract class PendingReadingRepository {
  /// Obtiene la lista de acometidas pendientes de lectura en el mes [month] ('YYYY-MM')
  /// y opcionalmente filtradas por [sector].
  Future<Either<Failure, List<PendingReadingConnection>>>
  getPendingReadingsByMonth({
    required String month,
    int? sector,
    LecturistLocation? location,
  });
}

class LecturistLocation {
  final double latitude;
  final double longitude;

  const LecturistLocation({required this.latitude, required this.longitude});
}
