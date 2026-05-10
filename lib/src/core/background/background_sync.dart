import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../models/auto_sync_settings.dart';
import '../../models/auto_sync_status.dart';
import '../../providers/auth_provider.dart';
import '../../providers/storage_provider.dart';
import '../services/sync_notification_service.dart';
import '../storage/settings_storage.dart';
import '../storage/objectbox_database.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    ProviderContainer? container;
    ObjectBoxDatabase? objectBoxDb;

    try {
      WidgetsFlutterBinding.ensureInitialized();
      await SyncNotificationService.showPreparing();

      // Khởi tạo các dependencies cần thiết
      objectBoxDb = await ObjectBoxDatabase.create();
      final prefs = await SharedPreferences.getInstance();

      container = ProviderContainer(
        overrides: [
          objectBoxProvider.overrideWithValue(objectBoxDb),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      // Kiểm tra đăng nhập
      final authUser = container.read(authProvider);
      if (authUser == null) {
        await SyncNotificationService.showInfo(
          'Không thể đồng bộ: chưa đăng nhập Google.',
        );
        final settings = SettingsStorage(prefs).readAutoSyncSettings();
        await _scheduleBackgroundSync(settings);
        return Future.value(true);
      }

      // Lấy DriveApi
      final driveApi = await container.read(authProvider.notifier).getDriveApi();
      if (driveApi == null) {
        await SyncNotificationService.showInfo(
          'Không thể đồng bộ: phiên Google đã hết hạn. Mở ứng dụng để đăng nhập lại.',
        );
        final settings = SettingsStorage(prefs).readAutoSyncSettings();
        await _scheduleBackgroundSync(settings);
        return Future.value(true);
      }

      await SyncNotificationService.showSyncing();

      // Tiến hành đồng bộ
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
      await _scheduleBackgroundSync(settings);

      return Future.value(true);
    } catch (e) {
      debugPrint('Background sync failed: $e');
      final prefs = await SharedPreferences.getInstance();
      final settingsStorage = SettingsStorage(prefs);
      final currentStatus = settingsStorage.readAutoSyncStatus();
      await settingsStorage.saveAutoSyncStatus(
        AutoSyncStatus(
          type: AutoSyncStatusType.failure,
          lastSuccessAt: currentStatus.lastSuccessAt,
          retryAt: DateTime.now().add(_autoSyncRetryDelay),
        ),
      );
      await SyncNotificationService.showFailure(
        'Đồng bộ thất bại. Sẽ thử lại sau.',
      );
      // Trả về false để WorkManager retry
      return Future.value(false);
    } finally {
      container?.dispose();
      objectBoxDb?.store.close();
    }
  });
}

const _autoSyncTaskName = 'configured_auto_sync_task';
const _autoSyncTaskId = 'sync_to_drive';
const _autoSyncTaskTag = 'auto_sync_schedule';
const _autoSyncRetryDelay = Duration(minutes: 15);

Future<void> cancelBackgroundSync() async {
  await Workmanager().cancelByTag(_autoSyncTaskTag);
}

Future<void> configureBackgroundSync(AutoSyncSettings settings) async {
  await cancelBackgroundSync();
  if (!settings.enabled) {
    return;
  }

  await _scheduleBackgroundSync(settings);
}

Future<void> _scheduleBackgroundSync(
  AutoSyncSettings settings, {
  DateTime? now,
}) async {
  if (!settings.enabled) {
    return;
  }

  final scheduledFrom = now ?? DateTime.now();
  final nextRun = switch (settings.scheduleType) {
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
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
    backoffPolicy: BackoffPolicy.linear,
    backoffPolicyDelay: const Duration(minutes: 15),
    existingWorkPolicy: ExistingWorkPolicy.replace,
    tag: _autoSyncTaskTag,
  );
}

Future<void> configureBackgroundSyncFromPreferences(
  SharedPreferences prefs,
) async {
  final settings = SettingsStorage(prefs).readAutoSyncSettings();
  await configureBackgroundSync(settings);
}

DateTime _nextDailyRun(DateTime now, int hour, int minute) {
  var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
  if (!scheduled.isAfter(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}

DateTime _nextWeeklyRun(
  DateTime now,
  int weekday,
  int hour,
  int minute,
) {
  final currentWeekday = now.weekday;
  var dayDelta = weekday - currentWeekday;
  var scheduled = DateTime(now.year, now.month, now.day, hour, minute)
      .add(Duration(days: dayDelta));

  if (!scheduled.isAfter(now)) {
    scheduled = scheduled.add(const Duration(days: 7));
  }

  return scheduled;
}
