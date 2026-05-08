import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/auth_user.dart';

class AuthStorage {
  const AuthStorage(this._prefs);

  final SharedPreferences _prefs;
  static const _userKey = 'authUser';

  AuthUser? readUser() {
    final jsonString = _prefs.getString(_userKey);
    if (jsonString == null) return null;
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return AuthUser.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(AuthUser user) async {
    final jsonString = jsonEncode(user.toJson());
    await _prefs.setString(_userKey, jsonString);
  }

  Future<void> clearUser() async {
    await _prefs.remove(_userKey);
  }
}
