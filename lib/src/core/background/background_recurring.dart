import 'dart:async';

import 'package:workmanager/workmanager.dart';

import '../../core/services/recurring_notification_service.dart';
import '../../core/storage/recurring_storage.dart';
import '../../core/storage/transaction_storage.dart';
import '../../models/recurring_item.dart';
import '../../models/transaction.dart';

const recurringTaskName = 'process_recurring_items';
const recurringTaskTag = 'recurring_schedule';

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
  DateTime? now,
}) async {
  final currentTime = now ?? DateTime.now();
  final items = recurringStorage.readItems();
  final updatedItems = <RecurringItem>[];
  final reminders = <RecurringItem>[];

  for (final item in items) {
    if (!item.isActive) {
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
    if (!item.isActive) {
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
}) async {
  var nextRunAt = item.nextRunAt;

  while (!nextRunAt.isAfter(now)) {
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
    await transactionStorage.putTransaction(transaction);
    await RecurringNotificationService.showTransactionCreated(item);
    nextRunAt = nextRecurringDate(nextRunAt, item.frequency);
  }

  return item.copyWith(nextRunAt: nextRunAt);
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
