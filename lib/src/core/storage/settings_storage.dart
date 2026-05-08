import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorage {
  const SettingsStorage(this._prefs);

  static const _themeModeKey = 'themeMode';

  final SharedPreferences _prefs;

  String readThemeMode() {
    return _prefs.getString(_themeModeKey) ?? 'system';
  }

  Future<void> saveThemeMode(String value) async {
    await _prefs.setString(_themeModeKey, value);
  }
}
