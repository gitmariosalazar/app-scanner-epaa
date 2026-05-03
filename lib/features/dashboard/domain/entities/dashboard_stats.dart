// lib/features/dashboard/domain/entities/dashboard_stats.dart
import 'package:equatable/equatable.dart';

class SectorProgress extends Equatable {
  final int sectorId;
  final String sectorName;
  final int assigned;
  final int completed;

  const SectorProgress({
    required this.sectorId,
    required this.sectorName,
    required this.assigned,
    required this.completed,
  });

  double get percentage => assigned > 0 ? completed / assigned : 0.0;
  bool get isComplete => completed >= assigned && assigned > 0;
  int get remaining => assigned - completed;

  @override
  List<Object?> get props => [sectorId, sectorName, assigned, completed];
}

class DashboardStats extends Equatable {
  final int totalAssigned;
  final int totalCompleted;
  final int sectorsTotal;
  final int sectorsCompleted;
  final int readingsToday;
  final List<SectorProgress> sectorProgress;
  final String period;
  final DateTime lastUpdated;

  const DashboardStats({
    required this.totalAssigned,
    required this.totalCompleted,
    required this.sectorsTotal,
    required this.sectorsCompleted,
    required this.readingsToday,
    required this.sectorProgress,
    required this.period,
    required this.lastUpdated,
  });

  double get overallProgress =>
      totalAssigned > 0 ? totalCompleted / totalAssigned : 0.0;
  int get remaining => totalAssigned - totalCompleted;
  double get completionPercent => overallProgress * 100;

  @override
  List<Object?> get props => [
    totalAssigned,
    totalCompleted,
    sectorsTotal,
    sectorsCompleted,
    readingsToday,
    sectorProgress,
    period,
    lastUpdated,
  ];
}
