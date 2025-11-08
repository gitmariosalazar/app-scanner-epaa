// lib/features/scan/domain/entities/reading.dart
import 'package:equatable/equatable.dart';

class Phone extends Equatable {
  final String number;
  const Phone(this.number);
  @override
  List<Object?> get props => [number];
}

class Email extends Equatable {
  final String email;
  const Email(this.email);
  @override
  List<Object?> get props => [email];
}

class Reading extends Equatable {
  final int readingId;
  final DateTime? previousReadingDate;
  final DateTime? readingTime;
  final String cadastralKey;
  final String cardId;
  final String clientName;
  final List<Phone> phones;
  final List<Email> emails;
  final String address;
  final int previousReading;
  final int? currentReading;
  final int sector;
  final int account;
  final double? readingValue;
  final double averageConsumption;
  final String meterNumber;
  final int rateId;
  final String rateName;
  final bool hasCurrentReading;

  const Reading({
    required this.readingId,
    this.previousReadingDate,
    this.readingTime,
    required this.cadastralKey,
    required this.cardId,
    required this.clientName,
    required this.phones,
    required this.emails,
    required this.address,
    required this.previousReading,
    this.currentReading,
    required this.sector,
    required this.account,
    this.readingValue,
    required this.averageConsumption,
    required this.meterNumber,
    required this.rateId,
    required this.rateName,
    required this.hasCurrentReading,
  });

  @override
  List<Object?> get props => [
    readingId,
    previousReadingDate,
    readingTime,
    cadastralKey,
    cardId,
    clientName,
    phones,
    emails,
    address,
    previousReading,
    currentReading,
    sector,
    account,
    readingValue,
    averageConsumption,
    meterNumber,
    rateId,
    rateName,
    hasCurrentReading,
  ];
}
