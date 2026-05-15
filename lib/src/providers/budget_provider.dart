import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/date_range.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import 'storage_provider.dart';
import 'transaction_provider.dart';

class BudgetsNotifier extends Notifier<List<Budget>> {
  @override
  List<Budget> build() {
    return _loadVisibleBudgets();
  }

  List<Budget> _loadVisibleBudgets() {
    return [
      for (final budget
          in ref.read(budgetStorageProvider).readBudgets(includeDeleted: true))
        if (!budget.isDeleted) budget,
    ];
  }

  void reload() {
    state = _loadVisibleBudgets();
  }

  Future<void> addBudget(Budget budget) async {
    final budgetToSave = budget.copyWith(updatedAt: DateTime.now());
    state = _sorted([...state, budgetToSave]);
    await ref.read(budgetStorageProvider).putBudget(budgetToSave);
  }

  Future<void> updateBudget(Budget budget) async {
    final budgetToSave = budget.copyWith(updatedAt: DateTime.now());
    state = _sorted([
      for (final item in state)
        if (item.id == budget.id) budgetToSave else item,
    ]);
    await ref.read(budgetStorageProvider).putBudget(budgetToSave);
  }

  Future<void> deleteBudget(String id) async {
    state = state.where((budget) => budget.id != id).toList();
    await ref.read(budgetStorageProvider).markBudgetDeleted(id);
  }

  static List<Budget> _sorted(List<Budget> budgets) {
    return [...budgets]..sort((left, right) {
      final periodResult = right.periodStart.compareTo(left.periodStart);
      if (periodResult != 0) {
        return periodResult;
      }

      return right.updatedAt.compareTo(left.updatedAt);
    });
  }
}

final budgetsProvider = NotifierProvider<BudgetsNotifier, List<Budget>>(
  BudgetsNotifier.new,
);

final budgetsForMonthProvider = Provider.family<List<Budget>, DateTime>((
  ref,
  month,
) {
  final periodStart = DateTime(month.year, month.month);
  return [
    for (final budget in ref.watch(budgetsProvider))
      if (budget.periodStart == periodStart) budget,
  ];
});

final budgetSpentByCategoryProvider =
    Provider.family<Map<String, double>, DateTime>((ref, month) {
      final range = monthDateRange(month);
      final transactions = ref.watch(
        transactionsQueryProvider((
          categoryId: null,
          fromDate: range.start,
          limit: null,
          toDate: range.end,
          type: TransactionType.expense,
        )),
      );
      final amounts = <String, double>{};

      for (final transaction in transactions) {
        amounts[transaction.categoryId] =
            (amounts[transaction.categoryId] ?? 0) + transaction.amount;
      }

      return amounts;
    });
