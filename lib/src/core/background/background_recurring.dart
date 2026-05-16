import 'dart:async';

import 'package:workmanager/workmanager.dart';

import '../../core/services/budget_notification_service.dart';
import '../../core/services/recurring_notification_service.dart';
import '../../core/storage/budget_storage.dart';
import '../../core/storage/category_storage.dart';
import '../../core/storage/recurring_storage.dart';
import '../../core/storage/transaction_storage.dart';
import '../../core/utils/date_range.dart';
import '../../models/recurring_item.dart';
import '../../models/transaction.dart';
import '../../providers/category_provider.dart';

const recurringTaskName = 'process_recurring_items';
const recurringTaskTag = 'recurring_schedule';
const _maxCatchUpOccurrencesPerRun = 60;

Future<void> configureRecurringBackgroundProcessingFromStorage(
  RecurringStorage storage, {
  DateTime? now,
}) async {
  await Workmanager().cancelByTag(recurringTaskTag);

  final scheduledFrom = now ?? DateTime.now();
  final nextRun = resolveNextRecurringProcessingTime(
    items: storage.readItems(),
    now: scheduledFrom,
  );
  await storage.saveNextRunAt(nextRun);

  if (nextRun == null) {
    return;
  }

  final delay = nextRun.difference(scheduledFrom);
  await Workmanager().registerOneOffTask(
    '${recurringTaskName}_${nextRun.millisecondsSinceEpoch}',
    recurringTaskName,
    initialDelay: delay.isNegative ? Duration.zero : delay,
    backoffPolicy: BackoffPolicy.linear,
    backoffPolicyDelay: const Duration(minutes: 15),
    existingWorkPolicy: ExistingWorkPolicy.replace,
    tag: recurringTaskTag,
  );
}

Future<bool> processRecurringItems({
  required RecurringStorage recurringStorage,
  required TransactionStorage transactionStorage,
  BudgetStorage? budgetStorage,
  CategoryStorage? categoryStorage,
  DateTime? now,
}) async {
  final currentTime = now ?? DateTime.now();
  final items = recurringStorage.readItems();
  final updatedItems = <RecurringItem>[];
  final reminders = <RecurringItem>[];

  for (final item in items) {
    if (!item.isActive || item.isDeleted) {
      updatedItems.add(item);
      continue;
    }

    if (item.kind == RecurringItemKind.reminder) {
      reminders.add(item);
      continue;
    }

    updatedItems.add(
      await _processRecurringTransaction(
        item,
        now: currentTime,
        transactionStorage: transactionStorage,
        budgetStorage: budgetStorage,
        categoryStorage: categoryStorage,
      ),
    );
  }

  updatedItems.addAll(
    await _processRecurringReminders(reminders, now: currentTime),
  );

  await recurringStorage.saveItems(updatedItems);
  await configureRecurringBackgroundProcessingFromStorage(
    recurringStorage,
    now: currentTime,
  );
  return true;
}

DateTime? resolveNextRecurringProcessingTime({
  required List<RecurringItem> items,
  required DateTime now,
}) {
  DateTime? nextRun;

  for (final item in items) {
    if (!item.isActive || item.isDeleted) {
      continue;
    }

    final candidate = item.kind == RecurringItemKind.transaction
        ? item.nextRunAt
        : _nextReminderProcessingTime(item, now);
    if (candidate == null) {
      continue;
    }

    if (nextRun == null || candidate.isBefore(nextRun)) {
      nextRun = candidate;
    }
  }

  if (nextRun != null && !nextRun.isAfter(now)) {
    return now.add(const Duration(minutes: 1));
  }
  return nextRun;
}

Future<RecurringItem> _processRecurringTransaction(
  RecurringItem item, {
  required DateTime now,
  required TransactionStorage transactionStorage,
  BudgetStorage? budgetStorage,
  CategoryStorage? categoryStorage,
}) async {
  var nextRunAt = item.nextRunAt;
  var createdCount = 0;

  while (!nextRunAt.isAfter(now) &&
      createdCount < _maxCatchUpOccurrencesPerRun) {
    final key = recurringOccurrenceKey(nextRunAt);
    final transaction = Transaction(
      id: 'rec-${item.id}-$key',
      amount: item.amount,
      type: item.type,
      categoryId: item.categoryId,
      sourceId: item.sourceId,
      date: nextRunAt,
      note: item.note,
    );
    await _notifyBudgetIfRecurringTransactionCrossesLimit(
      transaction,
      transactionStorage: transactionStorage,
      budgetStorage: budgetStorage,
      categoryStorage: categoryStorage,
    );
    await transactionStorage.putTransaction(transaction);
    nextRunAt = nextRecurringDate(nextRunAt, item.frequency);
    createdCount++;
  }

  if (createdCount > 0) {
    await RecurringNotificationService.showTransactionsCreated(
      item: item,
      count: createdCount,
    );
  }

  return item.copyWith(
    nextRunAt: nextRunAt,
    updatedAt: nextRunAt == item.nextRunAt ? item.updatedAt : now,
  );
}

Future<void> _notifyBudgetIfRecurringTransactionCrossesLimit(
  Transaction transaction, {
  required TransactionStorage transactionStorage,
  BudgetStorage? budgetStorage,
  CategoryStorage? categoryStorage,
}) async {
  if (transaction.type != TransactionType.expense || budgetStorage == null) {
    return;
  }

  final month = DateTime(transaction.date.year, transaction.date.month);
  final range = monthDateRange(month);
  final monthlyTransactions = transactionStorage.readTransactions(
    categoryId: transaction.categoryId,
    fromDate: range.start,
    toDate: range.end,
    type: TransactionType.expense,
  );

  if (monthlyTransactions.any((item) => item.id == transaction.id)) {
    return;
  }

  final beforeSpent = monthlyTransactions.fold<double>(
    0,
    (total, item) => total + item.amount,
  );
  final afterSpent = beforeSpent + transaction.amount;
  final budgets = budgetStorage.readBudgets().where(
    (budget) =>
        budget.categoryId == transaction.categoryId &&
        budget.periodStart == month,
  );

  for (final budget in budgets) {
    if (beforeSpent < budget.warningThresholdAmount &&
        afterSpent >= budget.warningThresholdAmount) {
      await BudgetNotificationService.showBudgetWarning(
        budgetId: budget.id,
        categoryName: _categoryName(transaction.categoryId, categoryStorage),
        spentAmount: afterSpent,
        warningAmount: budget.warningThresholdAmount,
        limitAmount: budget.limitAmount,
      );
    }
    if (beforeSpent <= budget.limitAmount && afterSpent > budget.limitAmount) {
      await BudgetNotificationService.showBudgetExceeded(
        budgetId: budget.id,
        categoryName: _categoryName(transaction.categoryId, categoryStorage),
        spentAmount: afterSpent,
        limitAmount: budget.limitAmount,
      );
    }
  }
}

String _categoryName(String categoryId, CategoryStorage? categoryStorage) {
  final storedCategories = categoryStorage?.readCategories() ?? const [];
  for (final category in [...storedCategories, ...defaultCategories]) {
    if (category.id == categoryId) {
      return category.name;
    }
  }
  return 'Danh mục';
}

Future<List<RecurringItem>> _processRecurringReminders(
  List<RecurringItem> items, {
  required DateTime now,
}) async {
  final updatedItems = <RecurringItem>[];
  final upcomingGroups = <DateTime, List<RecurringItem>>{};
  final dueGroups = <DateTime, List<RecurringItem>>{};
  final today = _dateOnly(now);

  for (final item in items) {
    var current = item;
    var guard = 0;

    while (guard < 120) {
      guard++;
      final occurrenceDate = _dateOnly(current.nextRunAt);
      final occurrenceKey = recurringOccurrenceKey(current.nextRunAt);
      final upcomingNotifyAt = _reminderUpcomingNotifyAt(occurrenceDate);
      final dueNotifyAt = _reminderDueNotifyAt(occurrenceDate);
      final preNotified = current.preNotifiedOccurrenceKeys.contains(
        occurrenceKey,
      );
      final dueNotified = current.dueNotifiedOccurrenceKeys.contains(
        occurrenceKey,
      );

      if (occurrenceDate.isBefore(today) || dueNotified) {
        current = current.copyWith(
          nextRunAt: nextRecurringDate(current.nextRunAt, current.frequency),
          updatedAt: now,
        );
        continue;
      }

      if (_isSameDate(occurrenceDate, today)) {
        if (!dueNotifyAt.isAfter(now)) {
          dueGroups.putIfAbsent(occurrenceDate, () => []).add(current);
          current = current.copyWith(
            dueNotifiedOccurrenceKeys: [
              ...current.dueNotifiedOccurrenceKeys,
              occurrenceKey,
            ],
            nextRunAt: nextRecurringDate(current.nextRunAt, current.frequency),
            updatedAt: now,
          );
          continue;
        }
        break;
      }

      if (!preNotified &&
          !upcomingNotifyAt.isAfter(now) &&
          now.isBefore(dueNotifyAt)) {
        upcomingGroups.putIfAbsent(occurrenceDate, () => []).add(current);
        current = current.copyWith(
          preNotifiedOccurrenceKeys: [
            ...current.preNotifiedOccurrenceKeys,
            occurrenceKey,
          ],
        );
      }
      break;
    }

    updatedItems.add(current);
  }

  for (final entry in _sortedReminderGroups(upcomingGroups)) {
    await RecurringNotificationService.showReminderUpcomingGroup(
      date: entry.key,
      items: entry.value,
    );
  }
  for (final entry in _sortedReminderGroups(dueGroups)) {
    await RecurringNotificationService.showReminderDueGroup(
      date: entry.key,
      items: entry.value,
    );
  }

  return updatedItems;
}

DateTime? _nextReminderProcessingTime(RecurringItem item, DateTime now) {
  var current = item;
  final today = _dateOnly(now);
  var guard = 0;

  while (guard < 120) {
    guard++;
    final occurrenceDate = _dateOnly(current.nextRunAt);
    final occurrenceKey = recurringOccurrenceKey(current.nextRunAt);
    final upcomingNotifyAt = _reminderUpcomingNotifyAt(occurrenceDate);
    final dueNotifyAt = _reminderDueNotifyAt(occurrenceDate);

    if (occurrenceDate.isBefore(today) ||
        current.dueNotifiedOccurrenceKeys.contains(occurrenceKey)) {
      current = current.copyWith(
        nextRunAt: nextRecurringDate(current.nextRunAt, current.frequency),
      );
      continue;
    }

    if (!current.preNotifiedOccurrenceKeys.contains(occurrenceKey)) {
      return upcomingNotifyAt;
    }

    if (!current.dueNotifiedOccurrenceKeys.contains(occurrenceKey)) {
      return dueNotifyAt;
    }
  }

  return null;
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

DateTime _reminderUpcomingNotifyAt(DateTime occurrenceDate) {
  return DateTime(
    occurrenceDate.year,
    occurrenceDate.month,
    occurrenceDate.day - 1,
    21,
  );
}

DateTime _reminderDueNotifyAt(DateTime occurrenceDate) {
  return DateTime(
    occurrenceDate.year,
    occurrenceDate.month,
    occurrenceDate.day,
    7,
  );
}

List<MapEntry<DateTime, List<RecurringItem>>> _sortedReminderGroups(
  Map<DateTime, List<RecurringItem>> groups,
) {
  return groups.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
}
