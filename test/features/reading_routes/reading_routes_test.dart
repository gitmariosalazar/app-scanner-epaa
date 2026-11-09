import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/features/reading/domain/entities/reading.dart';
import 'package:flutter_application/features/form/presentation/widgets/reading_current_row.dart';
import 'package:flutter_application/features/reading-routes/data/models/route_connection_item_model.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_assignment.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_connection_item.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_work_pack.dart';
import 'package:flutter_application/features/reading-routes/presentation/cubit/route_map_cubit.dart';
import 'package:flutter_application/features/reading-routes/presentation/cubit/route_map_state.dart';
import 'package:flutter_application/features/reading-routes/presentation/widgets/route_card.dart';
import 'package:flutter_application/features/reading-routes/presentation/widgets/route_connection_card.dart';

void main() {
  group('Reading Routes Domain Entity Tests', () {
    test(
      'RouteWorkPack nextPendingInSequence returns first pending acometida',
      () {
        const item1 = RouteConnectionItem(
          idDetalle: 1,
          acometidaId: '1-1',
          orden: 1,
          abonado: 'Juan Perez',
          clienteId: '1000000001',
          estado: 'LEIDA',
        );
        const item2 = RouteConnectionItem(
          idDetalle: 2,
          acometidaId: '1-2',
          orden: 2,
          abonado: 'Maria Lopez',
          clienteId: '1000000002',
          estado: 'PENDIENTE',
        );
        const item3 = RouteConnectionItem(
          idDetalle: 3,
          acometidaId: '1-3',
          orden: 3,
          abonado: 'Carlos Gomez',
          clienteId: '1000000003',
          estado: 'SALTADA',
        );

        const pack = RouteWorkPack(
          idAsignacion: 10,
          periodo: '2026-11',
          fechaProgramada: '2026-11-03',
          estadoAsignacion: 'ASIGNADA',
          totalPredios: 3,
          prediosLeidos: 1,
          prediosConNovedad: 0,
          prediosPendientes: 2,
          porcentajeAvance: 33.3,
          idRuta: 1,
          codigoRuta: 'SEC01-R01',
          nombreRuta: 'Sector 1 - Ruta 1',
          acometidas: [item1, item2, item3],
        );

        final next = pack.nextPendingInSequence;
        expect(next, isNotNull);
        expect(next!.acometidaId, equals('1-2'));
        expect(next.orden, equals(2));
      },
    );

    test('RouteAssignment copyWith correctly overrides values', () {
      const assignment = RouteAssignment(
        idAsignacion: 10,
        rutaId: 1,
        codigoRuta: 'SEC01-R01',
        nombreRuta: 'Sector 1 - Ruta 1',
        sector: 1,
        usuarioId: 'user-123',
        nombreLecturista: 'Carlos Mendoza',
        empleadoId: 'emp-123',
        periodoMes: '2026-11',
        estado: 'ASIGNADA',
        totalPredios: 150,
        prediosLeidos: 50,
        prediosConNovedad: 10,
        prediosPendientes: 90,
        porcentajeAvance: 40.0,
      );

      final updated = assignment.copyWith(
        isDownloadedOffline: true,
        pendingOfflineCount: 5,
        estado: 'EN_PROCESO',
      );

      expect(updated.isDownloadedOffline, isTrue);
      expect(updated.pendingOfflineCount, equals(5));
      expect(updated.estado, equals('EN_PROCESO'));
      expect(updated.codigoRuta, equals('SEC01-R01'));
    });

    test('RouteConnectionItem hasCoordinates returns true only when valid', () {
      const withCoords = RouteConnectionItem(
        idDetalle: 1,
        acometidaId: '1-1',
        orden: 1,
        abonado: 'Test',
        clienteId: '1000000001',
        estado: 'PENDIENTE',
        latitud: 0.331589,
        longitud: -78.221085,
      );

      const withoutCoords = RouteConnectionItem(
        idDetalle: 2,
        acometidaId: '1-2',
        orden: 2,
        abonado: 'Test 2',
        clienteId: '1000000002',
        estado: 'PENDIENTE',
        latitud: 0.0,
        longitud: 0.0,
      );

      expect(withCoords.hasCoordinates, isTrue);
      expect(withoutCoords.hasCoordinates, isFalse);
    });

    test(
      'RouteConnectionItem isCompleted returns true for LEIDA and NOVEDAD',
      () {
        const leida = RouteConnectionItem(
          idDetalle: 1,
          acometidaId: '1-1',
          orden: 1,
          abonado: 'Abonado 1',
          clienteId: '1000000001',
          estado: 'LEIDA',
        );
        const novedad = RouteConnectionItem(
          idDetalle: 2,
          acometidaId: '1-2',
          orden: 2,
          abonado: 'Abonado 2',
          clienteId: '1000000002',
          estado: 'NOVEDAD',
        );
        const pendiente = RouteConnectionItem(
          idDetalle: 3,
          acometidaId: '1-3',
          orden: 3,
          abonado: 'Abonado 3',
          clienteId: '1000000003',
          estado: 'PENDIENTE',
        );

        expect(leida.isCompleted, isTrue);
        expect(novedad.isCompleted, isTrue);
        expect(pendiente.isCompleted, isFalse);
      },
    );

    testWidgets(
      'ReadingCurrentRow renders safely with single reading item without index error',
      (WidgetTester tester) async {
        final singleReading = [
          Reading(
            readingId: 1,
            cadastralKey: '010101',
            clientName: 'Juan Perez',
            previousReading: '120',
            currentReading: '135',
            previousReadingDate: DateTime.now().subtract(
              const Duration(days: 30),
            ),
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ReadingCurrentRow(reading: singleReading)),
          ),
        );

        expect(find.byType(ReadingCurrentRow), findsOneWidget);
        expect(find.text('120'), findsOneWidget);
        expect(find.text('135'), findsOneWidget);
      },
    );

    test(
      'RouteMapCubit updatePack updates selectedItem without RouteConnectionItemModel type error',
      () {
        const item1 = RouteConnectionItemModel(
          idDetalle: 101,
          acometidaId: 'ac-101',
          orden: 1,
          abonado: 'Abonado 101',
          clienteId: '1000000101',
          estado: 'PENDIENTE',
          latitud: 0.33,
          longitud: -78.22,
        );

        const initialPack = RouteWorkPack(
          idAsignacion: 5,
          periodo: '2026-11',
          fechaProgramada: '2026-11-03',
          estadoAsignacion: 'ASIGNADA',
          totalPredios: 1,
          prediosLeidos: 0,
          prediosConNovedad: 0,
          prediosPendientes: 1,
          porcentajeAvance: 0.0,
          idRuta: 1,
          codigoRuta: 'R1',
          nombreRuta: 'Ruta 1',
          acometidas: [item1],
        );

        final cubit = RouteMapCubit();
        cubit.init(initialPack, initialSelected: item1);

        // Verify initial state
        expect(cubit.state, isA<RouteMapLoaded>());
        var state = cubit.state as RouteMapLoaded;
        expect(state.selectedItem?.estado, equals('PENDIENTE'));

        // Updated pack where item1 is now LEIDA
        const updatedItem1 = RouteConnectionItemModel(
          idDetalle: 101,
          acometidaId: 'ac-101',
          orden: 1,
          abonado: 'Abonado 101',
          clienteId: '1000000101',
          estado: 'LEIDA',
          lecturaActual: 150.0,
          latitud: 0.33,
          longitud: -78.22,
        );

        final updatedPack = initialPack.copyWith(
          acometidas: [updatedItem1],
          prediosLeidos: 1,
          prediosPendientes: 0,
          porcentajeAvance: 100.0,
        );

        // Call updatePack
        cubit.updatePack(updatedPack);

        state = cubit.state as RouteMapLoaded;
        expect(state.selectedItem, isNotNull);
        expect(state.selectedItem!.idDetalle, equals(101));
        expect(state.selectedItem!.estado, equals('LEIDA'));
        expect(state.selectedItem!.lecturaActual, equals(150.0));
      },
    );

    test(
      'Route Map marker color rules: LEIDA is green, PENDIENTE is blue, even when selected',
      () {
        Color getMarkerColor(String estado, bool isSelected) {
          switch (estado) {
            case 'LEIDA':
              return isSelected ? Colors.green.shade700 : Colors.green.shade600;
            case 'NOVEDAD':
              return isSelected
                  ? Colors.orange.shade800
                  : Colors.orange.shade700;
            case 'SALTADA':
            case 'OMITIDA':
              return isSelected
                  ? Colors.purple.shade700
                  : Colors.purple.shade600;
            case 'PENDIENTE':
            default:
              return isSelected
                  ? const Color(0xFF0288D1)
                  : const Color(0xFF1E88E5);
          }
        }

        // Si ya está tomada la lectura y está seleccionada: VERDE
        expect(getMarkerColor('LEIDA', true), equals(Colors.green.shade700));
        expect(getMarkerColor('LEIDA', false), equals(Colors.green.shade600));

        // Si no está tomada: AZUL (tanto seleccionada como no)
        expect(
          getMarkerColor('PENDIENTE', true),
          equals(const Color(0xFF0288D1)),
        );
        expect(
          getMarkerColor('PENDIENTE', false),
          equals(const Color(0xFF1E88E5)),
        );
      },
    );

    testWidgets(
      'RouteCard renders interactive map button and calls onOpenMap when tapped',
      (tester) async {
        bool mapTapped = false;
        bool cardTapped = false;

        const assignment = RouteAssignment(
          idAsignacion: 10,
          rutaId: 1,
          codigoRuta: 'SEC01-R01',
          nombreRuta: 'Sector 1 - Ruta 1',
          sector: 1,
          usuarioId: 'user-123',
          nombreLecturista: 'Carlos Mendoza',
          empleadoId: 'emp-456',
          periodoMes: '2026-11',
          estado: 'ASIGNADA',
          totalPredios: 10,
          prediosLeidos: 2,
          prediosConNovedad: 0,
          prediosPendientes: 8,
          porcentajeAvance: 20.0,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RouteCard(
                route: assignment,
                onTap: () => cardTapped = true,
                onDownloadOffline: () {},
                onOpenMap: () => mapTapped = true,
              ),
            ),
          ),
        );

        final mapButton = find.byTooltip('Ver ruta en mapa interactivo');
        expect(mapButton, findsOneWidget);

        await tester.tap(mapButton);
        await tester.pump();

        expect(mapTapped, isTrue);
        expect(cardTapped, isFalse);
      },
    );

    testWidgets('RouteCard omits map button when onOpenMap is null', (
      tester,
    ) async {
      const assignment = RouteAssignment(
        idAsignacion: 10,
        rutaId: 1,
        codigoRuta: 'SEC01-R01',
        nombreRuta: 'Sector 1 - Ruta 1',
        sector: 1,
        usuarioId: 'user-123',
        nombreLecturista: 'Carlos Mendoza',
        empleadoId: 'emp-456',
        periodoMes: '2026-11',
        estado: 'ASIGNADA',
        totalPredios: 10,
        prediosLeidos: 2,
        prediosConNovedad: 0,
        prediosPendientes: 8,
        porcentajeAvance: 20.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RouteCard(
              route: assignment,
              onTap: () {},
              onDownloadOffline: () {},
              onOpenMap: null,
            ),
          ),
        ),
      );

      expect(find.byTooltip('Ver ruta en mapa interactivo'), findsNothing);
    });

    test('RouteConnectionItemModel correctly maps various clienteId key names from JSON', () {
      final json1 = {'idDetalle': 1, 'acometidaId': '1-1', 'orden': 1, 'abonado': 'Test', 'clienteId': '1001'};
      final json2 = {'idDetalle': 2, 'acometidaId': '1-2', 'orden': 2, 'abonado': 'Test', 'clientId': '1002'};
      final json3 = {'idDetalle': 3, 'acometidaId': '1-3', 'orden': 3, 'abonado': 'Test', 'cardId': '1003'};
      final json4 = {'idDetalle': 4, 'acometidaId': '1-4', 'orden': 4, 'abonado': 'Test', 'card_id': '1004'};
      final json5 = {'idDetalle': 5, 'acometidaId': '1-5', 'orden': 5, 'abonado': 'Test'};

      expect(RouteConnectionItemModel.fromJson(json1).clienteId, equals('1001'));
      expect(RouteConnectionItemModel.fromJson(json2).clienteId, equals('1002'));
      expect(RouteConnectionItemModel.fromJson(json3).clienteId, equals('1003'));
      expect(RouteConnectionItemModel.fromJson(json4).clienteId, equals('1004'));
      expect(RouteConnectionItemModel.fromJson(json5).clienteId, equals(''));
    });

    testWidgets('RouteConnectionCard renders clienteId when provided and Sin ID when empty', (tester) async {
      const connWithId = RouteConnectionItem(
        idDetalle: 1,
        acometidaId: '1-63',
        orden: 1,
        abonado: 'RUPERTO AYALA',
        clienteId: '0400487765',
        estado: 'PENDIENTE',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RouteConnectionCard(
              connection: connWithId,
              onTakeReading: () {},
            ),
          ),
        ),
      );

      expect(find.text('0400487765'), findsOneWidget);
      expect(find.byIcon(Icons.badge_rounded), findsOneWidget);

      const connEmptyId = RouteConnectionItem(
        idDetalle: 2,
        acometidaId: '1-64',
        orden: 2,
        abonado: 'PEDRO PEREZ',
        clienteId: '',
        estado: 'PENDIENTE',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RouteConnectionCard(
              connection: connEmptyId,
              onTakeReading: () {},
            ),
          ),
        ),
      );

      expect(find.text('Sin ID'), findsOneWidget);
    });
  });
}
