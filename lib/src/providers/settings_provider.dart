import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/background/background_sync.dart';
import '../core/services/biometric_auth_result.dart';
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

  Future<void> markFailure({
    required DateTime retryAt,
    required int retryAttempt,
  }) async {
    final nextState = AutoSyncStatus(
      type: AutoSyncStatusType.failure,
      lastSuccessAt: state.lastSuccessAt,
      retryAt: retryAt,
      retryAttempt: retryAttempt,
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

enum BiometricLockTrigger { onScreenOff, onAppExit, afterTwoMinutes }

extension BiometricLockTriggerLabel on BiometricLockTrigger {
  String get label {
    return switch (this) {
      BiometricLockTrigger.onScreenOff => 'Khóa ứng dụng khi tắt máy',
      BiometricLockTrigger.onAppExit => 'Khóa mỗi khi thoát app',
      BiometricLockTrigger.afterTwoMinutes =>
        'Khóa ứng dụng sau 2 phút rời app',
    };
  }
}

class BiometricLockState {
  const BiometricLockState({
    required this.enabled,
    required this.unlocked,
    required this.lockTrigger,
    this.isAuthenticating = false,
    this.lastResult,
  });

  final bool enabled;
  final bool unlocked;
  final BiometricLockTrigger lockTrigger;
  final bool isAuthenticating;
  final BiometricAuthResult? lastResult;

  bool get isLocked => enabled && !unlocked;

  String? get errorMessage {
    final result = lastResult;
    if (result == null || result.success) {
      return null;
    }

    return result.message;
  }

  bool get canRetry => lastResult?.canRetry ?? true;

  bool get canDisableLock => lastResult?.canDisableLock ?? false;

  BiometricLockState copyWith({
    bool? enabled,
    bool? unlocked,
    BiometricLockTrigger? lockTrigger,
    bool? isAuthenticating,
    BiometricAuthResult? lastResult,
    bool clearLastResult = false,
  }) {
    return BiometricLockState(
      enabled: enabled ?? this.enabled,
      unlocked: unlocked ?? this.unlocked,
      lockTrigger: lockTrigger ?? this.lockTrigger,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
      lastResult: clearLastResult ? null : lastResult ?? this.lastResult,
    );
  }
}

class BiometricLockNotifier extends Notifier<BiometricLockState> {
  @override
  BiometricLockState build() {
    final storage = ref.read(settingsStorageProvider);
    final enabled = storage.readBiometricUnlockEnabled();
    final lockTrigger = _lockTriggerFromStorage(
      storage.readBiometricLockTrigger(),
    );
    final shouldStartLocked =
        enabled &&
        switch (lockTrigger) {
          BiometricLockTrigger.onScreenOff =>
            storage.readBiometricScreenOffLockPending(),
          BiometricLockTrigger.onAppExit => true,
          BiometricLockTrigger.afterTwoMinutes => true,
        };

    return BiometricLockState(
      enabled: enabled,
      unlocked: !shouldStartLocked,
      lockTrigger: lockTrigger,
    );
  }

  Future<BiometricAuthResult> enable() async {
    state = state.copyWith(
      isAuthenticating: true,
      unlocked: true,
      clearLastResult: true,
    );

    final result = await ref
        .read(biometricAuthServiceProvider)
        .authenticate(
          reason: 'Xác thực bằng bảo mật thiết bị để bật mở khóa ứng dụng.',
        );

    if (result.success) {
      await ref.read(settingsStorageProvider).saveBiometricUnlockEnabled(true);
      await ref
          .read(settingsStorageProvider)
          .saveBiometricScreenOffLockPending(false);
      state = state.copyWith(
        enabled: true,
        unlocked: true,
        isAuthenticating: false,
        clearLastResult: true,
      );
      return result;
    }

    state = state.copyWith(
      enabled: false,
      unlocked: true,
      isAuthenticating: false,
      lastResult: result,
    );
    return result;
  }

  Future<void> disable() async {
    await ref.read(settingsStorageProvider).saveBiometricUnlockEnabled(false);
    await ref
        .read(settingsStorageProvider)
        .saveBiometricScreenOffLockPending(false);
    state = state.copyWith(
      enabled: false,
      unlocked: true,
      isAuthenticating: false,
      clearLastResult: true,
    );
  }

  Future<void> setLockTrigger(BiometricLockTrigger lockTrigger) async {
    state = state.copyWith(lockTrigger: lockTrigger);
    await ref
        .read(settingsStorageProvider)
        .saveBiometricLockTrigger(lockTrigger.name);
    if (lockTrigger != BiometricLockTrigger.onScreenOff) {
      await ref
          .read(settingsStorageProvider)
          .saveBiometricScreenOffLockPending(false);
    }
  }

  void lock() {
    if (!state.enabled || state.isAuthenticating) {
      return;
    }

    state = state.copyWith(unlocked: false, clearLastResult: true);
  }

  Future<void> lockForScreenOff() async {
    if (!state.enabled || state.isAuthenticating) {
      return;
    }

    await ref
        .read(settingsStorageProvider)
        .saveBiometricScreenOffLockPending(true);
    state = state.copyWith(unlocked: false, clearLastResult: true);
  }

  Future<BiometricAuthResult> unlock() async {
    if (!state.enabled) {
      const result = BiometricAuthResult.success();
      state = state.copyWith(enabled: false, unlocked: true);
      return result;
    }

    if (state.unlocked) {
      return const BiometricAuthResult.success();
    }

    state = state.copyWith(isAuthenticating: true, clearLastResult: true);

    final result = await ref
        .read(biometricAuthServiceProvider)
        .authenticate(reason: 'Xác thực bằng bảo mật thiết bị để mở ứng dụng.');

    if (result.success) {
      await ref
          .read(settingsStorageProvider)
          .saveBiometricScreenOffLockPending(false);
      state = state.copyWith(
        enabled: true,
        unlocked: true,
        isAuthenticating: false,
        clearLastResult: true,
      );
    } else {
      state = state.copyWith(
        unlocked: false,
        isAuthenticating: false,
        lastResult: result,
      );
    }

    return result;
  }

  BiometricLockTrigger _lockTriggerFromStorage(String value) {
    return switch (value) {
      'onAppExit' => BiometricLockTrigger.onAppExit,
      'afterTwoMinutes' => BiometricLockTrigger.afterTwoMinutes,
      _ => BiometricLockTrigger.onScreenOff,
    };
  }
}

final biometricLockProvider =
    NotifierProvider<BiometricLockNotifier, BiometricLockState>(
      BiometricLockNotifier.new,
    );
