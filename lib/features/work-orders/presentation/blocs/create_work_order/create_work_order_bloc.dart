import 'package:bloc/bloc.dart';
import 'create_work_order_event.dart';
import 'create_work_order_state.dart';
import '../../../domain/usecases/create_work_order.dart';

class CreateWorkOrderBloc
    extends Bloc<CreateWorkOrderEvent, CreateWorkOrderState> {
  final CreateWorkOrderUseCase createWorkOrder;

  CreateWorkOrderBloc({required this.createWorkOrder})
    : super(CreateWorkOrderInitial()) {
    on<CreateWorkOrderSubmitted>((event, emit) async {
      emit(CreateWorkOrderLoading());
      final result = await createWorkOrder(event.params);
      result.fold(
        (failure) => emit(CreateWorkOrderFailure(message: failure.message)),
        (entity) => emit(CreateWorkOrderSuccess(entity: entity)),
      );
    });
  }
}
