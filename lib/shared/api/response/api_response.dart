// lib/core/network/api_response.dart
class ApiResponse<T> {
  final int statusCode;
  final String time;
  final List<String> message;
  final String url;
  final List<T> data;

  ApiResponse({
    required this.statusCode,
    required this.time,
    required this.message,
    required this.url,
    required this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ApiResponse<T>(
      statusCode: json['status_code'] as int,
      time: json['time'] as String,
      message: List<String>.from(json['message'] as List),
      url: json['url'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Útil para debugging
  @override
  String toString() {
    return 'ApiResponse(statusCode: $statusCode, message: $message, dataCount: ${data.length})';
  }
}
