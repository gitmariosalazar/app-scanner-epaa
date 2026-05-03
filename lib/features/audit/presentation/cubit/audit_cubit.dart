import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/features/audit/domain/entities/audit_sector.dart';
import 'package:flutter_application/features/audit/domain/usecases/close_sector.dart';
import 'package:flutter_application/features/audit/domain/usecases/get_audit_by_month.dart';
import 'package:intl/intl.dart';
import 'audit_state.dart';

class AuditCubit extends Cubit<AuditState> {
  final GetAuditByMonth _getAuditByMonth;
  final CloseSector _closeSector;

  AuditCubit(this._getAuditByMonth, this._closeSector) : super(AuditInitial());

  // Backend requires full date with day: yyyy-MM-01
  String get _currentMonth {
    final now = DateTime.now();
    return '${DateFormat('yyyy-MM').format(now)}-01';
  }

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

  /// Supervised closure of a sector audit.
  /// Emits [SectorClosing] → [SectorClosed] | [SectorCloseError].
  /// On success, refreshes the audit list automatically.
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
        // Refresh so the sector card reflects the new isComplete = true.
        await loadAudit(month: month);
        // After refresh the state is AuditLoaded; bubble up the success result
        // by re-emitting SectorClosed briefly if still mounted.
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

  /// Helper to safely extract sectors from the current state.
  List<AuditSector> get _currentSectors {
    final s = state;
    if (s is AuditLoaded) return s.sectors;
    if (s is SectorClosing) return s.sectors;
    if (s is SectorClosed) return s.sectors;
    if (s is SectorCloseError) return s.sectors;
    return const [];
  }
}
