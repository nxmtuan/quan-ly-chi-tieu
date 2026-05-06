import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/auth_user.dart';

class AuthStorage {
  const AuthStorage(this._preferences);

  static const _authUserKey = 'authUser';

  final SharedPreferences _preferences;

  AuthUser? readUser() {
    final rawUser = _preferences.getString(_authUserKey);

    if (rawUser == null) {
      return null;
    }

    return AuthUser.fromJson(jsonDecode(rawUser));
  }

  Future<void> saveUser(AuthUser user) {
    return _preferences.setString(_authUserKey, jsonEncode(user.toJson()));
  }

  Future<void> clearUser() {
    return _preferences.remove(_authUserKey);
  }
}
