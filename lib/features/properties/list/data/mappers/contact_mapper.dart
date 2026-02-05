import 'package:flutter_application/features/properties/list/data/model/schemas/dto/response/connection_with_properties_response.dart'
    as dto;
import 'package:flutter_application/features/properties/list/domain/entities/contact.dart';

extension PhoneDtoMapper on dto.Phone {
  PhoneEntity toEntity() {
    return PhoneEntity(telefonoid ?? 0, numero ?? '');
  }
}

extension EmailDtoMapper on dto.Email {
  EmailEntity toEntity() {
    return EmailEntity(correoid ?? 0, email ?? '');
  }
}
