// lib/features/reading/presentation/pending/cubit/pending_readings_cubit.dart
import 'package:flutter_application/features/reading/domain/repositories/pending_reading_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/features/reading/domain/entities/pending_reading_connection.dart';
import 'package:flutter_application/features/reading/domain/usecases/filter_pending_readings_usecase.dart';
import 'package:flutter_application/features/reading/domain/usecases/get_pending_readings_usecase.dart';
import 'package:geolocator/geolocator.dart';
import 'pending_readings_state.dart';

class PendingReadingsCubit extends Cubit<PendingReadingsState> {
  final GetPendingReadingsUseCase getPendingReadingsUseCase;
  final FilterPendingReadingsUseCase filterPendingReadingsUseCase;

  PendingReadingsCubit({
    required this.getPendingReadingsUseCase,
    required this.filterPendingReadingsUseCase,
  }) : super(const PendingReadingsInitial());

  /// Formatea la fecha actual a YYYY-MM
  static String get defaultMonthString {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month.toString().padLeft(2, '0');
    return '$year-$month';
  }

  Future<LecturistLocation?> _getCurrentLecturistLocation() async {
    try {
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );

      return LecturistLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      // Si falla o se acaba el tiempo, no detiene la carga; continúa sin ordenar por GPS
      return null;
    }
  }

  /// Carga inicial o recarga de acometidas pendientes.
  Future<void> loadPendingReadings({String? month, int? sector}) async {
    final targetMonth = month ?? _currentMonth();
    final targetSector = sector ?? _currentSector();

    emit(PendingReadingsLoading(month: targetMonth, sector: targetSector));

    // Obtiene la ubicación real antes de ejecutar la consulta
    final location = await _getCurrentLecturistLocation();

    final result = await getPendingReadingsUseCase(
      PendingReadingsParams(
        month: targetMonth,
        sector: targetSector,
        location: location,
      ),
    );

    result.fold(
      (failure) {
        emit(
          PendingReadingsError(
            message: failure.message,
            selectedMonth: targetMonth,
            selectedSector: targetSector,
          ),
        );
      },
      (readings) {
        final query = _currentSearchQuery();
        final filtered = _applyFilters(readings, query, targetSector);

        emit(
          PendingReadingsLoaded(
            allReadings: readings,
            filteredReadings: filtered,
            selectedMonth: targetMonth,
            selectedSector: targetSector,
            searchQuery: query,
          ),
        );
      },
    );
  }

  /// Cambia el mes seleccionado y consulta el backend.
  Future<void> changeMonth(String newMonth) async {
    if (newMonth.trim().isEmpty) return;
    await loadPendingReadings(month: newMonth.trim(), sector: _currentSector());
  }

  /// Filtra localmente o consulta por sector.
  void filterBySector(int? sector) {
    final currentState = state;
    if (currentState is PendingReadingsLoaded) {
      final filtered = _applyFilters(
        currentState.allReadings,
        currentState.searchQuery,
        sector,
      );
      emit(
        currentState.copyWith(
          selectedSector: sector,
          clearSector: sector == null,
          filteredReadings: filtered,
        ),
      );
    } else {
      loadPendingReadings(sector: sector);
    }
  }

  /// Búsqueda reactiva por texto (clave catastral, cliente, medidor, etc.).
  void search(String query) {
    final currentState = state;
    if (currentState is PendingReadingsLoaded) {
      final filtered = _applyFilters(
        currentState.allReadings,
        query,
        currentState.selectedSector,
      );
      emit(
        currentState.copyWith(searchQuery: query, filteredReadings: filtered),
      );
    }
  }

  /// Refresca los datos manteniendo los filtros actuales.
  Future<void> refresh() async {
    final currentState = state;
    if (currentState is PendingReadingsLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
      final location = await _getCurrentLecturistLocation();
      final result = await getPendingReadingsUseCase(
        PendingReadingsParams(
          month: currentState.selectedMonth,
          sector: currentState.selectedSector,
          location: location,
        ),
      );

      result.fold(
        (failure) {
          emit(
            PendingReadingsError(
              message: failure.message,
              selectedMonth: currentState.selectedMonth,
              selectedSector: currentState.selectedSector,
            ),
          );
        },
        (readings) {
          final filtered = _applyFilters(
            readings,
            currentState.searchQuery,
            currentState.selectedSector,
          );
          emit(
            currentState.copyWith(
              allReadings: readings,
              filteredReadings: filtered,
              isRefreshing: false,
            ),
          );
        },
      );
    } else {
      await loadPendingReadings();
    }
  }

  // --- Métodos auxiliares de estado ---
  String _currentMonth() {
    final s = state;
    if (s is PendingReadingsLoaded) return s.selectedMonth;
    if (s is PendingReadingsError) return s.selectedMonth;
    if (s is PendingReadingsLoading && s.month != null) return s.month!;
    return defaultMonthString;
  }

  int? _currentSector() {
    final s = state;
    if (s is PendingReadingsLoaded) return s.selectedSector;
    if (s is PendingReadingsError) return s.selectedSector;
    if (s is PendingReadingsLoading) return s.sector;
    return null;
  }

  String _currentSearchQuery() {
    final s = state;
    if (s is PendingReadingsLoaded) return s.searchQuery;
    return '';
  }

  List<PendingReadingConnection> _applyFilters(
    List<PendingReadingConnection> items,
    String query,
    int? sector,
  ) {
    return filterPendingReadingsUseCase.execute(
      items,
      PendingFilterCriteria(searchTerm: query, sector: sector),
    );
  }
}
