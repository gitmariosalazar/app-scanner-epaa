import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/core/usecases/usecase.dart';
import 'package:flutter_application/features/incidents/domain/dto/request/create_incident_request.dart';
import 'package:flutter_application/features/incidents/domain/dto/request/resolve_incident_request.dart';
import 'package:flutter_application/features/incidents/domain/usecases/create_incident.dart';
import 'package:flutter_application/features/incidents/domain/usecases/resolve_incident.dart';
import 'package:flutter_application/features/incidents/domain/usecases/find_incidents_by_connection.dart';
import 'package:flutter_application/features/incidents/domain/usecases/find_incident_by_id.dart';
import 'package:flutter_application/features/incidents/domain/usecases/find_incidents.dart';
import 'package:flutter_application/features/incidents/domain/usecases/find_incident_categories.dart';
import 'incident_state.dart';

class IncidentCubit extends Cubit<IncidentState> {
  final CreateIncidentUseCase _createIncidentUseCase;
  final ResolveIncidentUseCase _resolveIncidentUseCase;
  final FindIncidentsByConnectionUseCase _findIncidentsByConnectionUseCase;
  final FindIncidentByIdUseCase _findIncidentByIdUseCase;
  final FindIncidentsUseCase _findIncidentsUseCase;
  final FindIncidentCategoriesUseCase _findIncidentCategoriesUseCase;

  IncidentCubit({
    required CreateIncidentUseCase createIncidentUseCase,
    required ResolveIncidentUseCase resolveIncidentUseCase,
    required FindIncidentsByConnectionUseCase findIncidentsByConnectionUseCase,
    required FindIncidentByIdUseCase findIncidentByIdUseCase,
    required FindIncidentsUseCase findIncidentsUseCase,
    required FindIncidentCategoriesUseCase findIncidentCategoriesUseCase,
  })  : _createIncidentUseCase = createIncidentUseCase,
        _resolveIncidentUseCase = resolveIncidentUseCase,
        _findIncidentsByConnectionUseCase = findIncidentsByConnectionUseCase,
        _findIncidentByIdUseCase = findIncidentByIdUseCase,
        _findIncidentsUseCase = findIncidentsUseCase,
        _findIncidentCategoriesUseCase = findIncidentCategoriesUseCase,
        super(IncidentInitial());

  Future<void> createIncident({
    required CreateIncidentRequest request,
  }) async {
    emit(IncidentLoading());
    final result = await _createIncidentUseCase(request);

    result.fold(
      (failure) => emit(IncidentError(failure.message)),
      (newIncident) => emit(
        IncidentOperationSuccess(
          incident: newIncident,
          message: 'Incidente registrado exitosamente.',
        ),
      ),
    );
  }

  Future<void> resolveIncident({
    required int incidentId,
    required String resolverUserId,
    required ResolveIncidentRequest request,
  }) async {
    emit(IncidentLoading());
    final result = await _resolveIncidentUseCase(
      ResolveIncidentParams(
        incidentId: incidentId,
        resolverUserId: resolverUserId,
        request: request,
      ),
    );

    result.fold(
      (failure) => emit(IncidentError(failure.message)),
      (resolvedIncident) => emit(
        IncidentOperationSuccess(
          incident: resolvedIncident,
          message: 'Incidente resuelto exitosamente.',
        ),
      ),
    );
  }

  Future<void> loadIncidentsByConnection(String connectionId) async {
    emit(IncidentLoading());
    final result = await _findIncidentsByConnectionUseCase(connectionId);

    result.fold(
      (failure) => emit(IncidentError(failure.message)),
      (incidents) => emit(IncidentsLoaded(incidents)),
    );
  }

  Future<void> loadIncidentById(int incidentId) async {
    emit(IncidentLoading());
    final result = await _findIncidentByIdUseCase(incidentId);

    result.fold(
      (failure) => emit(IncidentError(failure.message)),
      (incident) => emit(IncidentDetailLoaded(incident)),
    );
  }

  Future<void> loadIncidents({
    String? connectionId,
    String? status,
    String? priority,
    int? incidentTypeId,
  }) async {
    emit(IncidentLoading());
    final result = await _findIncidentsUseCase(
      FindIncidentsParams(
        connectionId: connectionId,
        status: status,
        priority: priority,
        incidentTypeId: incidentTypeId,
      ),
    );

    result.fold(
      (failure) => emit(IncidentError(failure.message)),
      (incidents) => emit(IncidentsLoaded(incidents)),
    );
  }

  Future<void> loadIncidentCategories() async {
    emit(IncidentLoading());
    final result = await _findIncidentCategoriesUseCase(NoParams());

    result.fold(
      (failure) => emit(IncidentError(failure.message)),
      (categories) => emit(IncidentCategoriesLoaded(categories)),
    );
  }
}
