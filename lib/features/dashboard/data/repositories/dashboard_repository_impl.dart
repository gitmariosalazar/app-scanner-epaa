// lib/features/dashboard/data/repositories/dashboard_repository_impl.dart
//
// Sistema híbrido WebSocket + Polling:
//   - WebSocket: notificación instantánea cuando hay cambios (< 1 seg)
//   - Polling fallback: refresco periódico si WS no está disponible (60 s)
//
// OCP: watchDashboardStats() cambió su implementación interna sin tocar
// getDashboardStats() ni el contrato del repositorio.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/exception.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/core/services/polling_service.dart';
import 'package:flutter_application/core/services/websocket_service.dart';
import 'package:flutter_application/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:flutter_application/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:flutter_application/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:intl/intl.dart';

// Sector name catalog (local lookup — avoids extra API calls)
const _sectorNames = <int, String>{};

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final WebSocketService webSocketService;

  /// Polling de respaldo para cuando WebSocket no está disponible.
  /// 60 s es conservador; el WS entregará cambios instantáneos.
  final Duration pollingFallbackInterval;

  PeriodicPollingService<DashboardStats>? _pollingService;
  StreamController<DashboardStats>? _hybridController;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.webSocketService,
    this.pollingFallbackInterval = const Duration(seconds: 60),
  });

  // ── Helpers privados ────────────────────────────────────────────────────────

  Future<DashboardStats> _fetchStats() async {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final month = DateFormat('yyyy-MM').format(now);
    final period = DateFormat('MMMM yyyy', 'es_ES').format(now);

    final results = await Future.wait([
      remoteDataSource.getDashboardMetrics(today),
      remoteDataSource.getAdvancedMonthlyReport(month),
    ]);

    final metrics = results[0] as DashboardMetricsDto;
    final sectorReports = results[1] as List<AdvancedReadingReportDto>;

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

    return DashboardStats(
      totalAssigned: totalAssigned,
      totalCompleted: totalCompleted,
      sectorsTotal: sectorProgress.length,
      sectorsCompleted: sectorsCompleted,
      readingsToday: metrics.totalReadingsToday,
      sectorProgress: sectorProgress,
      period: period,
      lastUpdated: now,
    );
  }

  // ── DashboardRepository ────────────────────────────────────────────────────

  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats() async {
    try {
      return Right(await _fetchStats());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Stream<DashboardStats> watchDashboardStats() {
    if (_hybridController != null) return _hybridController!.stream;

    _hybridController = StreamController<DashboardStats>.broadcast();

    // ── 1. Carga inicial inmediata ──────────────────────────────────────────
    _fetchStats().then((stats) {
      if (_hybridController?.isClosed == false) {
        _hybridController!.add(stats);
      }
    });

    // ── 2. WebSocket: notificación instantánea cuando se crea/actualiza ─────
    webSocketService.onReadingUpdated.listen(
      (_) async {
        try {
          final stats = await _fetchStats();
          if (_hybridController?.isClosed == false) {
            _hybridController!.add(stats);
          }
        } catch (_) {}
      },
      onError: (e) => debugPrint('[Dashboard] WS error: $e'),
      cancelOnError: false, // no cancelar el stream por un error puntual
    );

    // ── 3. Polling de respaldo (60 s) — actúa si WS no está disponible ──────
    _pollingService = PeriodicPollingService<DashboardStats>(
      fetcher: _fetchStats,
      interval: pollingFallbackInterval,
      onError: (e, __) {
        if (_hybridController?.isClosed == false) {
          _hybridController!.addError(e);
        }
      },
    );
    _pollingService!.start();

    // Pipe del polling al controller híbrido
    _pollingService!.stream.listen((stats) {
      if (_hybridController?.isClosed == false) {
        _hybridController!.add(stats);
      }
    });

    return _hybridController!.stream;
  }
}
