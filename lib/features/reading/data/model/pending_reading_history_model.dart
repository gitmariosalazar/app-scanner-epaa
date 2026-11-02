// lib/features/reading/data/model/pending_reading_history_model.dart
import 'package:flutter_application/features/reading/data/model/pending_connection_location_model.dart';
import 'package:flutter_application/features/reading/domain/entities/pending_reading_history.dart';

class PendingReadingHistoryModel {
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
  final PendingConnectionLocationModel? locationReading;

  const PendingReadingHistoryModel({
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

  factory PendingReadingHistoryModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val, [int fallback = 0]) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? fallback;
      return fallback;
    }

    double? parseDouble(dynamic val) {
      if (val == null) return null;
      if (val is double) return val;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      if (val is String && val.trim().isNotEmpty) {
        return DateTime.tryParse(val.trim());
      }
      return null;
    }

    PendingConnectionLocationModel? parseLocation(dynamic val) {
      if (val is Map<String, dynamic>) {
        return PendingConnectionLocationModel.fromJson(val);
      }
      return null;
    }

    final id = parseInt(json['readingId'] ?? json['reading_id']);
    final connId = (json['connectionId'] ?? json['connection_id'] ?? '').toString();

    return PendingReadingHistoryModel(
      readingId: id,
      connectionId: connId,
      readingYear: json['readingYear'] != null || json['reading_year'] != null
          ? parseInt(json['readingYear'] ?? json['reading_year'])
          : null,
      readingMonth: (json['readingMonth'] ?? json['reading_month'])?.toString(),
      readingDate: parseDate(json['readingDate'] ?? json['reading_date']),
      readingTime: (json['readingTime'] ?? json['reading_time'])?.toString(),
      previousReading: parseDouble(json['previousReading'] ?? json['previous_reading']),
      currentReading: parseDouble(json['currentReading'] ?? json['current_reading']),
      consumption: parseDouble(json['consumption']),
      observation: (json['observation'] ?? json['novedad'])?.toString(),
      readingValue: parseDouble(json['readingValue'] ?? json['reading_value']),
      locationReading: parseLocation(json['locationReading'] ?? json['location_reading']),
    );
  }

  Map<String, dynamic> toJson() => {
        'readingId': readingId,
        'connectionId': connectionId,
        'readingYear': readingYear,
        'readingMonth': readingMonth,
        'readingDate': readingDate?.toIso8601String(),
        'readingTime': readingTime,
        'previousReading': previousReading,
        'currentReading': currentReading,
        'consumption': consumption,
        'observation': observation,
        'readingValue': readingValue,
        'locationReading': locationReading?.toJson(),
      };

  PendingReadingHistory toEntity() => PendingReadingHistory(
        readingId: readingId,
        connectionId: connectionId,
        readingYear: readingYear,
        readingMonth: readingMonth,
        readingDate: readingDate,
        readingTime: readingTime,
        previousReading: previousReading,
        currentReading: currentReading,
        consumption: consumption,
        observation: observation,
        readingValue: readingValue,
        locationReading: locationReading?.toEntity(),
      );
}
