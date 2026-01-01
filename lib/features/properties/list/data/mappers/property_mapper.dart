// lib/features/properties/data/mappers/property_mapper.dart

import 'package:flutter_application/features/properties/list/data/model/schemas/dto/response/connection_with_properties_response.dart'
    as dto;
import 'package:flutter_application/features/properties/list/domain/entities/property.dart';

extension PropertyDtoMapper on dto.Property {
  PropertyEntity toEntity() {
    return PropertyEntity(
      propertyId: propertyId,
      propertySector: propertySector,
      propertyTypeId: propertyTypeId ?? 0,
      propertyTypeName: propertyTypeName,
      propertyAddress: propertyAddress,
      propertyAlleyway: propertyAlleyway,
      propertyAltitude: propertyAltitude,
      propertyPrecision: propertyPrecision,
      propertyReference: propertyReference,
      propertyCoordinates: propertyCoordinates,
      propertyCadastralKey: propertyCadastralKey,
      propertyGeometricZone: propertyGeometricZone,
    );
  }
}
