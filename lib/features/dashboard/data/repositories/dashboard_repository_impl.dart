// lib/features/dashboard/data/repositories/dashboard_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/exception.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:flutter_application/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:flutter_application/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:intl/intl.dart';

// Sector name catalog (local lookup — avoids extra API calls)
const _sectorNames = <int, String>{};

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats() async {
    try {
      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);
      final month = DateFormat('yyyy-MM').format(now);
      final period = DateFormat('MMMM yyyy', 'es_ES').format(now);

      // Parallel requests — respects SRP (each datasource method has 1 job)
      final results = await Future.wait([
        remoteDataSource.getDashboardMetrics(today),
        remoteDataSource.getAdvancedMonthlyReport(month),
      ]);

      final metrics = results[0] as DashboardMetricsDto;
      final sectorReports = results[1] as List<AdvancedReadingReportDto>;

      // Map API → domain entities
      final sectorProgress = sectorReports.map((r) {
        return SectorProgress(
          sectorId: r.sector,
          sectorName: _sectorNames[r.sector] ?? 'Sector ${r.sector}',
          assigned: r.auditTotalEsperado > 0
              ? r.auditTotalEsperado
              : r.totalConnections,
          completed: r.auditTotalCompletadas > 0
              ? r.auditTotalCompletadas
              : r.readingsCompleted,
        );
      }).toList();

      final totalAssigned = sectorProgress.fold(0, (s, e) => s + e.assigned);
      final totalCompleted = sectorProgress.fold(0, (s, e) => s + e.completed);
      final sectorsCompleted = sectorProgress.where((s) => s.isComplete).length;

      return Right(
        DashboardStats(
          totalAssigned: totalAssigned,
          totalCompleted: totalCompleted,
          sectorsTotal: sectorProgress.length,
          sectorsCompleted: sectorsCompleted,
          readingsToday: metrics.totalReadingsToday,
          sectorProgress: sectorProgress,
          period: period,
          lastUpdated: now,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }
}
