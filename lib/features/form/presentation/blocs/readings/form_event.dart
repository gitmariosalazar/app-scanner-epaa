part of 'form_bloc.dart';

abstract class FormEvent extends Equatable {
  const FormEvent();

  @override
  List<Object> get props => [];
}

/// Evento para cargar lecturas desde la API (GET)
class LoadReadingEvent extends FormEvent {
  final String connectionId;

  const LoadReadingEvent(this.connectionId);

  @override
  List<Object> get props => [connectionId];
}

/// Evento para insertar una lectura (POST)
class InsertReadingEvent extends FormEvent {
  final CreateReadingRequest request;

  const InsertReadingEvent({required this.request});

  @override
  List<Object> get props => [request];
}
