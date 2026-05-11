import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/background/background_recurring.dart';
import '../models/recurring_item.dart';
import 'storage_provider.dart';

class RecurringItemsNotifier extends Notifier<List<RecurringItem>> {
  @override
  List<RecurringItem> build() {
    return _sorted(ref.read(recurringStorageProvider).readItems());
  }

  Future<void> addItem(RecurringItem item) async {
    state = [...state, item]
      ..sort((a, b) => a.nextRunAt.compareTo(b.nextRunAt));
    await ref.read(recurringStorageProvider).upsertItem(item);
    await configureRecurringBackgroundProcessingFromStorage(
      ref.read(recurringStorageProvider),
    );
  }

  Future<void> updateItem(RecurringItem item) async {
    state = [
      for (final existing in state)
        if (existing.id == item.id) item else existing,
    ]..sort((a, b) => a.nextRunAt.compareTo(b.nextRunAt));
    await ref.read(recurringStorageProvider).upsertItem(item);
    await configureRecurringBackgroundProcessingFromStorage(
      ref.read(recurringStorageProvider),
    );
  }

  Future<void> deleteItem(String id) async {
    state = [
      for (final item in state)
        if (item.id != id) item,
    ];
    await ref.read(recurringStorageProvider).deleteItem(id);
    await configureRecurringBackgroundProcessingFromStorage(
      ref.read(recurringStorageProvider),
    );
  }

  void reload() {
    state = _sorted(ref.read(recurringStorageProvider).readItems());
  }

  List<RecurringItem> _sorted(List<RecurringItem> items) {
    return [...items]..sort((a, b) => a.nextRunAt.compareTo(b.nextRunAt));
  }
}

final recurringItemsProvider =
    NotifierProvider<RecurringItemsNotifier, List<RecurringItem>>(
      RecurringItemsNotifier.new,
    );

final recurringTransactionsProvider = Provider<List<RecurringItem>>((ref) {
  return ref
      .watch(recurringItemsProvider)
      .where((item) => item.kind == RecurringItemKind.transaction)
      .toList();
});

final recurringRemindersProvider = Provider<List<RecurringItem>>((ref) {
  return ref
      .watch(recurringItemsProvider)
      .where((item) => item.kind == RecurringItemKind.reminder)
      .toList();
});
