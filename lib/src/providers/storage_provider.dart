import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage/auth_storage.dart';
import '../core/storage/category_storage.dart';
import '../core/storage/settings_storage.dart';
import '../core/storage/transaction_storage.dart';
import '../core/storage/objectbox_database.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/auth_user.dart';
import '../models/app_setting.dart';

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
  final store = ref.watch(objectBoxProvider).store;
  return SettingsStorage(store.box<AppSetting>());
});

final authStorageProvider = Provider<AuthStorage>((ref) {
  final store = ref.watch(objectBoxProvider).store;
  return AuthStorage(store.box<AuthUser>());
});
