import 'package:equatable/equatable.dart';

class PropertyEntity extends Equatable {
  final String propertyId;
  final String propertySector;
  final int propertyTypeId;
  final String propertyTypeName;
  final String propertyAddress;
  final String propertyAlleyway;
  final double? propertyAltitude;
  final double? propertyPrecision;
  final String? propertyReference;
  final String? propertyCoordinates;
  final String propertyCadastralKey;
  final String? propertyGeometricZone;

  const PropertyEntity({
    required this.propertyId,
    required this.propertySector,
    required this.propertyTypeId,
    required this.propertyTypeName,
    required this.propertyAddress,
    required this.propertyAlleyway,
    this.propertyAltitude,
    this.propertyPrecision,
    this.propertyReference,
    this.propertyCoordinates,
    required this.propertyCadastralKey,
    this.propertyGeometricZone,
  });

  @override
  List<Object?> get props => [
    propertyId,
    propertySector,
    propertyTypeId,
    propertyTypeName,
    propertyAddress,
    propertyAlleyway,
    propertyAltitude,
    propertyPrecision,
    propertyReference,
    propertyCoordinates,
    propertyCadastralKey,
    propertyGeometricZone,
  ];

  factory PropertyEntity.fromJson(Map<String, dynamic> json) {
    return PropertyEntity(
      propertyId: json['propertyId'] as String,
      propertySector: json['propertySector'] as String,
      propertyTypeId: json['propertyTypeId'] as int,
      propertyTypeName: json['propertyTypeName'] as String,
      propertyAddress: json['propertyAddress'] as String,
      propertyAlleyway: json['propertyAlleyway'] as String,
      propertyAltitude: (json['propertyAltitude'] as num?)?.toDouble(),
      propertyPrecision: (json['propertyPrecision'] as num?)?.toDouble(),
      propertyReference: json['propertyReference'] as String?,
      propertyCoordinates: json['propertyCoordinates'] as String?,
      propertyCadastralKey: json['propertyCadastralKey'] as String,
      propertyGeometricZone: json['propertyGeometricZone'] as String?,
    );
  }
}
