import 'package:equatable/equatable.dart';

class PhoneEntity extends Equatable {
  final int telefonoid;
  final String numero;
  const PhoneEntity(this.telefonoid, this.numero);
  @override
  List<Object?> get props => [telefonoid, numero];

  factory PhoneEntity.fromJson(Map<String, dynamic> json) {
    return PhoneEntity(json['telefonoid'] as int, json['numero'] as String);
  }
}

class EmailEntity extends Equatable {
  final int correoid;
  final String email;
  const EmailEntity(this.correoid, this.email);
  @override
  List<Object?> get props => [correoid, email];

  factory EmailEntity.fromJson(Map<String, dynamic> json) {
    return EmailEntity(json['correoid'] as int, json['email'] as String);
  }
}
