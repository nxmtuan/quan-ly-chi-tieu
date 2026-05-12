import 'package:flutter_test/flutter_test.dart';

import 'package:quan_ly_chi_tieu/src/core/services/sync_service.dart';
import 'package:quan_ly_chi_tieu/src/models/category.dart';
import 'package:quan_ly_chi_tieu/src/models/money_source.dart';
import 'package:quan_ly_chi_tieu/src/models/recurring_item.dart';
import 'package:quan_ly_chi_tieu/src/models/savings_goal.dart';
import 'package:quan_ly_chi_tieu/src/models/transaction.dart';

void main() {
  group('buildSyncSnapshot', () {
    test('purges expired soft-deleted records and compacts legacy fields', () {
      final now = DateTime.now();
      final expiredDeletedAt = now.subtract(const Duration(days: 45));
      final recentDeletedAt = now.subtract(const Duration(days: 7));

      final snapshot = buildSyncSnapshot(
        localCategories: [
          Category(
            id: 'keep-category',
            name: 'Keep',
            colorHex: 0xFF10B981,
            dbType: TransactionType.income.name,
            updatedAt: now.subtract(const Duration(days: 2)),
          ),
          Category(
            id: 'purge-category-local',
            name: 'Old deleted local',
            colorHex: 0xFFEF4444,
            dbType: TransactionType.expense.name,
            updatedAt: expiredDeletedAt,
            isDeleted: true,
          ),
        ],
        remoteCategories: [
          Category(
            id: 'purge-category-remote',
            name: 'Old deleted remote',
            colorHex: 0xFF2563EB,
            type: TransactionType.expense,
            updatedAt: expiredDeletedAt,
            isDeleted: true,
          ),
        ],
        localTransactions: [
          Transaction(
            id: 'keep-local',
            amount: 150000,
            dbType: TransactionType.income.name,
            categoryId: 'keep-category',
            date: now.subtract(const Duration(days: 3)),
            note: '',
            updatedAt: now.subtract(const Duration(days: 2)),
          ),
          Transaction(
            id: 'purge-local',
            amount: 50000,
            dbType: TransactionType.expense.name,
            categoryId: 'purge-category-local',
            date: expiredDeletedAt,
            note: '',
            updatedAt: expiredDeletedAt,
            isDeleted: true,
          ),
        ],
        remoteTransactions: [
          Transaction(
            id: 'keep-remote',
            amount: 250000,
            type: TransactionType.expense,
            categoryId: 'keep-category',
            date: now.subtract(const Duration(days: 1)),
            note: '',
            updatedAt: now.subtract(const Duration(hours: 12)),
          ),
          Transaction(
            id: 'purge-remote',
            amount: 100000,
            type: TransactionType.expense,
            categoryId: 'purge-category-remote',
            date: expiredDeletedAt,
            note: '',
            updatedAt: expiredDeletedAt,
            isDeleted: true,
          ),
          Transaction(
            id: 'keep-recent-delete',
            amount: 80000,
            type: TransactionType.expense,
            categoryId: 'keep-category',
            date: recentDeletedAt,
            note: '',
            updatedAt: recentDeletedAt,
            isDeleted: true,
          ),
        ],
        localMoneySources: [
          MoneySource(
            id: defaultMoneySourceId,
            name: 'Tiền mặt',
            updatedAt: now.subtract(const Duration(days: 2)),
          ),
          MoneySource(
            id: 'purge-source-local',
            name: 'Old deleted source local',
            updatedAt: expiredDeletedAt,
            isDeleted: true,
          ),
        ],
        remoteMoneySources: [
          MoneySource(
            id: 'bank',
            name: 'Ngân hàng',
            updatedAt: now.subtract(const Duration(days: 1)),
          ),
          MoneySource(
            id: 'purge-source-remote',
            name: 'Old deleted source remote',
            updatedAt: expiredDeletedAt,
            isDeleted: true,
          ),
        ],
        localSavingsGoals: [
          SavingsGoal(
            id: 'keep-goal-local',
            title: 'Emergency fund',
            targetAmount: 5000000,
            savedAmount: 1200000,
            updatedAt: now.subtract(const Duration(days: 2)),
          ),
          SavingsGoal(
            id: 'merge-goal',
            title: 'Old local goal',
            targetAmount: 3000000,
            savedAmount: 1000000,
            updatedAt: now.subtract(const Duration(days: 4)),
          ),
          SavingsGoal(
            id: 'purge-goal-local',
            title: 'Old deleted goal local',
            targetAmount: 1000000,
            savedAmount: 100000,
            updatedAt: expiredDeletedAt,
            isDeleted: true,
          ),
        ],
        remoteSavingsGoals: [
          SavingsGoal(
            id: 'keep-goal-remote',
            title: 'Remote fund',
            targetAmount: 2000000,
            savedAmount: 500000,
            updatedAt: now.subtract(const Duration(hours: 5)),
          ),
          SavingsGoal(
            id: 'merge-goal',
            title: 'New remote goal',
            targetAmount: 4000000,
            savedAmount: 1500000,
            updatedAt: now.subtract(const Duration(hours: 1)),
          ),
          SavingsGoal(
            id: 'purge-goal-remote',
            title: 'Old deleted goal remote',
            targetAmount: 1000000,
            savedAmount: 100000,
            updatedAt: expiredDeletedAt,
            isDeleted: true,
          ),
        ],
        localRecurringItems: [
          RecurringItem(
            id: 'keep-recurring-local',
            kind: RecurringItemKind.transaction,
            type: TransactionType.expense,
            amount: 120000,
            categoryId: 'keep-category',
            sourceId: defaultMoneySourceId,
            startDate: now,
            frequency: RecurrenceFrequency.monthly,
            nextRunAt: now,
            createdAt: now.subtract(const Duration(days: 3)),
            updatedAt: now.subtract(const Duration(days: 2)),
            note: 'Monthly bill',
            completedOccurrenceKeys: const ['local-state'],
          ),
          RecurringItem(
            id: 'merge-recurring',
            kind: RecurringItemKind.reminder,
            type: TransactionType.expense,
            amount: 10000,
            categoryId: 'keep-category',
            sourceId: defaultMoneySourceId,
            startDate: now,
            frequency: RecurrenceFrequency.daily,
            nextRunAt: now,
            createdAt: now.subtract(const Duration(days: 5)),
            updatedAt: now.subtract(const Duration(days: 4)),
            reminderText: 'Old local reminder',
            preNotifiedOccurrenceKeys: const ['2026-01-01'],
            dueNotifiedOccurrenceKeys: const ['2026-01-01'],
          ),
          RecurringItem(
            id: 'purge-recurring-local',
            kind: RecurringItemKind.reminder,
            type: TransactionType.expense,
            amount: 50000,
            categoryId: 'keep-category',
            sourceId: defaultMoneySourceId,
            startDate: expiredDeletedAt,
            frequency: RecurrenceFrequency.weekly,
            nextRunAt: expiredDeletedAt,
            createdAt: expiredDeletedAt,
            updatedAt: expiredDeletedAt,
            reminderText: 'Old reminder',
            isDeleted: true,
          ),
        ],
        remoteRecurringItems: [
          RecurringItem(
            id: 'keep-recurring-remote',
            kind: RecurringItemKind.reminder,
            type: TransactionType.expense,
            amount: 0,
            categoryId: 'keep-category',
            sourceId: defaultMoneySourceId,
            startDate: now,
            frequency: RecurrenceFrequency.daily,
            nextRunAt: now,
            createdAt: now.subtract(const Duration(days: 2)),
            updatedAt: now.subtract(const Duration(hours: 6)),
            reminderText: 'Daily reminder',
          ),
          RecurringItem(
            id: 'merge-recurring',
            kind: RecurringItemKind.reminder,
            type: TransactionType.expense,
            amount: 20000,
            categoryId: 'keep-category',
            sourceId: defaultMoneySourceId,
            startDate: now,
            frequency: RecurrenceFrequency.weekly,
            nextRunAt: now.add(const Duration(days: 1)),
            createdAt: now.subtract(const Duration(days: 5)),
            updatedAt: now.subtract(const Duration(hours: 1)),
            reminderText: 'New remote reminder',
          ),
          RecurringItem(
            id: 'purge-recurring-remote',
            kind: RecurringItemKind.transaction,
            type: TransactionType.income,
            amount: 300000,
            categoryId: 'keep-category',
            sourceId: defaultMoneySourceId,
            startDate: expiredDeletedAt,
            frequency: RecurrenceFrequency.monthly,
            nextRunAt: expiredDeletedAt,
            createdAt: expiredDeletedAt,
            updatedAt: expiredDeletedAt,
            note: 'Old recurring',
            isDeleted: true,
          ),
        ],
        syncStartedAt: now,
        shouldPurgeSoftDeleted: true,
      );

      expect(
        snapshot.categories.map((category) => category.id),
        contains('keep-category'),
      );
      expect(
        snapshot.categories.map((category) => category.id),
        isNot(contains('purge-category-local')),
      );
      expect(
        snapshot.categories.map((category) => category.id),
        isNot(contains('purge-category-remote')),
      );

      expect(
        snapshot.moneySources.map((source) => source.id),
        containsAll([defaultMoneySourceId, 'bank']),
      );
      expect(
        snapshot.moneySources.map((source) => source.id),
        isNot(contains('purge-source-local')),
      );
      expect(
        snapshot.moneySources.map((source) => source.id),
        isNot(contains('purge-source-remote')),
      );

      expect(
        snapshot.transactions.map((transaction) => transaction.id),
        containsAll(['keep-local', 'keep-remote', 'keep-recent-delete']),
      );
      expect(
        snapshot.transactions.map((transaction) => transaction.id),
        isNot(contains('purge-local')),
      );
      expect(
        snapshot.transactions.map((transaction) => transaction.id),
        isNot(contains('purge-remote')),
      );

      expect(
        snapshot.savingsGoals.map((goal) => goal.id),
        containsAll(['keep-goal-local', 'keep-goal-remote', 'merge-goal']),
      );
      expect(
        snapshot.savingsGoals.map((goal) => goal.id),
        isNot(contains('purge-goal-local')),
      );
      expect(
        snapshot.savingsGoals.map((goal) => goal.id),
        isNot(contains('purge-goal-remote')),
      );

      expect(
        snapshot.recurringItems.map((item) => item.id),
        containsAll(['keep-recurring-local', 'keep-recurring-remote']),
      );
      expect(
        snapshot.recurringItems.map((item) => item.id),
        isNot(contains('purge-recurring-local')),
      );
      expect(
        snapshot.recurringItems.map((item) => item.id),
        isNot(contains('purge-recurring-remote')),
      );

      final keepLocal = snapshot.transactions.firstWhere(
        (transaction) => transaction.id == 'keep-local',
      );
      expect(keepLocal.dbType, isNull);
      expect(keepLocal.note, isNull);
      expect(keepLocal.type, TransactionType.income);

      final keepCategory = snapshot.categories.firstWhere(
        (category) => category.id == 'keep-category',
      );
      expect(keepCategory.dbType, isNull);
      expect(keepCategory.type, TransactionType.income);

      final recurringJson = snapshot.recurringItems
          .firstWhere((item) => item.id == 'keep-recurring-local')
          .compactedForStorage()
          .toJson(includeNotificationState: false);
      expect(recurringJson.containsKey('completedOccurrenceKeys'), isFalse);
      expect(recurringJson.containsKey('preNotifiedOccurrenceKeys'), isFalse);
      expect(recurringJson.containsKey('dueNotifiedOccurrenceKeys'), isFalse);

      final mergedRecurring = snapshot.recurringItems.firstWhere(
        (item) => item.id == 'merge-recurring',
      );
      expect(mergedRecurring.reminderText, 'New remote reminder');
      expect(mergedRecurring.preNotifiedOccurrenceKeys, ['2026-01-01']);
      expect(mergedRecurring.dueNotifiedOccurrenceKeys, ['2026-01-01']);

      final mergedGoal = snapshot.savingsGoals.firstWhere(
        (goal) => goal.id == 'merge-goal',
      );
      expect(mergedGoal.title, 'New remote goal');
      expect(mergedGoal.savedAmount, 1500000);

      expect(snapshot.purgedSoftDeleted, isTrue);
    });
  });
}
