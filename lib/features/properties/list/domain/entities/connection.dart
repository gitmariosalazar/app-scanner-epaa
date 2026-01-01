import 'package:flutter_application/features/properties/list/domain/entities/company.dart';
import 'package:flutter_application/features/properties/list/domain/entities/person.dart';
import 'package:flutter_application/features/properties/list/domain/entities/property.dart';
import 'package:equatable/equatable.dart';

class ConnectionEntity extends Equatable {
  final String connectionId;
  final String clientId;
  final int connectionRateId;
  final String connectionRateName;
  final String? connectionMeterNumber;
  final int connectionSector;
  final int connectionAccount;
  final String connectionCadastralKey;
  final String? connectionContractNumber;
  final bool? connectionSewerage;
  final bool? connectionStatus;
  final String connectionAddress;
  final String? connectionInstallationDate;
  final int? connectionPeopleNumber;
  final int? connectionZone;
  final String? connectionCoordinates;
  final String? connectionReference;
  final Map<String, dynamic>? connectionMetadata;
  final double? connectionAltitude;
  final double? connectionPrecision;
  final DateTime? connectionGeolocationDate;
  final String? connectionGeometricZone;
  final String? propertyCadastralKey;
  final int? zoneId;
  final String? zoneCode;
  final String? zoneName;
  final PersonEntity? person;
  final CompanyEntity? company;
  final List<PropertyEntity>? properties;

  const ConnectionEntity({
    required this.connectionId,
    required this.clientId,
    required this.connectionRateId,
    required this.connectionRateName,
    this.connectionMeterNumber,
    required this.connectionSector,
    required this.connectionAccount,
    required this.connectionCadastralKey,
    this.connectionContractNumber,
    this.connectionSewerage,
    this.connectionStatus,
    required this.connectionAddress,
    required this.connectionInstallationDate,
    this.connectionPeopleNumber,
    this.connectionZone,
    this.connectionCoordinates,
    this.connectionReference,
    this.connectionMetadata,
    this.connectionAltitude,
    this.connectionPrecision,
    this.connectionGeolocationDate,
    this.connectionGeometricZone,
    this.propertyCadastralKey,
    this.zoneId,
    this.zoneCode,
    this.zoneName,
    this.person,
    this.company,
    this.properties,
  });

  @override
  List<Object?> get props => [
    connectionId,
    clientId,
    connectionRateId,
    connectionRateName,
    connectionMeterNumber,
    connectionSector,
    connectionAccount,
    connectionCadastralKey,
    connectionContractNumber,
    connectionGeometricZone,
    connectionSewerage,
    connectionStatus,
    connectionAddress,
    connectionInstallationDate,
    connectionPeopleNumber,
    connectionZone,
    connectionCoordinates,
    connectionReference,
    connectionMetadata,
    connectionAltitude,
    connectionPrecision,
    connectionGeolocationDate,
    connectionGeometricZone,
    propertyCadastralKey,
    zoneId,
    zoneCode,
    zoneName,
    person,
    company,
    properties,
  ];

  factory ConnectionEntity.fromJson(Map<String, dynamic> json) {
    return ConnectionEntity(
      connectionId: json['connectionId'] as String? ?? '',
      clientId: json['clientId'] as String? ?? '',
      connectionRateId: json['connectionRateId'] as int? ?? 0,
      connectionRateName: json['connectionRateName'] as String? ?? '',
      connectionMeterNumber: json['connectionMeterNumber'] as String?,
      connectionSector: json['connectionSector'] as int? ?? 0,
      connectionAccount: json['connectionAccount'] as int? ?? 0,
      connectionCadastralKey: json['connectionCadastralKey'] as String? ?? '',
      connectionContractNumber: json['connectionContractNumber'] as String?,
      connectionSewerage: json['connectionSewerage'] as bool?,
      connectionStatus: json['connectionStatus'] as bool?,
      connectionAddress: json['connectionAddress'] as String? ?? '',
      connectionInstallationDate: json['connectionInstallationDate'] as String?,
      connectionPeopleNumber: json['connectionPeopleNumber'] as int?,
      connectionZone: json['connectionZone'] as int?,
      connectionCoordinates: json['connectionCoordinates'] as String?,
      connectionReference: json['connectionReference'] as String?,
      connectionMetadata: json['connectionMetadata'] as Map<String, dynamic>?,
      connectionAltitude: (json['connectionAltitude'] as num?)?.toDouble(),
      connectionPrecision: (json['connectionPrecision'] as num?)?.toDouble(),
      connectionGeolocationDate: json['connectionGeolocationDate'] != null
          ? DateTime.tryParse(json['connectionGeolocationDate'])
          : null,
      connectionGeometricZone: json['connectionGeometricZone'] as String?,
      propertyCadastralKey: json['propertyCadastralKey'] as String?,
      zoneId: json['zoneId'] as int?,
      zoneCode: json['zoneCode'] as String?,
      zoneName: json['zoneName'] as String?,
      person: json['person'] != null
          ? PersonEntity.fromJson(json['person'] as Map<String, dynamic>)
          : null,
      company: json['company'] != null
          ? CompanyEntity.fromJson(json['company'] as Map<String, dynamic>)
          : null,
      properties: (json['properties'] as List<dynamic>?)
          ?.map((e) => PropertyEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
