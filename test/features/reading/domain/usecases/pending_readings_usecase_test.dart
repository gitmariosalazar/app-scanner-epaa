import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/reading/domain/entities/pending_connection_location.dart';
import 'package:flutter_application/features/reading/domain/entities/pending_reading_connection.dart';
import 'package:flutter_application/features/reading/domain/entities/pending_reading_history.dart';
import 'package:flutter_application/features/reading/domain/repositories/pending_reading_repository.dart';
import 'package:flutter_application/features/reading/domain/usecases/filter_pending_readings_usecase.dart';
import 'package:flutter_application/features/reading/domain/usecases/get_pending_readings_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class MockPendingReadingRepository implements PendingReadingRepository {
  List<PendingReadingConnection> data = [];
  Failure? failure;
  LecturistLocation? lastLocationCalled;

  @override
  Future<Either<Failure, List<PendingReadingConnection>>>
  getPendingReadingsByMonth({
    required String month,
    int? sector,
    LecturistLocation? location,
  }) async {
    lastLocationCalled = location;
    if (failure != null) return Left(failure!);
    return Right(data);
  }
}

void main() {
  late MockPendingReadingRepository repository;
  late GetPendingReadingsUseCase getPendingReadingsUseCase;
  late FilterPendingReadingsUseCase filterUseCase;

  final sampleConnection1 = PendingReadingConnection(
    cadastralKey: '0101-001',
    meterNumber: 'M-1001',
    address: 'Av. Central 123',
    sector: 1,
    account: 101,
    clientName: 'Juan Perez',
    cardId: '0102030405',
    rateName: 'Residencial',
    averageConsumption: 14.5,
    locationConnection: const PendingConnectionLocation(lat: -1.2, lng: -78.4),
    lastReading: const PendingReadingHistory(
      readingId: 501,
      connectionId: '0101-001',
      readingYear: 2026,
      readingMonth: 'OCTUBRE',
      previousReading: 120,
      currentReading: 135,
      consumption: 15,
      observation: 'Sin novedad',
    ),
  );

  final sampleConnection2 = PendingReadingConnection(
    cadastralKey: '0202-002',
    meterNumber: 'M-2002',
    address: 'Calle Los Andes 456',
    sector: 2,
    account: 202,
    clientName: 'Maria Rodriguez',
    cardId: '0203040506',
    rateName: 'Comercial',
    averageConsumption: 28.0,
    locationConnection: null,
    lastReading: null,
  );

  setUp(() {
    repository = MockPendingReadingRepository();
    getPendingReadingsUseCase = GetPendingReadingsUseCase(repository);
    filterUseCase = FilterPendingReadingsUseCase();
  });

  group('GetPendingReadingsUseCase', () {
    test('debe retornar ValidationFailure si el mes está vacío', () async {
      final result = await getPendingReadingsUseCase(
        const PendingReadingsParams(month: ''),
      );

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Debería fallar con ValidationFailure'),
      );
    });

    test(
      'debe retornar lista de acometidas pendientes cuando el repo responde exitosamente',
      () async {
        repository.data = [sampleConnection1, sampleConnection2];

        const location = LecturistLocation(latitude: -1.25, longitude: -78.45);
        final result = await getPendingReadingsUseCase(
          const PendingReadingsParams(
            month: '2026-10',
            sector: 1,
            location: location,
          ),
        );

        expect(result.isRight(), true);
        expect(repository.lastLocationCalled, location);
        result.fold((_) => fail('Debería retornar Right'), (list) {
          expect(list.length, 2);
          expect(list.first.cadastralKey, '0101-001');
          expect(list.first.lastReading?.consumption, 15);
        });
      },
    );
  });

  group('FilterPendingReadingsUseCase (OCP / Strategy)', () {
    final list = [sampleConnection1, sampleConnection2];

    test('filtra por clave catastral correctamente', () {
      final result = filterUseCase.execute(
        list,
        const PendingFilterCriteria(searchTerm: '0101'),
      );
      expect(result.length, 1);
      expect(result.first.cadastralKey, '0101-001');
    });

    test('filtra por nombre de cliente insensible a mayúsculas/minúsculas', () {
      final result = filterUseCase.execute(
        list,
        const PendingFilterCriteria(searchTerm: 'maria'),
      );
      expect(result.length, 1);
      expect(result.first.clientName, 'Maria Rodriguez');
    });

    test('filtra por número de medidor', () {
      final result = filterUseCase.execute(
        list,
        const PendingFilterCriteria(searchTerm: 'M-1001'),
      );
      expect(result.length, 1);
      expect(result.first.meterNumber, 'M-1001');
    });

    test('filtra por sector', () {
      final result = filterUseCase.execute(
        list,
        const PendingFilterCriteria(sector: 2),
      );
      expect(result.length, 1);
      expect(result.first.sector, 2);
    });

    test('combina búsqueda de texto y sector', () {
      final result1 = filterUseCase.execute(
        list,
        const PendingFilterCriteria(searchTerm: 'Perez', sector: 1),
      );
      expect(result1.length, 1);

      final result2 = filterUseCase.execute(
        list,
        const PendingFilterCriteria(searchTerm: 'Perez', sector: 2),
      );
      expect(result2.length, 0);
    });
  });
}
