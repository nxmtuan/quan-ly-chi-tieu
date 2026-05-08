import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../providers/auth_provider.dart';
import '../../providers/storage_provider.dart';
import '../storage/objectbox_database.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    
    try {
      WidgetsFlutterBinding.ensureInitialized();
      
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
      );

      // Hiển thị thông báo chuẩn bị
      await flutterLocalNotificationsPlugin.show(
        id: 888,
        title: 'Đồng bộ dữ liệu',
        body: 'Đang chuẩn bị đồng bộ...',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'sync_channel_id',
            'Đồng bộ dữ liệu',
            channelDescription: 'Thông báo tiến trình đồng bộ dữ liệu',
            importance: Importance.low,
            priority: Priority.low,
            showProgress: true,
            indeterminate: true,
            onlyAlertOnce: true,
          ),
        ),
      );

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
        await flutterLocalNotificationsPlugin.cancel(id: 888);
        return Future.value(true);
      }

      // Lấy DriveApi
      final driveApi = await container.read(authProvider.notifier).getDriveApi();
      if (driveApi == null) {
        await flutterLocalNotificationsPlugin.cancel(id: 888);
        return Future.value(true);
      }

      // Hiển thị thông báo đang đồng bộ
      await flutterLocalNotificationsPlugin.show(
        id: 888,
        title: 'Đồng bộ dữ liệu',
        body: 'Đang tiến hành đồng bộ...',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'sync_channel_id',
            'Đồng bộ dữ liệu',
            channelDescription: 'Thông báo tiến trình đồng bộ dữ liệu',
            importance: Importance.low,
            priority: Priority.low,
            showProgress: true,
            indeterminate: true,
            onlyAlertOnce: true,
          ),
        ),
      );

      // Tiến hành đồng bộ
      final syncService = container.read(syncServiceProvider(driveApi));
      await syncService.syncData();

      // Đồng bộ thành công thì xóa luôn thông báo
      await flutterLocalNotificationsPlugin.cancel(id: 888);

      return Future.value(true);
    } catch (e) {
      // Đồng bộ thất bại thì thông báo thất bại
      await flutterLocalNotificationsPlugin.show(
        id: 889,
        title: 'Đồng bộ dữ liệu',
        body: 'Đồng bộ thất bại. Sẽ thử lại sau.',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'sync_channel_id',
            'Đồng bộ dữ liệu',
            channelDescription: 'Thông báo tiến trình đồng bộ dữ liệu',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
      await flutterLocalNotificationsPlugin.cancel(id: 888);
      // Trả về false để WorkManager retry
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
