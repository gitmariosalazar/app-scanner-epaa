// lib/features/reading/domain/entities/pending_reading_connection.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_application/features/reading/domain/entities/pending_connection_location.dart';
import 'package:flutter_application/features/reading/domain/entities/pending_reading_history.dart';

/// Entidad pura de dominio que representa una acometida pendiente
/// de toma de lectura para un período mensual y sector determinado.
class PendingReadingConnection extends Equatable {
  final String cadastralKey;
  final String meterNumber;
  final String address;
  final int sector;
  final int account;
  final String clientName;
  final String cardId;
  final String rateName;
  final double averageConsumption;
  final PendingConnectionLocation? locationConnection;
  final PendingReadingHistory? lastReading;
  final double? distanceMeters;

  const PendingReadingConnection({
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

  @override
  List<Object?> get props => [
    cadastralKey,
    meterNumber,
    address,
    sector,
    account,
    clientName,
    cardId,
    rateName,
    averageConsumption,
    locationConnection,
    lastReading,
    distanceMeters,
  ];
}
