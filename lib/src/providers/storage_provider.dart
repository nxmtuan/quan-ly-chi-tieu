import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/storage/auth_storage.dart';
import '../core/storage/category_storage.dart';
import '../core/storage/settings_storage.dart';
import '../core/storage/transaction_storage.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final transactionStorageProvider = Provider<TransactionStorage>((ref) {
  return TransactionStorage(ref.watch(sharedPreferencesProvider));
});

final categoryStorageProvider = Provider<CategoryStorage>((ref) {
  return CategoryStorage(ref.watch(sharedPreferencesProvider));
});

final settingsStorageProvider = Provider<SettingsStorage>((ref) {
  return SettingsStorage(ref.watch(sharedPreferencesProvider));
});

final authStorageProvider = Provider<AuthStorage>((ref) {
  return AuthStorage(ref.watch(sharedPreferencesProvider));
});
