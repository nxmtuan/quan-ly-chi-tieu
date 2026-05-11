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

  for (final item in items) {
    if (!item.isActive) {
      updatedItems.add(item);
      continue;
    }

    final updated = item.kind == RecurringItemKind.transaction
        ? await _processRecurringTransaction(
            item,
            now: currentTime,
            transactionStorage: transactionStorage,
          )
        : await _processRecurringReminder(item, now: currentTime);
    updatedItems.add(updated);
  }

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

Future<RecurringItem> _processRecurringReminder(
  RecurringItem item, {
  required DateTime now,
}) async {
  var current = item;
  final occurrenceKey = recurringOccurrenceKey(current.nextRunAt);
  final preNotifyAt = current.nextRunAt.subtract(const Duration(days: 1));
  final completed = current.completedOccurrenceKeys.contains(occurrenceKey);

  if (!completed &&
      !current.preNotifiedOccurrenceKeys.contains(occurrenceKey) &&
      !preNotifyAt.isAfter(now)) {
    await RecurringNotificationService.showReminderUpcoming(current);
    current = current.copyWith(
      preNotifiedOccurrenceKeys: [
        ...current.preNotifiedOccurrenceKeys,
        occurrenceKey,
      ],
    );
  }

  if (!completed &&
      !current.dueNotifiedOccurrenceKeys.contains(occurrenceKey) &&
      !current.nextRunAt.isAfter(now)) {
    await RecurringNotificationService.showReminderDue(current);
    current = current.copyWith(
      dueNotifiedOccurrenceKeys: [
        ...current.dueNotifiedOccurrenceKeys,
        occurrenceKey,
      ],
    );
  }

  while (current.completedOccurrenceKeys.contains(
    recurringOccurrenceKey(current.nextRunAt),
  )) {
    current = current.copyWith(
      nextRunAt: nextRecurringDate(current.nextRunAt, current.frequency),
    );
  }

  return current;
}

DateTime? _nextReminderProcessingTime(RecurringItem item, DateTime now) {
  final key = recurringOccurrenceKey(item.nextRunAt);
  final completed = item.completedOccurrenceKeys.contains(key);
  if (completed) {
    return item.nextRunAt;
  }

  final preNotifyAt = item.nextRunAt.subtract(const Duration(days: 1));
  if (!item.preNotifiedOccurrenceKeys.contains(key)) {
    return preNotifyAt;
  }

  if (!item.dueNotifiedOccurrenceKeys.contains(key)) {
    return item.nextRunAt;
  }

  return nextRecurringDate(item.nextRunAt, item.frequency);
}
