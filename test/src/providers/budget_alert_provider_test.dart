import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quan_ly_chi_tieu/src/core/services/budget_notification_service.dart';
import 'package:quan_ly_chi_tieu/src/models/budget.dart';
import 'package:quan_ly_chi_tieu/src/models/category.dart';
import 'package:quan_ly_chi_tieu/src/models/transaction.dart';
import 'package:quan_ly_chi_tieu/src/providers/budget_alert_provider.dart';
import 'package:quan_ly_chi_tieu/src/providers/budget_provider.dart';
import 'package:quan_ly_chi_tieu/src/providers/category_provider.dart';
import 'package:quan_ly_chi_tieu/src/providers/transaction_provider.dart';

void main() {
  tearDown(() {
    BudgetNotificationService.debugShowBudgetExceededOverride = null;
    BudgetNotificationService.debugShowBudgetWarningOverride = null;
  });

  group('BudgetAlertService', () {
    test('notifies when an expense crosses the warning threshold', () async {
      final budget = Budget(
        id: 'budget-food',
        categoryId: 'food',
        limitAmount: 1000000,
        warningPercent: 80,
        periodStart: DateTime(2026, 5),
      );
      final transactions = <Transaction>[];
      final container = _createContainer(
        budgets: [budget],
        transactions: transactions,
      );
      addTearDown(container.dispose);
      final notifications = <Map<String, Object?>>[];
      BudgetNotificationService.debugShowBudgetWarningOverride =
          ({
            required budgetId,
            required categoryName,
            required spentAmount,
            required warningAmount,
            required limitAmount,
          }) async {
            notifications.add({
              'type': 'warning',
              'budgetId': budgetId,
              'categoryName': categoryName,
              'spentAmount': spentAmount,
              'warningAmount': warningAmount,
              'limitAmount': limitAmount,
            });
          };

      final firstExpense = Transaction(
        id: 'tx-1',
        amount: 700000,
        type: TransactionType.expense,
        categoryId: 'food',
        date: DateTime(2026, 5, 10),
      );
      transactions.add(firstExpense);
      await container
          .read(budgetAlertServiceProvider)
          .notifyAfterTransactionChange(currentTransaction: firstExpense);
      expect(notifications, isEmpty);

      final warningExpense = Transaction(
        id: 'tx-2',
        amount: 150000,
        type: TransactionType.expense,
        categoryId: 'food',
        date: DateTime(2026, 5, 12),
      );
      transactions.add(warningExpense);
      container.invalidate(transactionsQueryProvider);
      await container
          .read(budgetAlertServiceProvider)
          .notifyAfterTransactionChange(currentTransaction: warningExpense);

      expect(notifications, hasLength(1));
      expect(notifications.single['type'], 'warning');
      expect(notifications.single['budgetId'], 'budget-food');
      expect(notifications.single['categoryName'], 'Ăn uống');
      expect(notifications.single['spentAmount'], 850000);
      expect(notifications.single['warningAmount'], 800000);
      expect(notifications.single['limitAmount'], 1000000);
    });

    test('notifies again when spending crosses the budget limit', () async {
      final transactions = <Transaction>[];
      final container = _createContainer(
        budgets: [
          Budget(
            id: 'budget-food',
            categoryId: 'food',
            limitAmount: 1000000,
            warningPercent: 80,
            periodStart: DateTime(2026, 5),
          ),
        ],
        transactions: transactions,
      );
      addTearDown(container.dispose);
      final notificationTypes = <String>[];
      BudgetNotificationService.debugShowBudgetWarningOverride =
          ({
            required budgetId,
            required categoryName,
            required spentAmount,
            required warningAmount,
            required limitAmount,
          }) async {
            notificationTypes.add('warning');
          };
      BudgetNotificationService.debugShowBudgetExceededOverride =
          ({
            required budgetId,
            required categoryName,
            required spentAmount,
            required limitAmount,
          }) async {
            notificationTypes.add('exceeded');
          };

      final firstExpense = Transaction(
        id: 'tx-1',
        amount: 850000,
        type: TransactionType.expense,
        categoryId: 'food',
        date: DateTime(2026, 5, 10),
      );
      transactions.add(firstExpense);
      await container
          .read(budgetAlertServiceProvider)
          .notifyAfterTransactionChange(currentTransaction: firstExpense);

      final nextExpense = Transaction(
        id: 'tx-2',
        amount: 200000,
        type: TransactionType.expense,
        categoryId: 'food',
        date: DateTime(2026, 5, 11),
      );
      transactions.add(nextExpense);
      container.invalidate(transactionsQueryProvider);
      await container
          .read(budgetAlertServiceProvider)
          .notifyAfterTransactionChange(currentTransaction: nextExpense);

      expect(notificationTypes, ['warning', 'exceeded']);
    });

    test(
      'does not notify again when thresholds were already crossed',
      () async {
        final transactions = <Transaction>[];
        final container = _createContainer(
          budgets: [
            Budget(
              id: 'budget-food',
              categoryId: 'food',
              limitAmount: 1000000,
              warningPercent: 80,
              periodStart: DateTime(2026, 5),
            ),
          ],
          transactions: transactions,
        );
        addTearDown(container.dispose);
        var notificationCount = 0;
        BudgetNotificationService.debugShowBudgetWarningOverride =
            ({
              required budgetId,
              required categoryName,
              required spentAmount,
              required warningAmount,
              required limitAmount,
            }) async {
              notificationCount++;
            };
        BudgetNotificationService.debugShowBudgetExceededOverride =
            ({
              required budgetId,
              required categoryName,
              required spentAmount,
              required limitAmount,
            }) async {
              notificationCount++;
            };

        final firstExpense = Transaction(
          id: 'tx-1',
          amount: 1200000,
          type: TransactionType.expense,
          categoryId: 'food',
          date: DateTime(2026, 5, 10),
        );
        transactions.add(firstExpense);
        await container
            .read(budgetAlertServiceProvider)
            .notifyAfterTransactionChange(currentTransaction: firstExpense);

        final nextExpense = Transaction(
          id: 'tx-2',
          amount: 100000,
          type: TransactionType.expense,
          categoryId: 'food',
          date: DateTime(2026, 5, 11),
        );
        transactions.add(nextExpense);
        container.invalidate(transactionsQueryProvider);
        await container
            .read(budgetAlertServiceProvider)
            .notifyAfterTransactionChange(currentTransaction: nextExpense);

        expect(notificationCount, 2);
      },
    );

    test(
      'notifies warning and exceeded when creating a budget below spending',
      () async {
        final budget = Budget(
          id: 'budget-food',
          categoryId: 'food',
          limitAmount: 500000,
          warningPercent: 80,
          periodStart: DateTime(2026, 5),
        );
        final container = _createContainer(
          budgets: [budget],
          transactions: [
            Transaction(
              id: 'tx-1',
              amount: 900000,
              type: TransactionType.expense,
              categoryId: 'food',
              date: DateTime(2026, 5, 10),
            ),
          ],
        );
        addTearDown(container.dispose);
        final notifications = <String>[];
        BudgetNotificationService.debugShowBudgetWarningOverride =
            ({
              required budgetId,
              required categoryName,
              required spentAmount,
              required warningAmount,
              required limitAmount,
            }) async {
              notifications.add('warning');
            };
        BudgetNotificationService.debugShowBudgetExceededOverride =
            ({
              required budgetId,
              required categoryName,
              required spentAmount,
              required limitAmount,
            }) async {
              notifications.add('exceeded');
            };

        await container
            .read(budgetAlertServiceProvider)
            .notifyAfterBudgetChange(currentBudget: budget);

        expect(notifications, ['warning', 'exceeded']);
      },
    );
  });
}

ProviderContainer _createContainer({
  required List<Budget> budgets,
  required List<Transaction> transactions,
}) {
  return ProviderContainer(
    overrides: [
      budgetsForMonthProvider.overrideWith((ref, month) {
        final periodStart = DateTime(month.year, month.month);
        return [
          for (final budget in budgets)
            if (budget.periodStart == periodStart) budget,
        ];
      }),
      transactionsQueryProvider.overrideWith((ref, args) {
        var results = transactions.where((transaction) {
          if (args.type != null && transaction.type != args.type) {
            return false;
          }
          if (args.categoryId != null &&
              transaction.categoryId != args.categoryId) {
            return false;
          }
          if (args.fromDate != null &&
              transaction.date.isBefore(args.fromDate!)) {
            return false;
          }
          if (args.toDate != null && transaction.date.isAfter(args.toDate!)) {
            return false;
          }
          return true;
        }).toList();

        results.sort((left, right) => right.date.compareTo(left.date));
        if (args.limit != null && results.length > args.limit!) {
          results = results.take(args.limit!).toList();
        }
        return results;
      }),
      categoryByIdProvider.overrideWith((ref, id) {
        if (id == 'food') {
          return Category(
            id: 'food',
            name: 'Ăn uống',
            iconData: Icons.restaurant_rounded,
            colorHex: 0xFFEF4444,
            type: TransactionType.expense,
          );
        }
        return null;
      }),
    ],
  );
}
