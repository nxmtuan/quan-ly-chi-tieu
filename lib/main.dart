import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'src/app.dart';
import 'src/core/services/sync_notification_service.dart';
import 'src/core/services/recurring_notification_service.dart';
import 'src/core/services/budget_notification_service.dart';
import 'src/providers/storage_provider.dart';
import 'src/core/storage/objectbox_database.dart';

import 'package:workmanager/workmanager.dart';
import 'src/core/background/background_recurring.dart';
import 'src/core/background/background_sync.dart';
import 'src/core/storage/recurring_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN');

  await Workmanager().initialize(callbackDispatcher);
  final prefs = await SharedPreferences.getInstance();
  await configureBackgroundSyncFromPreferences(prefs);
  await configureRecurringBackgroundProcessingFromStorage(
    RecurringStorage(prefs),
  );

  await SyncNotificationService.initialize();
  await SyncNotificationService.requestPermission();
  await RecurringNotificationService.initialize();
  await RecurringNotificationService.requestPermission();
  await BudgetNotificationService.initialize();
  await BudgetNotificationService.requestPermission();

  final objectBoxDb = await ObjectBoxDatabase.create();

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
