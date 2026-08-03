import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/incidents/domain/dto/request/create_incident_request.dart';
import 'package:flutter_application/features/incidents/domain/dto/request/resolve_incident_request.dart';
import 'package:flutter_application/features/incidents/domain/entities/incident-category.model.dart';
import 'package:flutter_application/features/incidents/domain/entities/incident.model.dart';
import 'package:flutter_application/features/incidents/domain/entities/incident_detail_row_response.dart';
import 'package:flutter_application/features/incidents/domain/entities/incident_kpi.model.dart';

/// Repository interface for Incident operations.
/// Follows LSP (Liskov Substitution Principle) and ISP (Interface Segregation Principle).
abstract class IncidentRepository {
  Future<Either<Failure, IncidentModel>> createIncident({
    required CreateIncidentRequest request,
  });

  Future<Either<Failure, IncidentModel>> resolveIncident({
    required String incidentId,
    required String resolverUserId,
    required ResolveIncidentRequest request,
  });

  Future<Either<Failure, List<IncidentDetailRowResponse>>>
  findIncidentsByConnection(String connectionId);

  Future<Either<Failure, IncidentModel>> findById(String incidentId);

  Future<Either<Failure, List<IncidentDetailRowResponse>>> findIncidents({
    String? connectionId,
    String? status,
    String? priority,
    int? incidentTypeId,
  });

  Future<Either<Failure, List<IncidentCategoryModel>>> findIncidentCategories();
  Future<Either<Failure, IncidentDashboardKpiResponse>>
  getIncidentDashboardKpis();
}
