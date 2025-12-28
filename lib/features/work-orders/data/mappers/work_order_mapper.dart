import 'package:flutter_application/features/work-orders/data/models/create_work_order_request.dart';

import '../models/work_order_response.dart';
import '../../domain/entities/work_order_entity.dart';

class WorkOrderMapper {
  static WorkOrderEntity fromWorkOrderResponseToWorkOrderEntity(
    WorkOrderResponse model,
  ) {
    return WorkOrderEntity(
      workOrderId: model.workOrderId,
      description: model.description,
      creationDate: model.creationDate,
      assignationDate: model.assignationDate,
      startDate: model.startDate,
      completionDate: model.completionDate,
      cancelationDate: model.cancelationDate,
      workOrderTypeId: model.workOrderTypeId,
      priorityId: model.priorityId,
      workOrderStatusId: model.workOrderStatusId,
      connectionId: model.connectionId,
      clientId: model.clientId,
      createdUserId: model.createdUserId,
      assignedUserId: model.assignedUserId,
      estimatedCost: model.estimatedCost,
      realCost: model.realCost,
      observations: model.observations,
    );
  }

  static WorkOrderResponse fromWorkOrderEntityToWorkOrderResponse(
    WorkOrderEntity e,
  ) {
    return WorkOrderResponse(
      workOrderId: e.workOrderId,
      description: e.description,
      creationDate: e.creationDate,
      assignationDate: e.assignationDate,
      startDate: e.startDate,
      completionDate: e.completionDate,
      cancelationDate: e.cancelationDate,
      workOrderTypeId: e.workOrderTypeId,
      priorityId: e.priorityId,
      workOrderStatusId: e.workOrderStatusId,
      connectionId: e.connectionId,
      clientId: e.clientId,
      createdUserId: e.createdUserId,
      assignedUserId: e.assignedUserId,
      estimatedCost: e.estimatedCost,
      realCost: e.realCost,
      observations: e.observations,
    );
  }

  static WorkOrderResponse fromJson(Map<String, dynamic> json) {
    return WorkOrderResponse(
      workOrderId: json['workOrderId'] as int?,
      description: json['description'] as String,
      creationDate: json['creationDate'] != null
          ? DateTime.parse(json['creationDate'] as String)
          : null,
      assignationDate: null, // tu backend no lo devuelve aún
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'] as String)
          : null,
      cancelationDate: null,
      workOrderTypeId: json['workOrderTypeId'] as int,
      priorityId: json['priorityId'] as int,
      workOrderStatusId: json['workOrderStatusId'] as int,
      connectionId: json['connectionId'] as String? ?? '',
      clientId: json['clientId'] as String,
      createdUserId: json['createdUserId']?.toString() ?? '1', // fallback
      assignedUserId: json['assignedUserId'] as String?,
      estimatedCost: null,
      realCost: null,
      observations: json['observations'] as String?,
    );
  }

  static List<WorkOrderEntity> fromWorkOrderResponseListToWorkOrderEntityList(
    List<WorkOrderResponse> models,
  ) {
    return models
        .map((model) => fromWorkOrderResponseToWorkOrderEntity(model))
        .toList();
  }

  static List<WorkOrderResponse> fromWorkOrderEntityListToWorkOrderResponseList(
    List<WorkOrderEntity> entities,
  ) {
    return entities
        .map((e) => fromWorkOrderEntityToWorkOrderResponse(e))
        .toList();
  }

  static CreateWorkOrderRequest fromWorkOrderEntityToCreateWorkOrderRequest(
    WorkOrderEntity e,
  ) {
    return CreateWorkOrderRequest(
      workOrderId: e.workOrderId,
      description: e.description,
      creationDate: e.creationDate,
      assignationDate: e.assignationDate,
      startDate: e.startDate,
      completionDate: e.completionDate,
      cancelationDate: e.cancelationDate,
      workOrderTypeId: e.workOrderTypeId,
      priorityId: e.priorityId,
      workOrderStatusId: e.workOrderStatusId,
      connectionId: e.connectionId,
      clientId: e.clientId,
      createdUserId: e.createdUserId,
      assignedUserId: e.assignedUserId,
      estimatedCost: e.estimatedCost,
      realCost: e.realCost,
      observations: e.observations,
    );
  }
}
