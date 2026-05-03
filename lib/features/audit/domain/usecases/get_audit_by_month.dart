// lib/features/audit/domain/usecases/get_audit_by_month.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/core/usecases/usecase.dart';
import 'package:flutter_application/features/audit/domain/entities/audit_sector.dart';
import 'package:flutter_application/features/audit/domain/repositories/audit_repository.dart';

class GetAuditByMonth extends UseCase<List<AuditSector>, AuditParams> {
  final AuditRepository repository;

  GetAuditByMonth(this.repository);

  @override
  Future<Either<Failure, List<AuditSector>>> call(AuditParams params) {
    return repository.getAuditByMonth(params.month);
  }
}

class AuditParams extends Equatable {
  final String month; // Format: 'YYYY-MM'
  const AuditParams({required this.month});

  @override
  List<Object?> get props => [month];
}
