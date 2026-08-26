import 'package:flutter_application/features/auth/domain/entities/RoleOrPermission.dart';
import 'package:flutter_application/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.roles,
    required super.permissions,
    required super.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['userId']?.toString() ?? json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      roles: (json['roles'] as List<dynamic>?)?.map((e) {
        if (e is String) {
          return RoleOrPermission(id: 0, name: e, description: '');
        } else if (e is int) {
          return RoleOrPermission(id: e, name: e.toString(), description: '');
        }
        return RoleOrPermission.fromJson(e as Map<String, dynamic>);
      }).toList() ?? [],
      permissions: (json['permissions'] as List<dynamic>?)?.map((e) {
        if (e is String) {
          return RoleOrPermission(id: 0, name: e, description: '');
        } else if (e is int) {
          return RoleOrPermission(id: e, name: e.toString(), description: '');
        }
        return RoleOrPermission.fromJson(e as Map<String, dynamic>);
      }).toList() ?? [],
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'roles': roles.map((role) => role.toJson()).toList(),
      'permissions': permissions
          .map((permission) => permission.toJson())
          .toList(),
      'isActive': isActive,
    };
  }
}
