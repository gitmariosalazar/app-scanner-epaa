import 'package:flutter_application/features/properties/list/domain/entities/contact.dart';
import 'package:flutter_application/features/properties/list/data/model/schemas/dto/response/connection_with_properties_response.dart'
    as dto;

extension PhoneDtoMapper on dto.Phone {
  PhoneEntity toEntity() {
    return PhoneEntity(telefonoid, numero);
  }
}

extension EmailDtoMapper on dto.Email {
  EmailEntity toEntity() {
    return EmailEntity(correoid, email);
  }
}
