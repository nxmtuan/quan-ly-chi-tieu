import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorage {
  const SettingsStorage(this._preferences);

  static const _themeModeKey = 'themeMode';

  final SharedPreferences _preferences;

  String readThemeMode() {
    return _preferences.getString(_themeModeKey) ?? 'system';
  }

  Future<void> saveThemeMode(String value) {
    return _preferences.setString(_themeModeKey, value);
  }
}
