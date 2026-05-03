// lib/features/audit/domain/entities/audit_sector.dart
import 'package:equatable/equatable.dart';

/// Domain entity — maps 1:1 to AuditSectorResponse from the backend.
/// No JSON logic here; this belongs to the data layer.
class AuditSector extends Equatable {
  final int auditId;
  final DateTime readingMonth;
  final int sectorId;
  final int expectedTotal;
  final int completedTotal;
  final int pendingTotal;
  final double progressPercentage;
  final bool isComplete;
  final DateTime? closureDate;
  final String? supervisorId;
  final String? observations;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AuditSector({
    required this.auditId,
    required this.readingMonth,
    required this.sectorId,
    required this.expectedTotal,
    required this.completedTotal,
    required this.pendingTotal,
    required this.progressPercentage,
    required this.isComplete,
    this.closureDate,
    this.supervisorId,
    this.observations,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    auditId,
    readingMonth,
    sectorId,
    expectedTotal,
    completedTotal,
    pendingTotal,
    progressPercentage,
    isComplete,
    closureDate,
    supervisorId,
    observations,
    createdAt,
    updatedAt,
  ];
}
