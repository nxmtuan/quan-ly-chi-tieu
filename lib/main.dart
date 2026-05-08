import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'src/app.dart';
import 'src/providers/storage_provider.dart';
import 'src/core/storage/objectbox_database.dart';

import 'package:workmanager/workmanager.dart';
import 'src/core/background/background_sync.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN');
  
  Workmanager().initialize(callbackDispatcher);
  scheduleBackgroundSync();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  final objectBoxDb = await ObjectBoxDatabase.create();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        objectBoxProvider.overrideWithValue(objectBoxDb),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const ExpenseManagerApp(),
    ),
  );
}
