// lib/features/reading/data/model/pending_connection_location_model.dart
import 'package:flutter_application/features/reading/domain/entities/pending_connection_location.dart';

class PendingConnectionLocationModel {
  final double lat;
  final double lng;

  const PendingConnectionLocationModel({
    required this.lat,
    required this.lng,
  });

  factory PendingConnectionLocationModel.fromJson(Map<String, dynamic> json) {
    double parseCoordinate(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return PendingConnectionLocationModel(
      lat: parseCoordinate(json['lat'] ?? json['latitude'] ?? json['y']),
      lng: parseCoordinate(json['lng'] ?? json['longitude'] ?? json['x']),
    );
  }

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
      };

  PendingConnectionLocation toEntity() => PendingConnectionLocation(
        lat: lat,
        lng: lng,
      );
}
