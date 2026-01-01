// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application/features/properties/list/domain/usecases/get_connection_with_properties.dart';

import 'manually_connection_with_properties_event.dart';
import 'manually_connection_with_properties_state.dart';

class ManuallyConnectionWithPropertiesBloc
    extends
        Bloc<
          ManuallyConnectionWithPropertiesEvent,
          ManuallyConnectionWithPropertiesState
        > {
  final GetConnectionWithProperties getConnectionWithProperties;

  ManuallyConnectionWithPropertiesBloc(this.getConnectionWithProperties)
    : super(ManuallyConnectionWithPropertiesInitial()) {
    on<FetchManuallyConnectionWithPropertiesEvent>(
      _onFetchConnectionWithPropertiesEvent,
    );
  }

  Future<void> _onFetchConnectionWithPropertiesEvent(
    FetchManuallyConnectionWithPropertiesEvent event,
    Emitter emit,
  ) async {
    emit(ManuallyConnectionWithPropertiesLoading());
    try {
      final connection = await getConnectionWithProperties(event.cadastralKey);
      debugPrint('Fetched connection: $connection');
      emit(ManuallyConnectionWithPropertiesLoaded(connection));
    } catch (e) {
      debugPrint('Error fetching connection: $e');
      emit(ManuallyConnectionWithPropertiesError(e.toString()));
    }
  }
}
