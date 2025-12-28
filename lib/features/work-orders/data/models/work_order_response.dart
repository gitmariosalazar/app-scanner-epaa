class WorkOrderResponse {
  final int? workOrderId;
  final String description;
  final DateTime? creationDate;
  final DateTime? assignationDate;
  final DateTime? startDate;
  final DateTime? completionDate;
  final DateTime? cancelationDate;
  final int workOrderTypeId;
  final int priorityId;
  final int workOrderStatusId;
  final String connectionId;
  final String clientId;
  final String createdUserId;
  final String? assignedUserId;
  final double? estimatedCost;
  final double? realCost;
  final String? observations;

  WorkOrderResponse({
    this.workOrderId,
    required this.description,
    this.creationDate,
    this.assignationDate,
    this.startDate,
    this.completionDate,
    this.cancelationDate,
    required this.workOrderTypeId,
    required this.priorityId,
    required this.workOrderStatusId,
    required this.connectionId,
    required this.clientId,
    required this.createdUserId,
    this.assignedUserId,
    this.estimatedCost,
    this.realCost,
    this.observations,
  });
}
