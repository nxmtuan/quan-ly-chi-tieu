import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/budget_notification_service.dart';
import '../core/utils/date_range.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import 'budget_provider.dart';
import 'category_provider.dart';
import 'transaction_provider.dart';

final budgetAlertServiceProvider = Provider<BudgetAlertService>((ref) {
  return BudgetAlertService(ref);
});

class BudgetAlertService {
  const BudgetAlertService(this._ref);

  final Ref _ref;

  Future<void> notifyAfterTransactionChange({
    Transaction? previousTransaction,
    required Transaction currentTransaction,
  }) async {
    if (currentTransaction.type != TransactionType.expense) {
      return;
    }

    final currentMonth = DateTime(
      currentTransaction.date.year,
      currentTransaction.date.month,
    );
    final budgets = _ref.read(budgetsForMonthProvider(currentMonth));

    for (final budget in budgets) {
      if (budget.categoryId != currentTransaction.categoryId) {
        continue;
      }

      final afterSpent = _spentAmountForBudget(budget);
      final beforeSpent =
          afterSpent -
          currentTransaction.amount +
          _previousAmountForBudget(previousTransaction, budget);
      await _notifyIfCrossedBudgetMarkers(
        budget: budget,
        beforeSpent: beforeSpent,
        afterSpent: afterSpent,
      );
    }
  }

  Future<void> notifyAfterBudgetChange({
    Budget? previousBudget,
    required Budget currentBudget,
  }) async {
    final spentAmount = _spentAmountForBudget(currentBudget);
    final previousWarningAmount =
        previousBudget != null &&
            previousBudget.categoryId == currentBudget.categoryId &&
            previousBudget.periodStart == currentBudget.periodStart
        ? previousBudget.warningThresholdAmount
        : null;
    final previousLimit =
        previousBudget != null &&
            previousBudget.categoryId == currentBudget.categoryId &&
            previousBudget.periodStart == currentBudget.periodStart
        ? previousBudget.limitAmount
        : null;
    final wasWarningReached =
        previousWarningAmount != null && spentAmount >= previousWarningAmount;
    final wasExceeded = previousLimit != null && spentAmount > previousLimit;

    if (!wasWarningReached &&
        spentAmount >= currentBudget.warningThresholdAmount) {
      await _showWarning(currentBudget, spentAmount);
    }
    if (!wasExceeded && spentAmount > currentBudget.limitAmount) {
      await _showExceeded(currentBudget, spentAmount);
    }
  }

  Future<void> _notifyIfCrossedBudgetMarkers({
    required Budget budget,
    required double beforeSpent,
    required double afterSpent,
  }) async {
    if (beforeSpent < budget.warningThresholdAmount &&
        afterSpent >= budget.warningThresholdAmount) {
      await _showWarning(budget, afterSpent);
    }
    if (beforeSpent <= budget.limitAmount && afterSpent > budget.limitAmount) {
      await _showExceeded(budget, afterSpent);
    }
  }

  Future<void> _showWarning(Budget budget, double spentAmount) async {
    final category = _ref.read(categoryByIdProvider(budget.categoryId));
    await BudgetNotificationService.showBudgetWarning(
      budgetId: budget.id,
      categoryName: category?.name ?? 'Danh mục',
      spentAmount: spentAmount,
      warningAmount: budget.warningThresholdAmount,
      limitAmount: budget.limitAmount,
    );
  }

  Future<void> _showExceeded(Budget budget, double spentAmount) async {
    final category = _ref.read(categoryByIdProvider(budget.categoryId));
    await BudgetNotificationService.showBudgetExceeded(
      budgetId: budget.id,
      categoryName: category?.name ?? 'Danh mục',
      spentAmount: spentAmount,
      limitAmount: budget.limitAmount,
    );
  }

  double _spentAmountForBudget(Budget budget) {
    final range = monthDateRange(budget.periodStart);
    final transactions = _ref.read(
      transactionsQueryProvider((
        categoryId: budget.categoryId,
        fromDate: range.start,
        limit: null,
        toDate: range.end,
        type: TransactionType.expense,
      )),
    );

    return transactions.fold<double>(
      0,
      (total, transaction) => total + transaction.amount,
    );
  }

  double _previousAmountForBudget(Transaction? transaction, Budget budget) {
    if (transaction == null || transaction.type != TransactionType.expense) {
      return 0;
    }

    if (transaction.categoryId != budget.categoryId) {
      return 0;
    }

    final periodStart = budget.periodStart;
    final sameMonth =
        transaction.date.year == periodStart.year &&
        transaction.date.month == periodStart.month;
    return sameMonth ? transaction.amount : 0;
  }
}
