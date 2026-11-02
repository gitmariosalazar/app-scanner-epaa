// lib/features/reading/data/model/pending_reading_connection_model.dart
import 'package:flutter_application/features/reading/data/model/pending_connection_location_model.dart';
import 'package:flutter_application/features/reading/data/model/pending_reading_history_model.dart';
import 'package:flutter_application/features/reading/domain/entities/pending_reading_connection.dart';

class PendingReadingConnectionModel {
  final String cadastralKey;
  final String meterNumber;
  final String address;
  final int sector;
  final int account;
  final String clientName;
  final String cardId;
  final String rateName;
  final double averageConsumption;
  final PendingConnectionLocationModel? locationConnection;
  final PendingReadingHistoryModel? lastReading;
  final double? distanceMeters;

  const PendingReadingConnectionModel({
    required this.cadastralKey,
    required this.meterNumber,
    required this.address,
    required this.sector,
    required this.account,
    required this.clientName,
    required this.cardId,
    required this.rateName,
    required this.averageConsumption,
    this.locationConnection,
    this.lastReading,
    this.distanceMeters,
  });

  factory PendingReadingConnectionModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val, [int fallback = 0]) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? fallback;
      return fallback;
    }

    double parseDouble(dynamic val, [double fallback = 0.0]) {
      if (val is double) return val;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? fallback;
      return fallback;
    }

    PendingConnectionLocationModel? parseLocation(dynamic val) {
      if (val is Map<String, dynamic>) {
        return PendingConnectionLocationModel.fromJson(val);
      }
      return null;
    }

    PendingReadingHistoryModel? parseLastReading(dynamic val) {
      if (val is Map<String, dynamic>) {
        return PendingReadingHistoryModel.fromJson(val);
      }
      return null;
    }

    return PendingReadingConnectionModel(
      cadastralKey: (json['cadastralKey'] ?? json['cadastral_key'] ?? '')
          .toString(),
      meterNumber: (json['meterNumber'] ?? json['meter_number'] ?? '')
          .toString(),
      address: (json['address'] ?? json['direccion'] ?? '').toString(),
      sector: parseInt(json['sector']),
      account: parseInt(json['account'] ?? json['cuenta']),
      clientName: (json['clientName'] ?? json['client_name'] ?? 'Sin nombre')
          .toString(),
      cardId: (json['cardId'] ?? json['card_id'] ?? json['cliente_id'] ?? '')
          .toString(),
      rateName: (json['rateName'] ?? json['rate_name'] ?? '').toString(),
      averageConsumption: parseDouble(
        json['averageConsumption'] ?? json['average_consumption'],
      ),
      locationConnection: parseLocation(
        json['locationConnection'] ?? json['location_connection'],
      ),
      lastReading: parseLastReading(
        json['lastReading'] ?? json['last_reading'],
      ),
      distanceMeters: parseDouble(
        json['distanceMeters'] ?? json['distance_meters'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'cadastralKey': cadastralKey,
    'meterNumber': meterNumber,
    'address': address,
    'sector': sector,
    'account': account,
    'clientName': clientName,
    'cardId': cardId,
    'rateName': rateName,
    'averageConsumption': averageConsumption,
    'locationConnection': locationConnection?.toJson(),
    'lastReading': lastReading?.toJson(),
    'distanceMeters': distanceMeters,
  };

  PendingReadingConnection toEntity() => PendingReadingConnection(
    cadastralKey: cadastralKey,
    meterNumber: meterNumber,
    address: address,
    sector: sector,
    account: account,
    clientName: clientName,
    cardId: cardId,
    rateName: rateName,
    averageConsumption: averageConsumption,
    locationConnection: locationConnection?.toEntity(),
    lastReading: lastReading?.toEntity(),
    distanceMeters: distanceMeters,
  );
}
