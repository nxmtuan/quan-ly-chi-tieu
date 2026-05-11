import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../core/utils/formatters.dart';
import '../../models/recurring_item.dart';

class RecurringNotificationService {
  RecurringNotificationService._();

  static const String _channelId = 'recurring_activity_channel_id';
  static const String _channelName = 'Giao dịch và nhắc nhở định kỳ';
  static const String _channelDescription =
      'Thông báo khi giao dịch định kỳ được tạo hoặc lời nhắc sắp đến hạn';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

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

  static Future<void> showTransactionCreated(RecurringItem item) async {
    await _show(
      id: _notificationId(item, 1),
      title: 'Đã thêm giao dịch định kỳ',
      body: '${item.title} • ${formatCurrency(item.amount)}',
    );
  }

  static Future<void> showReminderUpcoming(RecurringItem item) async {
    await _show(
      id: _notificationId(item, 2),
      title: 'Sắp đến lời nhắc định kỳ',
      body: '${item.title} sẽ diễn ra vào ngày mai',
    );
  }

  static Future<void> showReminderDue(RecurringItem item) async {
    await _show(
      id: _notificationId(item, 3),
      title: 'Đến hạn lời nhắc định kỳ',
      body: '${item.title} • ${formatCurrency(item.amount)}',
    );
  }

  static Future<void> _show({
    required int id,
    required String title,
    required String body,
  }) async {
    await initialize();
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  static int _notificationId(RecurringItem item, int salt) {
    return item.id.hashCode.abs() % 100000 + salt * 100000;
  }
}
