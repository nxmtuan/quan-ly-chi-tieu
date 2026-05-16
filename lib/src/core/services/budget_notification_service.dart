import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../core/utils/formatters.dart';

class BudgetNotificationService {
  BudgetNotificationService._();

  static const String _channelId = 'budget_alert_channel_id';
  static const String _channelName = 'Cảnh báo ngân sách';
  static const String _channelDescription =
      'Thông báo khi ngân sách của một danh mục gần hoặc đã vượt hạn mức';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static Future<void> Function({
    required String budgetId,
    required String categoryName,
    required double spentAmount,
    required double limitAmount,
  })?
  debugShowBudgetExceededOverride;
  static Future<void> Function({
    required String budgetId,
    required String categoryName,
    required double spentAmount,
    required double warningAmount,
    required double limitAmount,
  })?
  debugShowBudgetWarningOverride;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings: initializationSettings);

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      ),
    );

    _initialized = true;
  }

  static Future<bool?> requestPermission() async {
    await initialize();
    return _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static Future<void> showBudgetWarning({
    required String budgetId,
    required String categoryName,
    required double spentAmount,
    required double warningAmount,
    required double limitAmount,
  }) async {
    final override = debugShowBudgetWarningOverride;
    if (override != null) {
      await override(
        budgetId: budgetId,
        categoryName: categoryName,
        spentAmount: spentAmount,
        warningAmount: warningAmount,
        limitAmount: limitAmount,
      );
      return;
    }

    final body =
        '$categoryName đã dùng ${formatCurrency(spentAmount)}, chạm ngưỡng cảnh báo ${formatCurrency(warningAmount)} trên hạn mức ${formatCurrency(limitAmount)}.';

    await initialize();
    await _plugin.show(
      id: _notificationId(budgetId, 1),
      title: 'Ngân sách sắp vượt hạn mức',
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
    );
  }

  static Future<void> showBudgetExceeded({
    required String budgetId,
    required String categoryName,
    required double spentAmount,
    required double limitAmount,
  }) async {
    final override = debugShowBudgetExceededOverride;
    if (override != null) {
      await override(
        budgetId: budgetId,
        categoryName: categoryName,
        spentAmount: spentAmount,
        limitAmount: limitAmount,
      );
      return;
    }

    final body =
        '$categoryName đã dùng ${formatCurrency(spentAmount)}, vượt hạn mức ${formatCurrency(limitAmount)}.';

    await initialize();
    await _plugin.show(
      id: _notificationId(budgetId, 2),
      title: 'Ngân sách đã vượt hạn mức',
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
    );
  }

  static int _notificationId(String budgetId, int salt) {
    return budgetId.hashCode.abs() % 100000 + 700000 + salt * 100000;
  }
}
