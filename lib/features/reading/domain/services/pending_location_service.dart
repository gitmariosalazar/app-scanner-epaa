// lib/features/reading/domain/services/pending_location_service.dart
import 'dart:math' as math;
import 'package:flutter_application/features/reading/domain/entities/pending_connection_location.dart';

/// Servicio de dominio para cálculos geográficos y distancias.
/// Implementa lógica pura de negocio (Haversine) cumpliendo con Clean Architecture.
class PendingLocationService {
  const PendingLocationService();

  static const double _earthRadiusMeters = 6371000.0;

  /// Verifica si una ubicación es válida.
  bool isValid(PendingConnectionLocation? loc) {
    if (loc == null) return false;
    if (loc.lat == 0.0 && loc.lng == 0.0) return false;
    return loc.lat >= -90.0 &&
        loc.lat <= 90.0 &&
        loc.lng >= -180.0 &&
        loc.lng <= 180.0;
  }

  /// Calcula la distancia geodésica en metros entre dos ubicaciones (Fórmula de Haversine).
  double? calculateDistance(
    PendingConnectionLocation? loc1,
    PendingConnectionLocation? loc2,
  ) {
    if (!isValid(loc1) || !isValid(loc2)) return null;

    final lat1Rad = loc1!.lat * math.pi / 180.0;
    final lat2Rad = loc2!.lat * math.pi / 180.0;
    final dLat = (loc2.lat - loc1.lat) * math.pi / 180.0;
    final dLng = (loc2.lng - loc1.lng) * math.pi / 180.0;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return _earthRadiusMeters * c;
  }

  /// Formatea la distancia en metros o kilómetros legibles.
  String formatDistance(double? meters) {
    if (meters == null) return '—';
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
    return '${meters.toStringAsFixed(1)} m';
  }

  /// Formatea coordenadas geográficas con precisión decimal estándar.
  String formatCoordinates(PendingConnectionLocation? loc) {
    if (!isValid(loc)) return 'Sin coordenadas';
    return '${loc!.lat.toStringAsFixed(5)}, ${loc.lng.toStringAsFixed(5)}';
  }

  /// Estima tiempo a pie en minutos (velocidad promedio 4.5 km/h ~ 75 m/min).
  String estimateWalkingTime(double? meters) {
    if (meters == null || meters <= 0) return '—';
    final minutes = (meters / 75.0).ceil();
    if (minutes < 1) return '< 1 min a pie';
    return '~$minutes min a pie';
  }

  /// Estima tiempo en vehículo en minutos (velocidad promedio 25 km/h en ciudad ~ 416 m/min).
  String estimateDrivingTime(double? meters) {
    if (meters == null || meters <= 0) return '—';
    final minutes = (meters / 416.0).ceil();
    if (minutes < 1) return '< 1 min en vehículo';
    return '~$minutes min en vehículo';
  }
}
