import 'dart:io';

class CreateIncidentRequest {
  final String? connectionId;
  final int? readingId;
  final int incidentTypeId;
  final String reportDescription;
  final String referenceAddress;
  final String reportOrigin;
  final String priority;
  final double latitude;
  final double longitude;
  final List<File> images;

  const CreateIncidentRequest({
    this.connectionId,
    this.readingId,
    required this.incidentTypeId,
    required this.reportDescription,
    required this.referenceAddress,
    required this.reportOrigin,
    required this.priority,
    required this.latitude,
    required this.longitude,
    required this.images,
  });
}
