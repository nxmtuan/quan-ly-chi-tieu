import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SyncNotificationService {
  SyncNotificationService._();

  static const String _progressChannelId = 'sync_progress_channel_id';
  static const String _progressChannelName = 'Tiến trình đồng bộ dữ liệu';
  static const String _progressChannelDescription =
      'Thông báo khi ứng dụng đang chuẩn bị và thực hiện đồng bộ dữ liệu';

  static const String _resultChannelId = 'sync_result_channel_id';
  static const String _resultChannelName = 'Kết quả đồng bộ dữ liệu';
  static const String _resultChannelDescription =
      'Thông báo kết quả sau khi đồng bộ dữ liệu hoàn tất';

  static const int _progressNotificationId = 888;
  static const int _resultNotificationId = 889;
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
        _progressChannelId,
        _progressChannelName,
        description: _progressChannelDescription,
        importance: Importance.low,
      ),
    );
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _resultChannelId,
        _resultChannelName,
        description: _resultChannelDescription,
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

  static Future<void> showPreparing() async {
    const body = 'Đang chuẩn bị đồng bộ...';
    await initialize();
    await _plugin.cancel(id: _resultNotificationId);
    await _plugin.show(
      id: _progressNotificationId,
      title: 'Đồng bộ dữ liệu',
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _progressChannelId,
          _progressChannelName,
          channelDescription: _progressChannelDescription,
          importance: Importance.low,
          priority: Priority.low,
          styleInformation: BigTextStyleInformation(body),
          showProgress: true,
          indeterminate: true,
          onlyAlertOnce: true,
          ongoing: true,
          autoCancel: false,
        ),
      ),
    );
  }

  static Future<void> showSyncing() async {
    const body = 'Đang tiến hành đồng bộ...';
    await initialize();
    await _plugin.show(
      id: _progressNotificationId,
      title: 'Đồng bộ dữ liệu',
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _progressChannelId,
          _progressChannelName,
          channelDescription: _progressChannelDescription,
          importance: Importance.low,
          priority: Priority.low,
          styleInformation: BigTextStyleInformation(body),
          showProgress: true,
          indeterminate: true,
          onlyAlertOnce: true,
          ongoing: true,
          autoCancel: false,
        ),
      ),
    );
  }

  static Future<void> showSuccess([String? body]) async {
    await _showResult(
      body ?? 'Đồng bộ dữ liệu thành công.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
  }

  static Future<void> showFailure(String body) async {
    await _showResult(
      body,
      importance: Importance.high,
      priority: Priority.high,
    );
  }

  static Future<void> showInfo(String body) async {
    await _showResult(
      body,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
  }

  static Future<void> _showResult(
    String body, {
    required Importance importance,
    required Priority priority,
  }) async {
    await initialize();
    await _plugin.cancel(id: _progressNotificationId);
    await _plugin.show(
      id: _resultNotificationId,
      title: 'Đồng bộ dữ liệu',
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _resultChannelId,
          _resultChannelName,
          channelDescription: _resultChannelDescription,
          importance: importance,
          priority: priority,
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
    );
  }
}
