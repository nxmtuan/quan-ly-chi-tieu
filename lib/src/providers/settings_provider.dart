import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/background/background_sync.dart';
import '../models/auto_sync_settings.dart';
import '../models/auto_sync_status.dart';
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

class AutoSyncStatusNotifier extends Notifier<AutoSyncStatus> {
  @override
  AutoSyncStatus build() {
    return ref.read(settingsStorageProvider).readAutoSyncStatus();
  }

  void reload() {
    state = ref.read(settingsStorageProvider).readAutoSyncStatus();
  }

  Future<void> markSuccess(DateTime at) async {
    final nextState = AutoSyncStatus(
      type: AutoSyncStatusType.success,
      lastSuccessAt: at,
    );
    state = nextState;
    await ref.read(settingsStorageProvider).saveAutoSyncStatus(nextState);
  }

  Future<void> markFailure({required DateTime retryAt}) async {
    final nextState = AutoSyncStatus(
      type: AutoSyncStatusType.failure,
      lastSuccessAt: state.lastSuccessAt,
      retryAt: retryAt,
    );
    state = nextState;
    await ref.read(settingsStorageProvider).saveAutoSyncStatus(nextState);
  }

  Future<void> reset() async {
    const nextState = AutoSyncStatus.idle();
    state = nextState;
    await ref.read(settingsStorageProvider).saveAutoSyncStatus(nextState);
  }
}

final autoSyncStatusProvider =
    NotifierProvider<AutoSyncStatusNotifier, AutoSyncStatus>(
      AutoSyncStatusNotifier.new,
    );
