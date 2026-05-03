// lib/features/audit/presentation/cubit/audit_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_application/features/audit/domain/entities/audit_sector.dart';
import 'package:flutter_application/features/audit/domain/entities/close_audit_sector_result.dart';

abstract class AuditState extends Equatable {
  const AuditState();
  @override
  List<Object?> get props => [];
}

class AuditInitial extends AuditState {}

class AuditLoading extends AuditState {}

class AuditLoaded extends AuditState {
  final List<AuditSector> sectors;
  final String month;

  const AuditLoaded({required this.sectors, required this.month});

  @override
  List<Object?> get props => [sectors, month];
}

class AuditError extends AuditState {
  final String message;
  const AuditError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Close Sector states ────────────────────────────────────────────────────────

/// Emitted while the close-sector request is in-flight.
/// Carries [sectorId] so the UI can show per-sector loading.
class SectorClosing extends AuditState {
  final int sectorId;
  final List<AuditSector> sectors; // preserve existing data during operation
  final String month;

  const SectorClosing({
    required this.sectorId,
    required this.sectors,
    required this.month,
  });

  @override
  List<Object?> get props => [sectorId, sectors, month];
}

/// Emitted after a successful closure.
class SectorClosed extends AuditState {
  final CloseAuditSectorResult result;
  final List<AuditSector> sectors; // updated list after closure
  final String month;

  const SectorClosed({
    required this.result,
    required this.sectors,
    required this.month,
  });

  @override
  List<Object?> get props => [result, sectors, month];
}

/// Emitted when the close operation fails.
class SectorCloseError extends AuditState {
  final String message;
  final int sectorId;
  final List<AuditSector> sectors; // preserve data on error
  final String month;

  const SectorCloseError({
    required this.message,
    required this.sectorId,
    required this.sectors,
    required this.month,
  });

  @override
  List<Object?> get props => [message, sectorId, sectors, month];
}
