import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../providers/auth_provider.dart';
import '../../providers/storage_provider.dart';
import '../storage/objectbox_database.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      // Khởi tạo các dependencies cần thiết
      final objectBoxDb = await ObjectBoxDatabase.create();
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          objectBoxProvider.overrideWithValue(objectBoxDb),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      // Kiểm tra đăng nhập
      final authUser = container.read(authProvider);
      if (authUser == null) {
        return Future.value(true);
      }

      // Lấy DriveApi
      final driveApi = await container.read(authProvider.notifier).getDriveApi();
      if (driveApi == null) {
        return Future.value(true);
      }

      // Tiến hành đồng bộ
      final syncService = container.read(syncServiceProvider(driveApi));
      await syncService.syncData();

      return Future.value(true);
    } catch (e) {
      // Nếu có lỗi mạng hoặc lỗi khác, trả về false để WorkManager retry
      return Future.value(false);
    }
  });
}

void scheduleBackgroundSync() {
  final now = DateTime.now();
  var nextMidnight = DateTime(now.year, now.month, now.day + 1);
  final delay = nextMidnight.difference(now);

  Workmanager().registerPeriodicTask(
    "daily_sync_task",
    "sync_to_drive",
    frequency: const Duration(hours: 24),
    initialDelay: delay,
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
    backoffPolicy: BackoffPolicy.linear,
    backoffPolicyDelay: const Duration(minutes: 15),
  );
}
