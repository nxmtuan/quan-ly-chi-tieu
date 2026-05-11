import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../models/auto_sync_settings.dart';
import '../../models/auto_sync_status.dart';
import '../../models/transaction.dart';
import '../../providers/auth_provider.dart';
import '../../providers/storage_provider.dart';
import '../storage/recurring_storage.dart';
import '../services/sync_notification_service.dart';
import '../storage/objectbox_database.dart';
import '../storage/settings_storage.dart';
import '../storage/transaction_storage.dart';
import 'background_recurring.dart';

const _autoSyncTaskName = 'configured_auto_sync_task';
const _autoSyncTaskId = 'sync_to_drive';
const _autoSyncTaskTag = 'auto_sync_schedule';
const _autoSyncRetryDelay = Duration(minutes: 15);

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    ProviderContainer? container;
    ObjectBoxDatabase? objectBoxDb;

    try {
      WidgetsFlutterBinding.ensureInitialized();

      objectBoxDb = await ObjectBoxDatabase.create();
      final prefs = await SharedPreferences.getInstance();

      if (task == recurringTaskName) {
        await processRecurringItems(
          recurringStorage: RecurringStorage(prefs),
          transactionStorage: TransactionStorage(
            objectBoxDb.store.box<Transaction>(),
          ),
        );
        return Future.value(true);
      }

      await SyncNotificationService.showPreparing();

      container = ProviderContainer(
        overrides: [
          objectBoxProvider.overrideWithValue(objectBoxDb),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final authUser = container.read(authProvider);
      if (authUser == null) {
        await SyncNotificationService.showInfo(
          'Không thể đồng bộ: chưa đăng nhập Google.',
        );
        final settingsStorage = SettingsStorage(prefs);
        final settings = settingsStorage.readAutoSyncSettings();
        await _scheduleBackgroundSync(
          settings,
          settingsStorage: settingsStorage,
        );
        return Future.value(true);
      }

      final driveApi = await container
          .read(authProvider.notifier)
          .getDriveApi();
      if (driveApi == null) {
        await SyncNotificationService.showInfo(
          'Không thể đồng bộ: phiên Google đã hết hạn. Mở ứng dụng để đăng nhập lại.',
        );
        final settingsStorage = SettingsStorage(prefs);
        final settings = settingsStorage.readAutoSyncSettings();
        await _scheduleBackgroundSync(
          settings,
          settingsStorage: settingsStorage,
        );
        return Future.value(true);
      }

      await SyncNotificationService.showSyncing();

      final syncService = container.read(syncServiceProvider(driveApi));
      await syncService.syncData();

      final settingsStorage = SettingsStorage(prefs);
      await settingsStorage.saveAutoSyncStatus(
        AutoSyncStatus(
          type: AutoSyncStatusType.success,
          lastSuccessAt: DateTime.now(),
        ),
      );

      await SyncNotificationService.showSuccess();
      final settings = settingsStorage.readAutoSyncSettings();
      await _scheduleBackgroundSync(settings, settingsStorage: settingsStorage);

      return Future.value(true);
    } catch (e) {
      debugPrint('Background sync failed: $e');
      final prefs = await SharedPreferences.getInstance();
      final settingsStorage = SettingsStorage(prefs);
      final currentStatus = settingsStorage.readAutoSyncStatus();
      final retryAt = DateTime.now().add(_autoSyncRetryDelay);

      await settingsStorage.saveAutoSyncStatus(
        AutoSyncStatus(
          type: AutoSyncStatusType.failure,
          lastSuccessAt: currentStatus.lastSuccessAt,
          retryAt: retryAt,
        ),
      );
      await settingsStorage.saveAutoSyncNextRunAt(retryAt);
      await SyncNotificationService.showFailure(
        'Đồng bộ thất bại. Sẽ thử lại sau.',
      );
      return Future.value(false);
    } finally {
      container?.dispose();
      objectBoxDb?.store.close();
    }
  });
}

Future<void> cancelBackgroundSync() async {
  await Workmanager().cancelByTag(_autoSyncTaskTag);
}

Future<void> configureBackgroundSync(AutoSyncSettings settings) async {
  await cancelBackgroundSync();
  if (!settings.enabled) {
    final prefs = await SharedPreferences.getInstance();
    await SettingsStorage(prefs).saveAutoSyncNextRunAt(null);
    return;
  }

  await _scheduleBackgroundSync(settings);
}

Future<void> _scheduleBackgroundSync(
  AutoSyncSettings settings, {
  DateTime? now,
  DateTime? scheduledFor,
  SettingsStorage? settingsStorage,
}) async {
  if (!settings.enabled) {
    return;
  }

  final scheduledFrom = now ?? DateTime.now();
  final nextRun =
      scheduledFor ??
      switch (settings.scheduleType) {
        AutoSyncScheduleType.daily => _nextDailyRun(
          scheduledFrom,
          settings.hour,
          settings.minute,
        ),
        AutoSyncScheduleType.weekly => _nextWeeklyRun(
          scheduledFrom,
          settings.weekday,
          settings.hour,
          settings.minute,
        ),
      };

  await Workmanager().registerOneOffTask(
    '${_autoSyncTaskName}_${nextRun.millisecondsSinceEpoch}',
    _autoSyncTaskId,
    initialDelay: nextRun.difference(scheduledFrom),
    constraints: Constraints(networkType: NetworkType.connected),
    backoffPolicy: BackoffPolicy.linear,
    backoffPolicyDelay: const Duration(minutes: 15),
    existingWorkPolicy: ExistingWorkPolicy.replace,
    tag: _autoSyncTaskTag,
  );

  final storage =
      settingsStorage ?? SettingsStorage(await SharedPreferences.getInstance());
  await storage.saveAutoSyncNextRunAt(nextRun);
}

Future<void> configureBackgroundSyncFromPreferences(
  SharedPreferences prefs, {
  DateTime? now,
}) async {
  final settingsStorage = SettingsStorage(prefs);
  final settings = settingsStorage.readAutoSyncSettings();

  await cancelBackgroundSync();
  if (!settings.enabled) {
    await settingsStorage.saveAutoSyncNextRunAt(null);
    return;
  }

  final scheduledFrom = now ?? DateTime.now();
  final restoredNextRun = resolveNextAutoSyncRunTime(
    settings: settings,
    status: settingsStorage.readAutoSyncStatus(),
    now: scheduledFrom,
    persistedNextRunAt: settingsStorage.readAutoSyncNextRunAt(),
  );

  await _scheduleBackgroundSync(
    settings,
    now: scheduledFrom,
    scheduledFor: restoredNextRun,
    settingsStorage: settingsStorage,
  );
}

DateTime resolveNextAutoSyncRunTime({
  required AutoSyncSettings settings,
  required AutoSyncStatus status,
  required DateTime now,
  DateTime? persistedNextRunAt,
}) {
  final retryAt = status.retryAt;
  if (retryAt != null && retryAt.isAfter(now)) {
    return retryAt;
  }

  if (persistedNextRunAt != null) {
    if (persistedNextRunAt.isAfter(now)) {
      return persistedNextRunAt;
    }
    return now;
  }

  return switch (settings.scheduleType) {
    AutoSyncScheduleType.daily => _nextDailyRun(
      now,
      settings.hour,
      settings.minute,
    ),
    AutoSyncScheduleType.weekly => _nextWeeklyRun(
      now,
      settings.weekday,
      settings.hour,
      settings.minute,
    ),
  };
}

DateTime _nextDailyRun(DateTime now, int hour, int minute) {
  var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
  if (!scheduled.isAfter(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}

DateTime _nextWeeklyRun(DateTime now, int weekday, int hour, int minute) {
  final currentWeekday = now.weekday;
  final dayDelta = weekday - currentWeekday;
  var scheduled = DateTime(
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  ).add(Duration(days: dayDelta));

  if (!scheduled.isAfter(now)) {
    scheduled = scheduled.add(const Duration(days: 7));
  }

  return scheduled;
}
