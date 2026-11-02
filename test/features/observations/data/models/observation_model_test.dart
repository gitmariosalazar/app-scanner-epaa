import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/features/observations/data/models/observation_model.dart';
import 'package:flutter_application/utils/date_utils.dart';

void main() {
  group('ObservationModel JSON Parsing', () {
    test('correctly parses user API json with clientName, observationDate, and details', () {
      final json = {
        "observationId": 0,
        "observationTitle": "NOVEDAD DETECTADA EN LECTURA ID: 2541293",
        "observationDetails":
            "Consumo extremadamente alto (>200%). Acción recomendada: EMERGENCIA: Inspección inmediata.",
        "observationDate": "2026-10-26T21:28:20.039Z",
        "readingId": 2541293,
        "connectionId": "14-668",
        "previousReading": "71.00",
        "currentReading": "85.00",
        "sector": 14,
        "account": 668,
        "cadastralKey": "",
        "rentalIncomeCode": 0,
        "readingValue": "4.70",
        "noveltyReadingTypeId": 5,
        "noveltyTypeName": "CONSUMO EXCESIVO",
        "noveltyTypeDescription": "Consumo extremadamente alto (>200%).",
        "clientId": "1002103388",
        "address": "12 DE FEBRERO Y GARCÃA MORENO ",
        "clientName": "NANCY ELIZABETH CHAVEZ MAYA ",
        "observations": "",
        "readingMonth": "2026-10",
        "readingDate": "2026-10-26T21:28:24.993Z"
      };

      final model = ObservationModel.fromJson(json);

      // Verify clientName is correctly parsed
      expect(model.clientName, 'NANCY ELIZABETH CHAVEZ MAYA');

      // Verify registrationDate fallback to observationDate
      expect(model.registrationDate, '2026-10-26T21:28:20.039Z');

      // Verify safeFormatDateTime works on the date
      final formatted = safeFormatDateTime(model.registrationDate);
      expect(formatted, contains('26-10-2026'));

      // Verify detail parsed from observationDetails
      expect(
        model.observationDetail,
        'Consumo extremadamente alto (>200%). Acción recomendada: EMERGENCIA: Inspección inmediata.',
      );

      // Verify actionRecommended was extracted
      expect(model.actionRecommended, 'EMERGENCIA: Inspección inmediata.');

      // Verify address encoding fix (GARCÃA -> GARCÍA)
      expect(model.address, '12 DE FEBRERO Y GARCÍA MORENO');
    });
  });
}
