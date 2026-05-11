// lib/features/dashboard/domain/usecases/watch_dashboard_stats.dart
//
// Use case de dominio: expone un Stream reactivo de [DashboardStats].
// Principios:
//   - SRP: única responsabilidad → proveer el stream al cubit.
//   - DIP: depende de la abstracción [DashboardRepository], nunca de la impl.
//   - ISP: firmado sobre su propio contrato, sin mezclar con GetDashboardStats.

import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:flutter_application/features/dashboard/domain/repositories/dashboard_repository.dart';

class WatchDashboardStats {
  final DashboardRepository _repository;

  const WatchDashboardStats(this._repository);

  /// Retorna un [Stream] de [DashboardStats] que el repositorio actualiza
  /// periódicamente. Los errores son mapeados a [Failure] para que la capa
  /// de presentación no dependa de excepciones concretas.
  Stream<DashboardStats> call() => _repository.watchDashboardStats();
}
