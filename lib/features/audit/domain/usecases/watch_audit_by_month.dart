// lib/features/audit/domain/usecases/watch_audit_by_month.dart
//
// Use case de dominio: expone un Stream reactivo de [List<AuditSector>]
// para el mes dado.
// Principios: SRP / DIP / ISP (misma lógica que WatchDashboardStats).

import 'package:flutter_application/features/audit/domain/entities/audit_sector.dart';
import 'package:flutter_application/features/audit/domain/repositories/audit_repository.dart';

class WatchAuditByMonth {
  final AuditRepository _repository;

  const WatchAuditByMonth(this._repository);

  /// [month] con formato 'YYYY-MM-01'.
  Stream<List<AuditSector>> call(String month) =>
      _repository.watchAuditByMonth(month);
}
