import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/money_source_provider.dart';
import '../../providers/recurring_provider.dart';
import '../../providers/savings_goal_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';

Future<void> refreshAppData(WidgetRef ref) async {
  reloadAppData(ref);
}

void reloadAppData(WidgetRef ref) {
  ref.read(transactionsProvider.notifier).reload();
  ref.read(categoriesProvider.notifier).reload();
  ref.read(moneySourcesProvider.notifier).reload();
  ref.read(savingsGoalsProvider.notifier).reload();
  ref.read(budgetsProvider.notifier).reload();
  ref.read(recurringItemsProvider.notifier).reload();
  ref.read(autoSyncStatusProvider.notifier).reload();
}
