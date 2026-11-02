// lib/features/reading/domain/entities/pending_reading_history.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_application/features/reading/domain/entities/pending_connection_location.dart';

/// Representa el historial de la última lectura tomada previamente
/// en una acometida antes del período consultado.
class PendingReadingHistory extends Equatable {
  final int readingId;
  final String connectionId;
  final int? readingYear;
  final String? readingMonth;
  final DateTime? readingDate;
  final String? readingTime;
  final double? previousReading;
  final double? currentReading;
  final double? consumption;
  final String? observation;
  final double? readingValue;
  final PendingConnectionLocation? locationReading;

  const PendingReadingHistory({
    required this.readingId,
    required this.connectionId,
    this.readingYear,
    this.readingMonth,
    this.readingDate,
    this.readingTime,
    this.previousReading,
    this.currentReading,
    this.consumption,
    this.observation,
    this.readingValue,
    this.locationReading,
  });

  @override
  List<Object?> get props => [
        readingId,
        connectionId,
        readingYear,
        readingMonth,
        readingDate,
        readingTime,
        previousReading,
        currentReading,
        consumption,
        observation,
        readingValue,
        locationReading,
      ];
}
