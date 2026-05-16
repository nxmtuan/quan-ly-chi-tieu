import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/storage_provider.dart';
import 'app_data_refresh.dart';

Future<void> deleteAllLocalAppData(WidgetRef ref) async {
  await ref.read(transactionStorageProvider).clearAll();
  await ref.read(budgetStorageProvider).clearAll();
  await ref.read(savingsGoalStorageProvider).clearAll();
  await ref.read(categoryStorageProvider).clearAll();
  await ref.read(moneySourceStorageProvider).clearAll();
  await ref.read(recurringStorageProvider).clearAll();

  reloadAppData(ref);
}
