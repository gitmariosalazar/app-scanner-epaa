// lib/features/scan/data/models/reading_info_response.dart
import 'package:json_annotation/json_annotation.dart';

part 'reading_info_response.g.dart';

@JsonSerializable()
class Phone {
  @JsonKey(name: 'telefonoid')
  final int telefonoid;

  @JsonKey(name: 'numero')
  final String numero;

  Phone({required this.telefonoid, required this.numero});

  factory Phone.fromJson(Map<String, dynamic> json) => _$PhoneFromJson(json);
  Map<String, dynamic> toJson() => _$PhoneToJson(this);
}

@JsonSerializable()
class Email {
  @JsonKey(name: 'correoid')
  final int correoid;

  @JsonKey(name: 'email')
  final String email;

  Email({required this.correoid, required this.email});

  factory Email.fromJson(Map<String, dynamic> json) => _$EmailFromJson(json);
  Map<String, dynamic> toJson() => _$EmailToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ReadingInfoResponse {
  @JsonKey(name: 'readingId')
  final int readingId;

  @JsonKey(name: 'previousReadingDate', defaultValue: null)
  final String? previousReadingDate;

  @JsonKey(name: 'readingTime', defaultValue: null)
  final String? readingTime;

  @JsonKey(name: 'cadastralKey')
  final String cadastralKey;

  @JsonKey(name: 'cardId')
  final String cardId;

  @JsonKey(name: 'clientName')
  final String clientName;

  @JsonKey(name: 'clientPhones', defaultValue: <Phone>[])
  final List<Phone> clientPhones;

  @JsonKey(name: 'clientEmails', defaultValue: <Email>[])
  final List<Email> clientEmails;

  @JsonKey(name: 'address')
  final String address;

  @JsonKey(name: 'previousReading')
  final String previousReading;

  @JsonKey(name: 'currentReading', defaultValue: null)
  final String? currentReading;

  @JsonKey(name: 'sector')
  final int sector;

  @JsonKey(name: 'account')
  final int account;

  @JsonKey(name: 'readingValue', defaultValue: '')
  final String readingValue;

  @JsonKey(name: 'averageConsumption', defaultValue: '')
  final String averageConsumption;

  @JsonKey(name: 'meterNumber', defaultValue: null)
  final String? meterNumber;

  @JsonKey(name: 'rateId')
  final int rateId;

  @JsonKey(name: 'rateName')
  final String rateName;

  @JsonKey(name: 'hasCurrentReading', defaultValue: false)
  final bool hasCurrentReading;

  ReadingInfoResponse({
    required this.readingId,
    this.previousReadingDate,
    this.readingTime,
    required this.cadastralKey,
    required this.cardId,
    required this.clientName,
    required this.clientPhones,
    required this.clientEmails,
    required this.address,
    required this.previousReading,
    this.currentReading,
    required this.sector,
    required this.account,
    this.readingValue = '',
    required this.averageConsumption,
    required this.meterNumber,
    required this.rateId,
    required this.rateName,
    required this.hasCurrentReading,
  });

  factory ReadingInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$ReadingInfoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReadingInfoResponseToJson(this);
}
