import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_application/config/environments/environment.dart';
import 'package:flutter_application/features/work-orders/data/mappers/work_order_mapper.dart';
import 'package:flutter_application/features/work-orders/data/models/assign_work_order_request.dart';
import 'package:flutter_application/features/work-orders/data/models/create_work_order_request.dart';
import 'package:flutter_application/features/work-orders/data/models/update_work_order_request.dart';
import 'package:flutter_application/features/work-orders/data/models/work_order_response.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

abstract class WorkOrderRemoteDataSource {
  Future<WorkOrderResponse> createWorkOrder(CreateWorkOrderRequest request);
  Future<WorkOrderResponse> editWorkOrder(
    String id,
    UpdateWorkOrderRequest request,
  );
  Future<void> deleteWorkOrder(String id);
  Future<WorkOrderResponse> assignWorkOrder(
    String id,
    AssignWorkOrderRequest request,
  );
  Future<List<WorkOrderResponse>> listWorkOrders({
    int page = 1,
    int pageSize = 20,
  });
  Future<WorkOrderResponse> getWorkOrderDetails(String id);
}

// A simple implementation using http package (pseudo)
class WorkOrderRemoteDataSourceImpl implements WorkOrderRemoteDataSource {
  final http.Client client; // e.g. http.Client
  final String baseUrl = Environment.apiUrl;

  WorkOrderRemoteDataSourceImpl({required this.client});

  @override
  Future<WorkOrderResponse> createWorkOrder(
    CreateWorkOrderRequest request,
  ) async {
    // TODO: implement API call
    final response = await client.post(
      Uri.parse('$baseUrl/work-orders/create-work-order'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    debugPrint('Response body: ${response.body}');
    debugPrint('Response status code: ${response.statusCode}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      final decode = jsonDecode(response.body);
      final data = decode['data'];

      return WorkOrderMapper.fromJson(data);
    } else {
      throw Exception('Failed to create work order $response');
    }
  }

  @override
  Future<void> deleteWorkOrder(String id) {
    throw UnimplementedError();
  }

  @override
  Future<WorkOrderResponse> editWorkOrder(
    String id,
    UpdateWorkOrderRequest request,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<WorkOrderResponse> assignWorkOrder(
    String id,
    AssignWorkOrderRequest request,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<List<WorkOrderResponse>> listWorkOrders({
    int page = 1,
    int pageSize = 20,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<WorkOrderResponse> getWorkOrderDetails(String id) {
    throw UnimplementedError();
  }
}
