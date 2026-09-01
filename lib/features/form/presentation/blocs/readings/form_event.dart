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

/// Evento para cambiar un medidor (Update Meter)
class ChangeMeterEvent extends FormEvent {
  final ChangeMeterRequest request;

  const ChangeMeterEvent({required this.request});

  @override
  List<Object> get props => [request];
}

/// Evento unificado para guardar todo (Lectura, Incidente, Medidor)
class SaveCompleteFormEvent extends FormEvent {
  final CreateReadingRequest? readingRequest;
  final ChangeMeterRequest? changeMeterRequest;
  final CreateIncidentRequest? incidentRequest;

  const SaveCompleteFormEvent({
    this.readingRequest,
    this.changeMeterRequest,
    this.incidentRequest,
  });

  @override
  List<Object> get props {
    final list = <Object>[];
    if (readingRequest != null) list.add(readingRequest!);
    if (changeMeterRequest != null) list.add(changeMeterRequest!);
    if (incidentRequest != null) list.add(incidentRequest!);
    return list;
  }
}
