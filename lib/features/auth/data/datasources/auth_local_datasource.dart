import 'dart:convert';
import 'package:flutter_application/core/error/exception.dart';
import 'package:flutter_application/features/auth/data/models/auth_response_model.dart';
import 'package:flutter_application/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
  Future<void> cacheUser(UserModel user);
  Future<AuthResponseModel?> getAuthResponse();
  Future<void> clearUser();
}

const CACHED_AUTH_TOKEN = 'CACHED_AUTH_TOKEN';
const CACHED_USER_DATA = 'CACHED_USER_DATA';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheToken(String token) async {
    await sharedPreferences.setString(CACHED_AUTH_TOKEN, token);
    print(
      '💾 TOKEN GUARDADO CORRECTAMENTE: ${token.substring(0, 30)}...',
    ); // ← Agrega esto
  }

  @override
  Future<String?> getToken() async {
    return sharedPreferences.getString(CACHED_AUTH_TOKEN);
  }

  @override
  Future<void> clearToken() {
    return sharedPreferences.remove(CACHED_AUTH_TOKEN);
  }

  @override
  Future<void> cacheUser(UserModel user) {
    return sharedPreferences.setString(
      CACHED_USER_DATA,
      jsonEncode(user.toJson()),
    );
  }

  @override
  Future<AuthResponseModel?> getAuthResponse() async {
    final jsonString = sharedPreferences.getString(CACHED_USER_DATA);
    if (jsonString != null) {
      try {
        return AuthResponseModel.fromJson(jsonDecode(jsonString));
      } catch (e) {
        throw CacheException('Could not parse cached user data');
      }
    }
    return null;
  }

  @override
  Future<void> clearUser() {
    return sharedPreferences.remove(CACHED_USER_DATA);
  }
}
