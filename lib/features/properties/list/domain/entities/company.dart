import 'package:equatable/equatable.dart';
import 'package:flutter_application/features/properties/list/domain/entities/contact.dart';

class CompanyEntity extends Equatable {
  final String ruc;
  final String? address;
  final String? country;
  final String clientId;
  final String? parishId;
  final int companyId;
  final String? businessName;
  final String? commercialName;
  final List<EmailEntity?> emails;
  final List<PhoneEntity?> phones;

  const CompanyEntity({
    required this.ruc,
    this.address,
    this.country,
    required this.clientId,
    this.parishId,
    required this.companyId,
    this.businessName,
    this.commercialName,
    required this.emails,
    required this.phones,
  });

  @override
  List<Object?> get props => [
    ruc,
    address,
    country,
    clientId,
    parishId,
    companyId,
    businessName,
    commercialName,
    emails,
    phones,
  ];

  factory CompanyEntity.fromJson(Map<String, dynamic> json) {
    return CompanyEntity(
      ruc: json['ruc'] as String,
      address: json['address'] as String?,
      country: json['country'] as String?,
      clientId: json['clientId'] as String,
      parishId: json['parishId'] as String?,
      companyId: json['companyId'] as int,
      businessName: json['businessName'] as String?,
      commercialName: json['commercialName'] as String?,
      emails:
          (json['emails'] as List<dynamic>?)
              ?.map(
                (e) => e != null
                    ? EmailEntity.fromJson(e as Map<String, dynamic>)
                    : null,
              )
              .toList() ??
          [],
      phones:
          (json['phones'] as List<dynamic>?)
              ?.map(
                (e) => e != null
                    ? PhoneEntity.fromJson(e as Map<String, dynamic>)
                    : null,
              )
              .toList() ??
          [],
    );
  }
}
