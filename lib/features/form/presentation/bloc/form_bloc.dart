import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application/config/environments/environment.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:equatable/equatable.dart';
import 'dart:convert';

part 'form_event.dart';
part 'form_state.dart';

class FormBloc extends Bloc<FormEvent, FormState> {
  FormBloc() : super(FormInitial()) {
    on<SubmitFormEvent>((event, emit) async {
      emit(FormLoading());
      try {
        final String baseUrl = Environment.apiUrl;
        debugPrint(
          'Enviando a: $baseUrl/Readings/update-current-reading/${event.readingId}',
        );
        final response = await http.put(
          Uri.parse(
            '$baseUrl/Readings/update-current-reading/${event.readingId}',
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "previewsReading": event.previewsReading,
            "currentReading": event.currentReading,
            "rentalIncomeCode": event.rentalIncomeCode,
            "novelty": event.novelty,
            "incomeCode": event.incomeCode,
            "cadastralKey": event.cadastralKey,
            "sector": event.sector,
            "account": event.account,
            "connectionId": event.connectionId,
          }),
        );
        debugPrint(
          'Respuesta API (save): ${response.statusCode} - ${response.body}',
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          emit(FormSuccess());
        } else {
          emit(
            FormFailure(
              message: 'Error al guardar la lectura: ${response.statusCode}',
            ),
          );
        }
      } catch (e) {
        String errorMessage = 'Error: $e';
        if (e is SocketException) {
          errorMessage =
              'Error de conexión: No se pudo conectar al servidor en baseURL. Verifica que el servidor esté activo, usa la IP correcta y que el puerto 3005 esté abierto.';
        }
        emit(FormFailure(message: errorMessage));
      }
    });
  }
}
