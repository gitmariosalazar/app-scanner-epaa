// lib/features/reading/presentation/pending/cubit/pending_readings_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_application/features/reading/domain/entities/pending_reading_connection.dart';

abstract class PendingReadingsState extends Equatable {
  const PendingReadingsState();

  @override
  List<Object?> get props => [];
}

class PendingReadingsInitial extends PendingReadingsState {
  const PendingReadingsInitial();
}

class PendingReadingsLoading extends PendingReadingsState {
  final String? month;
  final int? sector;

  const PendingReadingsLoading({this.month, this.sector});

  @override
  List<Object?> get props => [month, sector];
}

class PendingReadingsLoaded extends PendingReadingsState {
  final List<PendingReadingConnection> allReadings;
  final List<PendingReadingConnection> filteredReadings;
  final String selectedMonth;
  final int? selectedSector;
  final String searchQuery;
  final bool isRefreshing;

  const PendingReadingsLoaded({
    required this.allReadings,
    required this.filteredReadings,
    required this.selectedMonth,
    this.selectedSector,
    this.searchQuery = '',
    this.isRefreshing = false,
  });

  int get totalCount => filteredReadings.length;
  int get rawTotalCount => allReadings.length;

  /// Retorna la lista ordenada de sectores disponibles en las lecturas cargadas.
  List<int> get availableSectors {
    final set = allReadings.map((e) => e.sector).toSet();
    final list = set.toList()..sort();
    return list;
  }

  PendingReadingsLoaded copyWith({
    List<PendingReadingConnection>? allReadings,
    List<PendingReadingConnection>? filteredReadings,
    String? selectedMonth,
    int? selectedSector,
    bool clearSector = false,
    String? searchQuery,
    bool? isRefreshing,
  }) {
    return PendingReadingsLoaded(
      allReadings: allReadings ?? this.allReadings,
      filteredReadings: filteredReadings ?? this.filteredReadings,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedSector: clearSector ? null : (selectedSector ?? this.selectedSector),
      searchQuery: searchQuery ?? this.searchQuery,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
        allReadings,
        filteredReadings,
        selectedMonth,
        selectedSector,
        searchQuery,
        isRefreshing,
      ];
}

class PendingReadingsError extends PendingReadingsState {
  final String message;
  final String selectedMonth;
  final int? selectedSector;

  const PendingReadingsError({
    required this.message,
    required this.selectedMonth,
    this.selectedSector,
  });

  @override
  List<Object?> get props => [message, selectedMonth, selectedSector];
}
