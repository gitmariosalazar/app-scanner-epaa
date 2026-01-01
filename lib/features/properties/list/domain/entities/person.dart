import 'package:equatable/equatable.dart';
import 'package:flutter_application/features/properties/list/domain/entities/contact.dart';

class PersonEntity extends Equatable {
  final String personId;
  final String? firstName;
  final String? lastName;
  final String? address;
  final String? country;
  final int? genderId;
  final String? parishId;
  final String? birthDate;
  final bool? isDeceased;
  final int professionId;
  final int civilStatus;
  final List<EmailEntity?> emails;
  final List<PhoneEntity?> phones;

  const PersonEntity({
    required this.personId,
    this.firstName,
    this.lastName,
    this.address,
    this.country,
    this.genderId,
    this.parishId,
    this.birthDate,
    this.isDeceased,
    required this.professionId,
    required this.civilStatus,
    required this.emails,
    required this.phones,
  });

  @override
  List<Object?> get props => [
    personId,
    firstName,
    lastName,
    address,
    country,
    genderId,
    parishId,
    birthDate,
    isDeceased,
    professionId,
    civilStatus,
    emails,
    phones,
  ];

  factory PersonEntity.fromJson(Map<String, dynamic> json) {
    return PersonEntity(
      personId: json['personId'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      address: json['address'] as String?,
      country: json['country'] as String?,
      genderId: json['genderId'] as int?,
      parishId: json['parishId'] as String?,
      birthDate: json['birthDate'] as String?,
      isDeceased: json['isDeceased'] as bool?,
      professionId: json['professionId'] as int,
      civilStatus: json['civilStatus'] as int,
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
