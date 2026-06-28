import 'package:equatable/equatable.dart';

class CreateIncidentRequest extends Equatable {
  final String? connectionId;
  final int? readingId;
  final int incidentTypeId;
  final String reportDescription;
  final String referenceAddress;
  final String reportOrigin; // 'LECTURISTA' | 'ATENCION_AL_CLIENTE' | 'INSPECTOR' | 'WEB_USUARIO'
  final String priority; // 'BAJA' | 'MEDIA' | 'ALTA' | 'CRITICA'
  final double latitude;
  final double longitude;
  final List<String> images;

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

  @override
  List<Object?> get props => [
        connectionId,
        readingId,
        incidentTypeId,
        reportDescription,
        referenceAddress,
        reportOrigin,
        priority,
        latitude,
        longitude,
        images,
      ];

  Map<String, dynamic> toJson() {
    return {
      if (connectionId != null) 'connectionId': connectionId,
      if (readingId != null) 'readingId': readingId,
      'incidentTypeId': incidentTypeId,
      'reportDescription': reportDescription,
      'referenceAddress': referenceAddress,
      'reportOrigin': reportOrigin,
      'priority': priority,
      'latitude': latitude,
      'longitude': longitude,
      'images': images,
    };
  }
}

