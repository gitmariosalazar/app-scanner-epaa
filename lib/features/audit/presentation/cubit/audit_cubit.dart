// lib/features/audit/presentation/cubit/audit_cubit.dart
//
// Cubit reactivo para auditoría.
// Gestiona:
//   1. Stream reactivo (polling background) — startWatching()
//   2. Operación de cierre de sector — closeSector()
//   3. Ciclo de vida de la app — WidgetsBindingObserver
//
// Principios SOLID:
//   - SRP: sólo orquesta estados de UI; la lógica de polling vive en el repo.
//   - OCP: nuevo mes → nueva suscripción sin modificar la clase.
//   - DIP: depende de use cases (abstracciones), nunca de datasources.

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/features/audit/domain/entities/audit_sector.dart';
import 'package:flutter_application/features/audit/domain/usecases/close_sector.dart';
import 'package:flutter_application/features/audit/domain/usecases/get_audit_by_month.dart';
import 'package:flutter_application/features/audit/domain/usecases/watch_audit_by_month.dart';
import 'package:intl/intl.dart';
import 'audit_state.dart';

class AuditCubit extends Cubit<AuditState> with WidgetsBindingObserver {
  final GetAuditByMonth _getAuditByMonth;
  final CloseSector _closeSector;
  final WatchAuditByMonth _watchAuditByMonth;

  StreamSubscription? _subscription;

  /// Mes actualmente observado. Nulo si no se ha iniciado el watch.
  String? _watchedMonth;

  AuditCubit(
    this._getAuditByMonth,
    this._closeSector,
    this._watchAuditByMonth,
  ) : super(AuditInitial()) {
    WidgetsBinding.instance.addObserver(this);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Backend requires full date with day: yyyy-MM-01
  String get _currentMonth {
    final now = DateTime.now();
    return '${DateFormat('yyyy-MM').format(now)}-01';
  }

  // ── Inicio y cambio de mes ─────────────────────────────────────────────────

  /// Inicia (o cambia) el stream reactivo para [month].
  /// Si [month] es nulo se usa el mes actual.
  void startWatching({String? month}) {
    final targetMonth = month ?? _currentMonth;

    // Si ya observamos ese mes no hacemos nada (idempotente).
    if (_watchedMonth == targetMonth && _subscription != null) return;

    _cancelSubscription(); // cancelar el mes anterior si existe
    _watchedMonth = targetMonth;
    _subscribeToStream(targetMonth);
  }

  void _subscribeToStream(String month) {
    if (isClosed) return;

    if (state is AuditInitial) {
      emit(AuditLoading());
    }

    _subscription = _watchAuditByMonth(month).listen(
      (sectors) {
        if (!isClosed) emit(AuditLoaded(sectors: sectors, month: month));
      },
      onError: (Object error) {
        if (!isClosed) emit(AuditError(error.toString()));
      },
      cancelOnError: false,
    );
  }

  // ── Fetch puntual (mantiene compatibilidad con código existente) ────────────

  Future<void> loadAudit({String? month}) async {
    if (isClosed) return;
    final targetMonth = month ?? _currentMonth;
    emit(AuditLoading());
    final result = await _getAuditByMonth(AuditParams(month: targetMonth));
    if (isClosed) return;
    result.fold(
      (failure) => emit(AuditError(failure.message)),
      (sectors) => emit(AuditLoaded(sectors: sectors, month: targetMonth)),
    );
  }

  Future<void> refresh({String? month}) => loadAudit(month: month);

  // ── Cierre de sector ───────────────────────────────────────────────────────

  /// Supervised closure of a sector audit.
  /// Emits [SectorClosing] → [SectorClosed] | [SectorCloseError].
  /// On success, the reactive stream auto-updates the list.
  Future<void> closeSector({
    required int sectorId,
    required String month,
    required String supervisorId,
    String? observations,
  }) async {
    if (isClosed) return;

    // Preserve current data while the request is in-flight.
    final currentSectors = _currentSectors;
    emit(SectorClosing(sectorId: sectorId, sectors: currentSectors, month: month));

    final result = await _closeSector(
      CloseSectorParams(
        sectorId: sectorId,
        month: month,
        supervisorId: supervisorId,
        observations: observations,
      ),
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        SectorCloseError(
          message: failure.message,
          sectorId: sectorId,
          sectors: currentSectors,
          month: month,
        ),
      ),
      (closeResult) async {
        // El stream reactivo se actualizará automáticamente en el próximo tick.
        // Forzamos una recarga inmediata para feedback instantáneo.
        await loadAudit(month: month);
        if (!isClosed) {
          emit(
            SectorClosed(
              result: closeResult,
              sectors: currentSectors,
              month: month,
            ),
          );
        }
      },
    );
  }

  // ── AppLifecycle ──────────────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_subscription == null && _watchedMonth != null && !isClosed) {
          _subscribeToStream(_watchedMonth!);
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _cancelSubscription();
        break;
    }
  }

  void _cancelSubscription() {
    _subscription?.cancel();
    _subscription = null;
  }

  // ── Helper: sectores actuales ───────────────────────────────────────────────

  List<AuditSector> get _currentSectors {
    final s = state;
    if (s is AuditLoaded) return s.sectors;
    if (s is SectorClosing) return s.sectors;
    if (s is SectorClosed) return s.sectors;
    if (s is SectorCloseError) return s.sectors;
    return const [];
  }

  // ── Limpieza ────────────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelSubscription();
    return super.close();
  }
}
