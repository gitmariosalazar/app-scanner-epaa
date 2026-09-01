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

import 'package:flutter_application/features/properties/form/update/domain/usecases/change_meter_usecase.dart';
import 'package:flutter_application/features/properties/form/update/data/models/dto/request/change_meter_request.dart';
import 'package:flutter_application/features/incidents/domain/usecases/create_incident.dart';
import 'package:flutter_application/features/incidents/domain/dto/request/create_incident_request.dart';

part 'form_event.dart';
part 'form_state.dart';

class FormBloc extends Bloc<FormEvent, FormState> {
  final CreateReadingUseCase createReadingUseCase;
  final ChangeMeterUseCase changeMeterUseCase;
  final CreateIncidentUseCase createIncidentUseCase;

  FormBloc({
    required this.createReadingUseCase,
    required this.changeMeterUseCase,
    required this.createIncidentUseCase,
  }) : super(FormInitial()) {
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

    on<ChangeMeterEvent>((event, emit) async {
      emit(FormLoading());
      try {
        await changeMeterUseCase(event.request);
        emit(ChangeMeterSuccess());
      } catch (e) {
        String errorMessage = 'Error: $e';
        if (e is SocketException) {
          errorMessage =
              'Error de conexión: No se pudo conectar al servidor. Verifica que el servidor esté activo.';
        }
        emit(FormFailure(message: errorMessage));
      }
    });

    on<SaveCompleteFormEvent>((event, emit) async {
      emit(FormLoading());
      try {
        // Ejecutar Cambio de Medidor (si existe)
        if (event.changeMeterRequest != null) {
          try {
            await changeMeterUseCase(event.changeMeterRequest!);
          } catch (e) {
            if (e.toString().contains('409') || e.toString().toLowerCase().contains('asignado a esta acometida')) {
              emit(MeterConflictState(originalEvent: event, message: e.toString()));
              return;
            }
            rethrow;
          }
        }

        // Ejecutar Incidente de Ruta (si existe)
        if (event.incidentRequest != null) {
          final incResult = await createIncidentUseCase(event.incidentRequest!);
          incResult.fold(
            (failure) => throw Exception(failure.message),
            (success) => true,
          );
        }

        // Ejecutar Lectura (si existe)
        if (event.readingRequest != null) {
          final result = await createReadingUseCase(event.readingRequest!);
          emit(FormSuccess(result));
        } else {
          // Si no hubo lectura pero hubo otras acciones, usamos un FormSuccess con data vacía o un ChangeMeterSuccess
          emit(ChangeMeterSuccess());
        }
      } catch (e) {
        String errorMessage = 'Error al guardar: $e';
        if (e is SocketException) {
          errorMessage =
              'Error de conexión: No se pudo conectar al servidor. Verifica que el servidor esté activo.';
        }
        emit(FormFailure(message: errorMessage));
      }
    });
  }
}
