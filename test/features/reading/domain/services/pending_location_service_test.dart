import 'package:flutter_application/features/reading/domain/entities/pending_connection_location.dart';
import 'package:flutter_application/features/reading/domain/services/pending_location_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = PendingLocationService();

  group('PendingLocationService', () {
    test('isValid verifica correctamente coordenadas válidas y nulas/cero', () {
      expect(service.isValid(null), false);
      expect(service.isValid(const PendingConnectionLocation(lat: 0.0, lng: 0.0)), false);
      expect(service.isValid(const PendingConnectionLocation(lat: 91.0, lng: 0.0)), false);
      expect(service.isValid(const PendingConnectionLocation(lat: 0.3344, lng: -78.2144)), true);
    });

    test('calculateDistance retorna distancia aproximada correcta', () {
      // Coordenadas con diferencia conocida (~111 metros por 0.001 grado latitud)
      const loc1 = PendingConnectionLocation(lat: 0.3340, lng: -78.2140);
      const loc2 = PendingConnectionLocation(lat: 0.3350, lng: -78.2140);

      final distance = service.calculateDistance(loc1, loc2);
      expect(distance, isNotNull);
      expect(distance!, greaterThan(100));
      expect(distance, lessThan(125));
    });

    test('calculateDistance retorna null si alguna coordenada es inválida', () {
      const locValid = PendingConnectionLocation(lat: 0.3340, lng: -78.2140);
      expect(service.calculateDistance(locValid, null), isNull);
      expect(
        service.calculateDistance(
          locValid,
          const PendingConnectionLocation(lat: 0.0, lng: 0.0),
        ),
        isNull,
      );
    });

    test('formatDistance formatea en metros y kilómetros', () {
      expect(service.formatDistance(null), '—');
      expect(service.formatDistance(45.5), '45.5 m');
      expect(service.formatDistance(1250.0), '1.25 km');
    });

    test('estimateWalkingTime y estimateDrivingTime retornan texto estimado', () {
      expect(service.estimateWalkingTime(300), '~4 min a pie');
      expect(service.estimateDrivingTime(1000), '~3 min en vehículo');
    });
  });
}
