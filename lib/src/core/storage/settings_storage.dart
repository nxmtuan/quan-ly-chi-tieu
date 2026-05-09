import 'package:shared_preferences/shared_preferences.dart';

import '../../models/auto_sync_settings.dart';

class SettingsStorage {
  const SettingsStorage(this._prefs);

  static const softDeletePurgeInterval = Duration(days: 30);
  static const softDeleteRetention = Duration(days: 30);

  static const _themeModeKey = 'themeMode';
  static const _autoSyncEnabledKey = 'autoSyncEnabled';
  static const _autoSyncTypeKey = 'autoSyncType';
  static const _autoSyncHourKey = 'autoSyncHour';
  static const _autoSyncMinuteKey = 'autoSyncMinute';
  static const _autoSyncWeekdayKey = 'autoSyncWeekday';
  static const _lastSoftDeletePurgeAtKey = 'lastSoftDeletePurgeAt';

  final SharedPreferences _prefs;

  String readThemeMode() {
    return _prefs.getString(_themeModeKey) ?? 'system';
  }

  Future<void> saveThemeMode(String value) async {
    await _prefs.setString(_themeModeKey, value);
  }

  AutoSyncSettings readAutoSyncSettings() {
    final typeValue = _prefs.getString(_autoSyncTypeKey) ?? 'daily';

    return AutoSyncSettings(
      enabled: _prefs.getBool(_autoSyncEnabledKey) ?? false,
      scheduleType: typeValue == 'weekly'
          ? AutoSyncScheduleType.weekly
          : AutoSyncScheduleType.daily,
      hour: _prefs.getInt(_autoSyncHourKey) ?? 8,
      minute: _prefs.getInt(_autoSyncMinuteKey) ?? 0,
      weekday: _prefs.getInt(_autoSyncWeekdayKey) ?? 1,
    );
  }

  Future<void> saveAutoSyncSettings(AutoSyncSettings settings) async {
    await _prefs.setBool(_autoSyncEnabledKey, settings.enabled);
    await _prefs.setString(
      _autoSyncTypeKey,
      settings.scheduleType == AutoSyncScheduleType.weekly
          ? 'weekly'
          : 'daily',
    );
    await _prefs.setInt(_autoSyncHourKey, settings.hour);
    await _prefs.setInt(_autoSyncMinuteKey, settings.minute);
    await _prefs.setInt(_autoSyncWeekdayKey, settings.weekday);
  }

  DateTime? readLastSoftDeletePurgeAt() {
    final rawValue = _prefs.getString(_lastSoftDeletePurgeAtKey);
    if (rawValue == null) {
      return null;
    }

    return DateTime.tryParse(rawValue);
  }

  bool isSoftDeletePurgeDue({DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    final lastPurgeAt = readLastSoftDeletePurgeAt();
    if (lastPurgeAt == null) {
      return true;
    }

    return currentTime.difference(lastPurgeAt) >= softDeletePurgeInterval;
  }

  Future<void> saveLastSoftDeletePurgeAt(DateTime value) async {
    await _prefs.setString(_lastSoftDeletePurgeAtKey, value.toIso8601String());
  }
}
