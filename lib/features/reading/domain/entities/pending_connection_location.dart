// lib/features/reading/domain/entities/pending_connection_location.dart
import 'package:equatable/equatable.dart';

/// Coordenadas geográficas asociadas a una acometida o lectura.
class PendingConnectionLocation extends Equatable {
  final double lat;
  final double lng;

  const PendingConnectionLocation({
    required this.lat,
    required this.lng,
  });

  @override
  List<Object?> get props => [lat, lng];
}
