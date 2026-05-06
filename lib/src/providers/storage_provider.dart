import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/storage/transaction_storage.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final transactionStorageProvider = Provider<TransactionStorage>((ref) {
  return TransactionStorage(ref.watch(sharedPreferencesProvider));
});
