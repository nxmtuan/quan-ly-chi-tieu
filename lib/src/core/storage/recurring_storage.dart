import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/recurring_item.dart';

class RecurringStorage {
  const RecurringStorage(this._prefs);

  static const _itemsKey = 'recurring_items_v1';
  static const _nextRunAtKey = 'recurring_next_run_at_v1';

  final SharedPreferences _prefs;

  List<RecurringItem> readItems() {
    final raw = _prefs.getString(_itemsKey);
    if (raw == null || raw.isEmpty) {
      return <RecurringItem>[];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return <RecurringItem>[];
    }

    return [
      for (final item in decoded)
        if (item is Map<String, dynamic>) RecurringItem.fromJson(item),
    ];
  }

  Future<void> saveItems(List<RecurringItem> items) async {
    await _prefs.setString(
      _itemsKey,
      jsonEncode([for (final item in items) item.toJson()]),
    );
  }

  Future<void> upsertItem(RecurringItem item) async {
    final items = readItems();
    await saveItems([
      for (final existing in items)
        if (existing.id == item.id) item else existing,
      if (!items.any((existing) => existing.id == item.id)) item,
    ]);
  }

  Future<void> deleteItem(String id) async {
    await saveItems([
      for (final item in readItems())
        if (item.id != id) item,
    ]);
  }

  DateTime? readNextRunAt() {
    final raw = _prefs.getString(_nextRunAtKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> saveNextRunAt(DateTime? date) async {
    if (date == null) {
      await _prefs.remove(_nextRunAtKey);
      return;
    }
    await _prefs.setString(_nextRunAtKey, date.toIso8601String());
  }
}
