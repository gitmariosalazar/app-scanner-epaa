// lib/features/auth/data/models/user_model.dart
import 'package:flutter_application/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({required String id, required String email})
    : super(id: id, email: email);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(id: json['id'], email: json['email']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email};
  }
}
