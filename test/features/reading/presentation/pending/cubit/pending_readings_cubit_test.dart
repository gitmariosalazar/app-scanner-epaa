import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/reading/domain/entities/pending_reading_connection.dart';
import 'package:flutter_application/features/reading/domain/repositories/pending_reading_repository.dart';
import 'package:flutter_application/features/reading/domain/usecases/filter_pending_readings_usecase.dart';
import 'package:flutter_application/features/reading/domain/usecases/get_pending_readings_usecase.dart';
import 'package:flutter_application/features/reading/presentation/pending/cubit/pending_readings_cubit.dart';
import 'package:flutter_application/features/reading/presentation/pending/cubit/pending_readings_state.dart';
import 'package:flutter_test/flutter_test.dart';

class MockRepo implements PendingReadingRepository {
  List<PendingReadingConnection> data = [];
  Failure? failure;

  @override
  Future<Either<Failure, List<PendingReadingConnection>>>
  getPendingReadingsByMonth({
    required String month,
    int? sector,
    LecturistLocation? location,
  }) async {
    if (failure != null) return Left(failure!);
    return Right(data);
  }
}

void main() {
  late MockRepo mockRepo;
  late GetPendingReadingsUseCase getPendingReadingsUseCase;
  late FilterPendingReadingsUseCase filterPendingReadingsUseCase;
  late PendingReadingsCubit cubit;

  final item1 = const PendingReadingConnection(
    cadastralKey: 'KEY-001',
    meterNumber: 'M-001',
    address: 'Calle 1',
    sector: 1,
    account: 10,
    clientName: 'Carlos Gomez',
    cardId: '11001100',
    rateName: 'Residencial',
    averageConsumption: 12.0,
  );

  final item2 = const PendingReadingConnection(
    cadastralKey: 'KEY-002',
    meterNumber: 'M-002',
    address: 'Calle 2',
    sector: 2,
    account: 20,
    clientName: 'Ana Lopez',
    cardId: '22002200',
    rateName: 'Comercial',
    averageConsumption: 25.0,
  );

  setUp(() {
    mockRepo = MockRepo();
    getPendingReadingsUseCase = GetPendingReadingsUseCase(mockRepo);
    filterPendingReadingsUseCase = FilterPendingReadingsUseCase();
    cubit = PendingReadingsCubit(
      getPendingReadingsUseCase: getPendingReadingsUseCase,
      filterPendingReadingsUseCase: filterPendingReadingsUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('estado inicial es PendingReadingsInitial', () {
    expect(cubit.state, isA<PendingReadingsInitial>());
  });

  test(
    'loadPendingReadings emite Loading y luego Loaded en caso de éxito',
    () async {
      mockRepo.data = [item1, item2];

      final expectedStates = [
        isA<PendingReadingsLoading>(),
        isA<PendingReadingsLoaded>()
            .having((s) => s.allReadings.length, 'allReadings.length', 2)
            .having(
              (s) => s.filteredReadings.length,
              'filteredReadings.length',
              2,
            ),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.loadPendingReadings(month: '2026-10');
    },
  );

  test('search filtra los resultados reactivamente dentro de Loaded', () async {
    mockRepo.data = [item1, item2];
    await cubit.loadPendingReadings(month: '2026-10');

    expect(cubit.state, isA<PendingReadingsLoaded>());

    cubit.search('Carlos');
    final loadedState = cubit.state as PendingReadingsLoaded;
    expect(loadedState.filteredReadings.length, 1);
    expect(loadedState.filteredReadings.first.clientName, 'Carlos Gomez');
  });

  test('filterBySector filtra por sector correctamente', () async {
    mockRepo.data = [item1, item2];
    await cubit.loadPendingReadings(month: '2026-10');

    cubit.filterBySector(2);
    final loadedState = cubit.state as PendingReadingsLoaded;
    expect(loadedState.filteredReadings.length, 1);
    expect(loadedState.filteredReadings.first.sector, 2);
  });

  test('loadPendingReadings emite Error cuando el usecase falla', () async {
    mockRepo.failure = ServerFailure(message: 'Error en servidor', code: 500);

    final expectedStates = [
      isA<PendingReadingsLoading>(),
      isA<PendingReadingsError>().having(
        (s) => s.message,
        'message',
        'Error en servidor',
      ),
    ];

    expectLater(cubit.stream, emitsInOrder(expectedStates));

    await cubit.loadPendingReadings(month: '2026-10');
  });
}
