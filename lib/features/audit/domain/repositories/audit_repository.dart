// lib/features/audit/domain/repositories/audit_repository.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/audit/domain/entities/audit_sector.dart';
import 'package:flutter_application/features/audit/domain/entities/close_audit_sector_result.dart';

/// OCP: New audit operations can be added without touching existing use-cases.
abstract class AuditRepository {
  /// Fetch puntual — conservado para compatibilidad (OCP).
  Future<Either<Failure, List<AuditSector>>> getAuditByMonth(String month);

  /// Stream reactivo: emite nuevos datos periódicamente para [month].
  Stream<List<AuditSector>> watchAuditByMonth(String month);

  /// Supervised closure of a sector audit.
  /// Returns [CloseAuditSectorResult] on success.
  Future<Either<Failure, CloseAuditSectorResult>> closeSector({
    required int sectorId,
    required String month,
    required String supervisorId,
    String? observations,
  });
}
