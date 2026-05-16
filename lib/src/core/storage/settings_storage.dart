import 'package:shared_preferences/shared_preferences.dart';

import '../../models/auto_sync_settings.dart';
import '../../models/auto_sync_status.dart';

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
  static const _autoSyncStatusKey = 'autoSyncStatus';
  static const _autoSyncLastSuccessAtKey = 'autoSyncLastSuccessAt';
  static const _autoSyncRetryAtKey = 'autoSyncRetryAt';
  static const _autoSyncRetryAttemptKey = 'autoSyncRetryAttempt';
  static const _autoSyncNextRunAtKey = 'autoSyncNextRunAt';
  static const _biometricUnlockEnabledKey = 'biometricUnlockEnabled';
  static const _biometricLockTriggerKey = 'biometricLockTrigger';
  static const _biometricScreenOffLockPendingKey =
      'biometricScreenOffLockPending';
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
      settings.scheduleType == AutoSyncScheduleType.weekly ? 'weekly' : 'daily',
    );
    await _prefs.setInt(_autoSyncHourKey, settings.hour);
    await _prefs.setInt(_autoSyncMinuteKey, settings.minute);
    await _prefs.setInt(_autoSyncWeekdayKey, settings.weekday);
  }

  AutoSyncStatus readAutoSyncStatus() {
    final statusValue = _prefs.getString(_autoSyncStatusKey) ?? 'idle';
    final lastSuccessAt = DateTime.tryParse(
      _prefs.getString(_autoSyncLastSuccessAtKey) ?? '',
    );
    final retryAt = DateTime.tryParse(
      _prefs.getString(_autoSyncRetryAtKey) ?? '',
    );

    return AutoSyncStatus(
      type: switch (statusValue) {
        'success' => AutoSyncStatusType.success,
        'failure' => AutoSyncStatusType.failure,
        _ => AutoSyncStatusType.idle,
      },
      lastSuccessAt: lastSuccessAt,
      retryAt: retryAt,
      retryAttempt: _prefs.getInt(_autoSyncRetryAttemptKey) ?? 0,
    );
  }

  Future<void> saveAutoSyncStatus(AutoSyncStatus status) async {
    final statusValue = switch (status.type) {
      AutoSyncStatusType.success => 'success',
      AutoSyncStatusType.failure => 'failure',
      AutoSyncStatusType.idle => 'idle',
    };

    await _prefs.setString(_autoSyncStatusKey, statusValue);

    if (status.lastSuccessAt != null) {
      await _prefs.setString(
        _autoSyncLastSuccessAtKey,
        status.lastSuccessAt!.toIso8601String(),
      );
    } else {
      await _prefs.remove(_autoSyncLastSuccessAtKey);
    }

    if (status.retryAt != null) {
      await _prefs.setString(
        _autoSyncRetryAtKey,
        status.retryAt!.toIso8601String(),
      );
    } else {
      await _prefs.remove(_autoSyncRetryAtKey);
    }

    if (status.retryAttempt > 0) {
      await _prefs.setInt(_autoSyncRetryAttemptKey, status.retryAttempt);
    } else {
      await _prefs.remove(_autoSyncRetryAttemptKey);
    }
  }

  DateTime? readAutoSyncNextRunAt() {
    final rawValue = _prefs.getString(_autoSyncNextRunAtKey);
    if (rawValue == null) {
      return null;
    }

    return DateTime.tryParse(rawValue);
  }

  Future<void> saveAutoSyncNextRunAt(DateTime? value) async {
    if (value == null) {
      await _prefs.remove(_autoSyncNextRunAtKey);
      return;
    }

    await _prefs.setString(_autoSyncNextRunAtKey, value.toIso8601String());
  }

  bool readBiometricUnlockEnabled() {
    return _prefs.getBool(_biometricUnlockEnabledKey) ?? false;
  }

  Future<void> saveBiometricUnlockEnabled(bool value) async {
    await _prefs.setBool(_biometricUnlockEnabledKey, value);
  }

  String readBiometricLockTrigger() {
    return _prefs.getString(_biometricLockTriggerKey) ?? 'onScreenOff';
  }

  Future<void> saveBiometricLockTrigger(String value) async {
    await _prefs.setString(_biometricLockTriggerKey, value);
  }

  bool readBiometricScreenOffLockPending() {
    return _prefs.getBool(_biometricScreenOffLockPendingKey) ?? false;
  }

  Future<void> saveBiometricScreenOffLockPending(bool value) async {
    await _prefs.setBool(_biometricScreenOffLockPendingKey, value);
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
