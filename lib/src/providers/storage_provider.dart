import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/storage/auth_storage.dart';
import '../core/storage/category_storage.dart';
import '../core/storage/settings_storage.dart';
import '../core/storage/transaction_storage.dart';
import '../core/storage/objectbox_database.dart';
import '../models/transaction.dart';
import '../models/category.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final objectBoxProvider = Provider<ObjectBoxDatabase>((ref) {
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

final settingsStorageProvider = Provider<SettingsStorage>((ref) {
  return SettingsStorage(ref.watch(sharedPreferencesProvider));
});

final authStorageProvider = Provider<AuthStorage>((ref) {
  return AuthStorage(ref.watch(sharedPreferencesProvider));
});
