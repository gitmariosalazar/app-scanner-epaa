import 'package:flutter_application/features/observations/domain/entities/observation_entity.dart';
import 'package:flutter_application/utils/date_utils.dart';

class ObservationModel extends ObservationEntity {
  const ObservationModel({
    required super.readingId,
    required super.observationTitle,
    required super.observationDetail,
    required super.registrationDate,
    required super.connectionId,
    required super.previousReading,
    required super.currentReading,
    required super.sector,
    required super.account,
    required super.readingValue,
    required super.noveltyReadingTypeId,
    required super.noveltyTypeName,
    required super.noveltyTypeDescription,
    required super.address,
    required super.observations,
    required super.clientId,
    required super.clientName,
    required super.readingMonth,
    required super.readingDate,
    super.actionRecommended,
  });

  factory ObservationModel.fromJson(Map<String, dynamic> json) {
    String cleanString(dynamic val) {
      if (val == null) return '';
      final str = val.toString().trim();
      return str
          .replaceAll('Ã¡', 'á')
          .replaceAll('Ã©', 'é')
          .replaceAll('Ã­', 'í')
          .replaceAll('Ã³', 'ó')
          .replaceAll('Ãº', 'ú')
          .replaceAll('Ã±', 'ñ')
          .replaceAll('Ã\x81', 'Á')
          .replaceAll('Ã\x89', 'É')
          .replaceAll('Ã\x8D', 'Í')
          .replaceAll('Ã\x93', 'Ó')
          .replaceAll('Ã\x9A', 'Ú')
          .replaceAll('Ã\x91', 'Ñ')
          .replaceAll('Ã', 'Í');
    }

    final firstName = cleanString(json['citizenFirstName']);
    final lastName = cleanString(json['citizenLastName']);
    final citizenName = '$firstName $lastName'.trim();
    final rawClientName = cleanString(json['clientName']);
    final clientName = rawClientName.isNotEmpty ? rawClientName : citizenName;

    final regDate = (json['registrationDate'] ??
            json['observationDate'] ??
            json['readingDate'] ??
            '')
        .toString()
        .trim();

    final detail = cleanString(
      json['observationDetail'] ?? json['observationDetails'] ?? '',
    );

    String? actionRecommended = json['actionRecommended'] != null
        ? cleanString(json['actionRecommended'])
        : null;
    if ((actionRecommended == null || actionRecommended.isEmpty) &&
        detail.contains('Acción recomendada:')) {
      final parts = detail.split('Acción recomendada:');
      if (parts.length > 1) {
        actionRecommended = parts[1].trim();
      }
    }

    double parseDouble(dynamic value) {
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return ObservationModel(
      readingId: json['readingId'] ?? 0,
      observationTitle: cleanString(json['observationTitle']),
      observationDetail: detail,
      registrationDate: regDate,
      connectionId: json['connectionId']?.toString().trim() ?? '',
      previousReading: parseDouble(json['previousReading']),
      currentReading: parseDouble(json['currentReading']),
      sector: json['sector'] ?? 0,
      account: json['account'] ?? 0,
      readingValue: parseDouble(json['readingValue']),
      noveltyReadingTypeId: json['noveltyReadingTypeId'] ?? 0,
      noveltyTypeName: cleanString(json['noveltyTypeName']),
      noveltyTypeDescription: cleanString(json['noveltyTypeDescription']),
      address: cleanString(json['address']),
      observations: cleanString(json['observations']),
      clientId: json['clientId']?.toString().trim() ?? '',
      clientName: clientName,
      readingMonth: json['readingMonth']?.toString().trim() ?? '',
      readingDate: json['readingDate']?.toString().trim() ?? '',
      actionRecommended: actionRecommended,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'readingId': readingId,
      'observationTitle': observationTitle,
      'observationDetail': observationDetail,
      'registrationDate': formatFromIsoDate(registrationDate),
      'connectionId': connectionId,
      'previousReading': previousReading,
      'currentReading': currentReading,
      'sector': sector,
      'account': account,
      'readingValue': readingValue,
      'noveltyReadingTypeId': noveltyReadingTypeId,
      'noveltyTypeName': noveltyTypeName,
      'noveltyTypeDescription': noveltyTypeDescription,
      'address': address,
      'observations': observations,
      'clientId': clientId,
      'clientName': clientName,
      'readingMonth': readingMonth,
      'readingDate': readingDate,
      if (actionRecommended != null) 'actionRecommended': actionRecommended,
    };
  }
}
