// lib/features/audit/domain/entities/close_audit_sector_result.dart
import 'package:equatable/equatable.dart';

/// Lightweight result returned after successfully closing a sector audit.
/// Follows SRP: only carries the data needed by the presentation layer.
class CloseAuditSectorResult extends Equatable {
  final int auditId;
  final int sectorId;
  final String readingMonth;
  final bool isComplete;
  final DateTime? closureDate;
  final String? supervisorId;
  final String? observations;

  const CloseAuditSectorResult({
    required this.auditId,
    required this.sectorId,
    required this.readingMonth,
    required this.isComplete,
    this.closureDate,
    this.supervisorId,
    this.observations,
  });

  @override
  List<Object?> get props => [
    auditId,
    sectorId,
    readingMonth,
    isComplete,
    closureDate,
    supervisorId,
    observations,
  ];
}
