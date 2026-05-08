import '../../../objectbox.g.dart';
import '../../models/app_setting.dart';

class SettingsStorage {
  const SettingsStorage(this._box);

  static const _themeModeKey = 'themeMode';

  final Box<AppSetting> _box;

  String readThemeMode() {
    final query = _box.query(AppSetting_.key.equals(_themeModeKey)).build();
    final result = query.findFirst();
    query.close();
    return result?.value ?? 'system';
  }

  Future<void> saveThemeMode(String value) async {
    final query = _box.query(AppSetting_.key.equals(_themeModeKey)).build();
    var setting = query.findFirst();
    query.close();
    
    if (setting != null) {
      setting.value = value;
      _box.put(setting);
    } else {
      _box.put(AppSetting(key: _themeModeKey, value: value));
    }
  }
}
