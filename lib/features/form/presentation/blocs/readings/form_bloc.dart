// features/form/presentation/blocs/readings/form_bloc.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application/config/environments/environment.dart';
import 'package:flutter_application/features/reading/data/model/create_reading_request.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:equatable/equatable.dart';
import 'dart:convert';
import 'package:flutter_application/features/reading/domain/entities/reading_result.dart';
import 'package:flutter_application/features/reading/domain/usecases/create_reading_usecase.dart';

part 'form_event.dart';
part 'form_state.dart';

class FormBloc extends Bloc<FormEvent, FormState> {
  final CreateReadingUseCase createReadingUseCase;

  FormBloc({required this.createReadingUseCase}) : super(FormInitial()) {
    on<InsertReadingEvent>((event, emit) async {
      emit(FormLoading());
      try {
        final result = await createReadingUseCase(event.request);
        emit(FormSuccess(result));
      } catch (e) {
        String errorMessage = 'Error: $e';
        if (e is SocketException) {
          errorMessage =
              'Error de conexión: No se pudo conectar al servidor. Verifica que el servidor esté activo.';
        }
        emit(FormFailure(message: errorMessage));
      }
    });
  }
}
