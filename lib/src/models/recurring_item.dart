import 'transaction.dart';

enum RecurringItemKind { transaction, reminder }

enum RecurrenceFrequency { daily, weekly, monthly }

extension RecurrenceFrequencyLabel on RecurrenceFrequency {
  String get label {
    return switch (this) {
      RecurrenceFrequency.daily => 'Mỗi ngày',
      RecurrenceFrequency.weekly => 'Mỗi tuần',
      RecurrenceFrequency.monthly => 'Mỗi tháng',
    };
  }
}

class RecurringItem {
  const RecurringItem({
    required this.id,
    required this.kind,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.sourceId,
    required this.startDate,
    required this.frequency,
    required this.nextRunAt,
    required this.createdAt,
    this.note,
    this.reminderText,
    this.isActive = true,
    this.completedOccurrenceKeys = const [],
    this.preNotifiedOccurrenceKeys = const [],
    this.dueNotifiedOccurrenceKeys = const [],
  });

  final String id;
  final RecurringItemKind kind;
  final TransactionType type;
  final double amount;
  final String categoryId;
  final String sourceId;
  final DateTime startDate;
  final RecurrenceFrequency frequency;
  final DateTime nextRunAt;
  final DateTime createdAt;
  final String? note;
  final String? reminderText;
  final bool isActive;
  final List<String> completedOccurrenceKeys;
  final List<String> preNotifiedOccurrenceKeys;
  final List<String> dueNotifiedOccurrenceKeys;

  String get title {
    final text = kind == RecurringItemKind.reminder ? reminderText : note;
    if (text != null && text.trim().isNotEmpty) {
      return text.trim();
    }
    return kind == RecurringItemKind.transaction
        ? 'Giao dịch định kỳ'
        : 'Nhắc nhở định kỳ';
  }

  RecurringItem copyWith({
    String? id,
    RecurringItemKind? kind,
    TransactionType? type,
    double? amount,
    String? categoryId,
    String? sourceId,
    DateTime? startDate,
    RecurrenceFrequency? frequency,
    DateTime? nextRunAt,
    DateTime? createdAt,
    String? note,
    String? reminderText,
    bool? isActive,
    List<String>? completedOccurrenceKeys,
    List<String>? preNotifiedOccurrenceKeys,
    List<String>? dueNotifiedOccurrenceKeys,
  }) {
    return RecurringItem(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      sourceId: sourceId ?? this.sourceId,
      startDate: startDate ?? this.startDate,
      frequency: frequency ?? this.frequency,
      nextRunAt: nextRunAt ?? this.nextRunAt,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      reminderText: reminderText ?? this.reminderText,
      isActive: isActive ?? this.isActive,
      completedOccurrenceKeys:
          completedOccurrenceKeys ?? this.completedOccurrenceKeys,
      preNotifiedOccurrenceKeys:
          preNotifiedOccurrenceKeys ?? this.preNotifiedOccurrenceKeys,
      dueNotifiedOccurrenceKeys:
          dueNotifiedOccurrenceKeys ?? this.dueNotifiedOccurrenceKeys,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kind': kind.name,
      'type': type.name,
      'amount': amount,
      'categoryId': categoryId,
      'sourceId': sourceId,
      'startDate': startDate.toIso8601String(),
      'frequency': frequency.name,
      'nextRunAt': nextRunAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'note': note,
      'reminderText': reminderText,
      'isActive': isActive,
      'completedOccurrenceKeys': completedOccurrenceKeys,
      'preNotifiedOccurrenceKeys': preNotifiedOccurrenceKeys,
      'dueNotifiedOccurrenceKeys': dueNotifiedOccurrenceKeys,
    };
  }

  factory RecurringItem.fromJson(Map<String, dynamic> json) {
    return RecurringItem(
      id: json['id'] as String,
      kind: RecurringItemKind.values.byName(json['kind'] as String),
      type: TransactionType.values.byName(json['type'] as String),
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      sourceId: json['sourceId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      frequency: RecurrenceFrequency.values.byName(json['frequency'] as String),
      nextRunAt: DateTime.parse(json['nextRunAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      note: json['note'] as String?,
      reminderText: json['reminderText'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      completedOccurrenceKeys: _stringList(json['completedOccurrenceKeys']),
      preNotifiedOccurrenceKeys: _stringList(json['preNotifiedOccurrenceKeys']),
      dueNotifiedOccurrenceKeys: _stringList(json['dueNotifiedOccurrenceKeys']),
    );
  }
}

List<String> _stringList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return [
    for (final item in value)
      if (item is String) item,
  ];
}

DateTime nextRecurringDate(DateTime from, RecurrenceFrequency frequency) {
  return switch (frequency) {
    RecurrenceFrequency.daily => from.add(const Duration(days: 1)),
    RecurrenceFrequency.weekly => from.add(const Duration(days: 7)),
    RecurrenceFrequency.monthly => _sameDayNextMonth(from),
  };
}

DateTime normalizeRecurringDate(DateTime date) {
  return DateTime(date.year, date.month, date.day, date.hour, date.minute);
}

String recurringOccurrenceKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

DateTime _sameDayNextMonth(DateTime from) {
  final nextMonth = DateTime(from.year, from.month + 1);
  final lastDay = DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
  final day = from.day > lastDay ? lastDay : from.day;
  return DateTime(nextMonth.year, nextMonth.month, day, from.hour, from.minute);
}
