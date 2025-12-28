class AssignWorkOrderRequest {
  final String userId;

  AssignWorkOrderRequest({required this.userId});

  Map<String, dynamic> toJson() => {'userId': userId};
}
