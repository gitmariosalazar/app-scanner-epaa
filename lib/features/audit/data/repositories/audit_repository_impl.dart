// lib/features/audit/data/repositories/audit_repository_impl.dart
//
// Sistema híbrido WebSocket + Polling para auditoría.
// El WS notifica al instante; el polling garantiza consistencia si WS cae.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/exception.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/core/services/polling_service.dart';
import 'package:flutter_application/core/services/websocket_service.dart';
import 'package:flutter_application/features/audit/data/datasources/audit_remote_datasource.dart';
import 'package:flutter_application/features/audit/domain/entities/audit_sector.dart';
import 'package:flutter_application/features/audit/domain/entities/close_audit_sector_result.dart';
import 'package:flutter_application/features/audit/domain/repositories/audit_repository.dart';

class AuditRepositoryImpl implements AuditRepository {
  final AuditRemoteDataSource remoteDataSource;
  final WebSocketService webSocketService;

  /// Polling de respaldo: intervalo conservador porque el WS notificará antes.
  final Duration pollingFallbackInterval;

  // Controladores híbridos por mes
  final _hybridControllers =
      <String, StreamController<List<AuditSector>>>{};
  final _pollingServices =
      <String, PeriodicPollingService<List<AuditSector>>>{};

  AuditRepositoryImpl({
    required this.remoteDataSource,
    required this.webSocketService,
    this.pollingFallbackInterval = const Duration(seconds: 60),
  });

  // Normaliza cualquier formato de mes a 'yyyy-MM' para consistencia
  String _normalizeMonth(String month) {
    // Acepta 'yyyy-MM' o 'yyyy-MM-dd' — siempre retorna 'yyyy-MM'
    if (month.length > 7) return month.substring(0, 7);
    return month;
  }

  // ── Helpers privados ────────────────────────────────────────────────────────

  Future<List<AuditSector>> _fetchAudit(String month) async {
    final normalizedMonth = _normalizeMonth(month);
    final dtos = await remoteDataSource.getAuditByMonth(normalizedMonth);
    return dtos.map((dto) {
      return AuditSector(
        auditId: dto.auditId,
        readingMonth: _parseDate(dto.readingMonth),
        sectorId: dto.sectorId,
        expectedTotal: dto.expectedTotal,
        completedTotal: dto.completedTotal,
        pendingTotal: dto.pendingTotal,
        progressPercentage: dto.progressPercentage,
        isComplete: dto.isComplete,
        closureDate:
            dto.closureDate != null ? _parseDate(dto.closureDate!) : null,
        supervisorId: dto.supervisorId,
        observations: dto.observations,
        createdAt: _parseDate(dto.createdAt),
        updatedAt: _parseDate(dto.updatedAt),
      );
    }).toList();
  }

  // ── AuditRepository ────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<AuditSector>>> getAuditByMonth(
    String month,
  ) async {
    try {
      return Right(await _fetchAudit(month));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error al cargar auditoría: $e'));
    }
  }

  @override
  Stream<List<AuditSector>> watchAuditByMonth(String month) {
    // Siempre operar con 'yyyy-MM' — evita cache duplicado por formato diferente
    final normalizedMonth = _normalizeMonth(month);

    if (_hybridControllers.containsKey(normalizedMonth)) {
      return _hybridControllers[normalizedMonth]!.stream;
    }

    final ctrl = StreamController<List<AuditSector>>.broadcast();
    _hybridControllers[normalizedMonth] = ctrl;

    // ── 1. Carga inicial ────────────────────────────────────────────────────
    _fetchAudit(normalizedMonth).then((sectors) {
      if (!ctrl.isClosed) ctrl.add(sectors);
    });

    // ── 2. WebSocket: refresco al instante en reading:updated y audit:updated
    //
    // reading:updated: NO filtramos por mes porque el backend envía
    // 'previousMonthReading' (mes anterior) en el payload, no el mes actual.
    // Refrescar siempre es seguro: _fetchAudit() siempre pide el mes observado.
    webSocketService.onReadingUpdated.listen(
      (_) async {
        try {
          final sectors = await _fetchAudit(normalizedMonth);
          if (!ctrl.isClosed) ctrl.add(sectors);
        } catch (_) {}
      },
      onError: (e) => debugPrint('[Audit] WS reading error: $e'),
      cancelOnError: false,
    );

    webSocketService.onAuditUpdated.listen(
      (payload) async {
        final payloadMonth = payload.month.length > 7
            ? payload.month.substring(0, 7)
            : payload.month;
        if (payloadMonth != normalizedMonth) return;
        try {
          final sectors = await _fetchAudit(normalizedMonth);
          if (!ctrl.isClosed) ctrl.add(sectors);
        } catch (_) {}
      },
      onError: (e) => debugPrint('[Audit] WS audit error: $e'),
      cancelOnError: false,
    );

    // ── 3. Polling de respaldo (60 s) ───────────────────────────────────────
    final polling = PeriodicPollingService<List<AuditSector>>(
      fetcher: () => _fetchAudit(normalizedMonth),
      interval: pollingFallbackInterval,
    );
    polling.start();
    _pollingServices[month] = polling;

    polling.stream.listen((sectors) {
      if (!ctrl.isClosed) ctrl.add(sectors);
    });

    return ctrl.stream;
  }

  @override
  Future<Either<Failure, CloseAuditSectorResult>> closeSector({
    required int sectorId,
    required String month,
    required String supervisorId,
    String? observations,
  }) async {
    try {
      final dto = await remoteDataSource.closeSector(
        sectorId: sectorId,
        month: month,
        supervisorId: supervisorId,
        observations: observations,
      );

      return Right(
        CloseAuditSectorResult(
          auditId: dto.auditId,
          sectorId: dto.sectorId,
          readingMonth: dto.readingMonth,
          isComplete: dto.isComplete,
          closureDate:
              dto.closureDate != null ? _parseDate(dto.closureDate!) : null,
          supervisorId: dto.supervisorId,
          observations: dto.observations,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Error al cerrar el período de lectura: $e'),
      );
    }
  }

  DateTime _parseDate(String raw) {
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return DateTime.now();
    }
  }
}
