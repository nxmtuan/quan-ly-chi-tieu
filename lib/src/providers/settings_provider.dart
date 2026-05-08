import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/background/background_sync.dart';
import '../models/auto_sync_settings.dart';
import 'storage_provider.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final storedValue = ref.read(settingsStorageProvider).readThemeMode();

    return switch (storedValue) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode value) async {
    state = value;
    await ref.read(settingsStorageProvider).saveThemeMode(value.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class AutoSyncSettingsNotifier extends Notifier<AutoSyncSettings> {
  @override
  AutoSyncSettings build() {
    return ref.read(settingsStorageProvider).readAutoSyncSettings();
  }

  Future<void> save(AutoSyncSettings settings) async {
    state = settings;
    await ref.read(settingsStorageProvider).saveAutoSyncSettings(settings);
    await configureBackgroundSync(settings);
  }

  Future<void> setEnabled(bool enabled) async {
    await save(state.copyWith(enabled: enabled));
  }

  Future<void> updateSchedule({
    required AutoSyncScheduleType scheduleType,
    required int hour,
    required int minute,
    required int weekday,
  }) async {
    await save(
      state.copyWith(
        scheduleType: scheduleType,
        hour: hour,
        minute: minute,
        weekday: weekday,
      ),
    );
  }
}

final autoSyncSettingsProvider =
    NotifierProvider<AutoSyncSettingsNotifier, AutoSyncSettings>(
      AutoSyncSettingsNotifier.new,
    );
