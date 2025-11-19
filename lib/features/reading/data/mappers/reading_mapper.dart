// lib/features/scan/data/mappers/reading_info_mapper.dart
import 'package:flutter_application/features/reading/domain/entities/reading.dart';
import 'package:flutter_application/features/reading/data/model/reading_info_response.dart'
    as dto;

extension ReadingInfoResponseX on dto.ReadingInfoResponse {
  Reading toEntity() {
    return Reading(
      readingId: readingId,
      previousReadingDate: previousReadingDate != null
          ? DateTime.tryParse(previousReadingDate!)
          : null,
      readingTime: readingTime != null ? _parseTime(readingTime!) : null,
      cadastralKey: cadastralKey,
      cardId: cardId,
      clientName: clientName,
      phones: clientPhones.map((p) => Phone(p.numero)).toList(),
      emails: clientEmails.map((e) => Email(e.email)).toList(),
      address: address,
      previousReading: int.tryParse(previousReading.replaceAll('.00', '')) ?? 0,
      currentReading: currentReading != null
          ? int.tryParse(currentReading!.replaceAll('.00', ''))
          : null,
      sector: sector,
      account: account,
      readingValue: double.tryParse(readingValue.replaceAll('.00', '')) ?? 0.0,
      averageConsumption:
          double.tryParse(averageConsumption.replaceAll('.00', '')) ?? 0.0,
      meterNumber: meterNumber ?? '',
      rateId: rateId,
      rateName: rateName,
      hasCurrentReading: hasCurrentReading,
      monthReading: monthReading,
      startDatePeriod: DateTime.tryParse(startDatePeriod) ?? DateTime.now(),
      endDatePeriod: DateTime.tryParse(endDatePeriod) ?? DateTime.now(),
    );
  }

  DateTime? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final now = DateTime.now();
      return DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (e) {
      return null;
    }
  }
}
