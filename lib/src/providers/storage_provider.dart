import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import '../core/services/sync_service.dart';
import '../core/network/google_drive_service.dart';

import '../core/storage/auth_storage.dart';
import '../core/storage/category_storage.dart';
import '../core/storage/money_source_storage.dart';
import '../core/storage/recurring_storage.dart';
import '../core/storage/settings_storage.dart';
import '../core/storage/transaction_storage.dart';
import '../core/storage/objectbox_database.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/money_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

final objectBoxProvider = Provider<ObjectBoxDatabase>((ref) {
  throw UnimplementedError();
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final transactionStorageProvider = Provider<TransactionStorage>((ref) {
  final store = ref.watch(objectBoxProvider).store;
  return TransactionStorage(store.box<Transaction>());
});

final categoryStorageProvider = Provider<CategoryStorage>((ref) {
  final store = ref.watch(objectBoxProvider).store;
  return CategoryStorage(store.box<Category>());
});

final moneySourceStorageProvider = Provider<MoneySourceStorage>((ref) {
  final store = ref.watch(objectBoxProvider).store;
  return MoneySourceStorage(store.box<MoneySource>());
});

final recurringStorageProvider = Provider<RecurringStorage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return RecurringStorage(prefs);
});

final settingsStorageProvider = Provider<SettingsStorage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsStorage(prefs);
});

final authStorageProvider = Provider<AuthStorage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthStorage(prefs);
});

final syncServiceProvider = Provider.family<SyncService, drive.DriveApi>((
  ref,
  driveApi,
) {
  final store = ref.watch(objectBoxProvider).store;
  final driveService = GoogleDriveService(driveApi);
  final settingsStorage = ref.watch(settingsStorageProvider);
  return SyncService(
    driveService: driveService,
    settingsStorage: settingsStorage,
    transactionBox: store.box<Transaction>(),
    categoryBox: store.box<Category>(),
    moneySourceBox: store.box<MoneySource>(),
  );
});
