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

  static Future<void> showReminderUpcomingGroup({
    required DateTime date,
    required List<RecurringItem> items,
  }) async {
    if (items.isEmpty) {
      return;
    }

    await _show(
      id: _dateNotificationId(date, 2),
      title: 'Lời nhắc cho ngày mai',
      body:
          'Bạn có ${items.length} lời nhắc vào ngày mai (${formatShortDate(date)}). ${_previewItems(items)}',
    );
  }

  static Future<void> showReminderDueGroup({
    required DateTime date,
    required List<RecurringItem> items,
  }) async {
    if (items.isEmpty) {
      return;
    }

    await _show(
      id: _dateNotificationId(date, 3),
      title: 'Lời nhắc cần thực hiện hôm nay',
      body:
          'Bạn có ${items.length} lời nhắc cần thực hiện vào hôm nay. Bỏ qua thông báo này nếu bạn đã hoàn thành. ${_previewItems(items)}',
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

  static int _dateNotificationId(DateTime date, int salt) {
    return date.year * 10000 + date.month * 100 + date.day + salt * 100000000;
  }

  static String _previewItems(List<RecurringItem> items) {
    final titles = items.take(3).map((item) => item.title).join(', ');
    if (items.length <= 3) {
      return titles;
    }
    return '$titles và ${items.length - 3} lời nhắc khác';
  }
}
