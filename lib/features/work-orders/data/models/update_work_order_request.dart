class UpdateWorkOrderRequest {
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

  UpdateWorkOrderRequest({
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

  Map<String, dynamic> toJson() => {
    'workOrderId': workOrderId,
    'description': description,
    'creationDate': creationDate?.toIso8601String(),
    'assignationDate': assignationDate?.toIso8601String(),
    'startDate': startDate?.toIso8601String(),
    'completionDate': completionDate?.toIso8601String(),
    'cancelationDate': cancelationDate?.toIso8601String(),
    'workOrderTypeId': workOrderTypeId,
    'priorityId': priorityId,
    'workOrderStatusId': workOrderStatusId,
    'connectionId': connectionId,
    'clientId': clientId,
    'createdUserId': createdUserId,
    'assignedUserId': assignedUserId,
    'estimatedCost': estimatedCost,
    'realCost': realCost,
    'observations': observations,
  };
}
