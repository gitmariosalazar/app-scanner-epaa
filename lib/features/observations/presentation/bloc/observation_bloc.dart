import 'package:equatable/equatable.dart';
import 'package:flutter_application/features/observations/domain/entities/observation_entity.dart';
import 'package:flutter_application/features/observations/domain/usecases/get_observations_by_cadasralkey_usecase.dart';
import 'package:flutter_application/features/observations/domain/usecases/get_observations_usecase.dart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 👇 Aquí declaras las partes
part 'observation_event.dart';
part 'observation_state.dart';

class ObservationBloc extends Bloc<ObservationEvent, ObservationState> {
  final FindAllObservationsUseCase findAllObservationsUseCase;
  final FindAllObservationsByCadastralKeyUseCase findByCadastralKeyUseCase;

  ObservationBloc(
    this.findAllObservationsUseCase,
    this.findByCadastralKeyUseCase,
  ) : super(ObservationInitial()) {
    on<FindAllObservationsEvent>((event, emit) async {
      emit(ObservationLoading());
      // month example: 2026-02
      final month = DateTime.now().month.toString().padLeft(2, '0');
      final year = DateTime.now().year.toString();
      final result = await findAllObservationsUseCase(
        Params(month: "$year-$month"),
      );

      result.fold(
        (failure) => emit(ObservationError(failure.toString())),
        (observation) => emit(FindAllObservationLoaded(observation)),
      );
    });

    on<FindObservationsByCadastralKeyEvent>((event, emit) async {
      emit(ObservationLoading());
      final result = await findByCadastralKeyUseCase(
        ObservationParams(connectionId: event.connectionId),
      );
      result.fold(
        (failure) => emit(ObservationError(failure.toString())),
        (observations) =>
            emit(GetObservationByCadastralKeyListLoaded(observations)),
      );
    });
  }
}
