// lib/features/audit/domain/usecases/close_sector.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/audit/domain/entities/close_audit_sector_result.dart';
import 'package:flutter_application/features/audit/domain/repositories/audit_repository.dart';

/// Parameters for the CloseSector use-case.
/// Encapsulated to keep the use-case signature stable (OCP).
class CloseSectorParams extends Equatable {
  final int sectorId;
  final String month;
  final String supervisorId;
  final String? observations;

  const CloseSectorParams({
    required this.sectorId,
    required this.month,
    required this.supervisorId,
    this.observations,
  });

  @override
  List<Object?> get props => [sectorId, month, supervisorId, observations];
}

/// Use-case: supervised closure of a reading-audit sector.
/// SRP — single responsibility: delegate to repository, return result.
/// DIP — depends on abstraction [AuditRepository], not a concrete class.
class CloseSector {
  final AuditRepository _repository;

  const CloseSector(this._repository);

  Future<Either<Failure, CloseAuditSectorResult>> call(
    CloseSectorParams params,
  ) {
    return _repository.closeSector(
      sectorId: params.sectorId,
      month: params.month,
      supervisorId: params.supervisorId,
      observations: params.observations,
    );
  }
}
