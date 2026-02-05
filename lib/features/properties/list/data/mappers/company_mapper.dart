import 'package:flutter_application/features/properties/list/data/model/schemas/dto/response/connection_with_properties_response.dart'
    as dto;
import 'package:flutter_application/features/properties/list/domain/entities/company.dart';
import 'package:flutter_application/features/properties/list/data/mappers/contact_mapper.dart';

extension CompanyDtoMapper on dto.Company {
  CompanyEntity toEntity() {
    return CompanyEntity(
      ruc: ruc,
      address: address,
      country: country,
      clientId: clientId,
      parishId: parishId,
      companyId: companyId ?? 0, // Fallback to 0 if null
      businessName: businessName,
      commercialName: commercialName,
      emails: emails.map((e) => e?.toEntity()).toList(),
      phones: phones.map((e) => e?.toEntity()).toList(),
    );
  }
}
