import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_chi_tieu/src/core/background/background_recurring.dart';
import 'package:quan_ly_chi_tieu/src/models/recurring_item.dart';

void main() {
  group('resolveFirstProcessableRecurringTransactionDate', () {
    test('keeps yesterday daily occurrence for catch-up', () {
      final result = resolveFirstProcessableRecurringTransactionDate(
        nextRunAt: DateTime(2026, 5, 12, 22),
        frequency: RecurrenceFrequency.daily,
        now: DateTime(2026, 5, 13, 9),
      );

      expect(result, DateTime(2026, 5, 12, 22));
    });

    test('skips daily occurrences older than yesterday', () {
      final result = resolveFirstProcessableRecurringTransactionDate(
        nextRunAt: DateTime(2026, 5, 12, 22),
        frequency: RecurrenceFrequency.daily,
        now: DateTime(2026, 5, 14, 23),
      );

      expect(result, DateTime(2026, 5, 13, 22));
    });

    test(
      'keeps latest yesterday daily occurrence after skipping old dates',
      () {
        final result = resolveFirstProcessableRecurringTransactionDate(
          nextRunAt: DateTime(2026, 5, 12, 22),
          frequency: RecurrenceFrequency.daily,
          now: DateTime(2026, 5, 15, 23),
        );

        expect(result, DateTime(2026, 5, 14, 22));
      },
    );

    test(
      'keeps today daily occurrence when it is the first processable date',
      () {
        final result = resolveFirstProcessableRecurringTransactionDate(
          nextRunAt: DateTime(2026, 5, 15, 22),
          frequency: RecurrenceFrequency.daily,
          now: DateTime(2026, 5, 15, 23),
        );

        expect(result, DateTime(2026, 5, 15, 22));
      },
    );

    test('skips old weekly occurrence to the next weekly date', () {
      final result = resolveFirstProcessableRecurringTransactionDate(
        nextRunAt: DateTime(2026, 5, 12, 22),
        frequency: RecurrenceFrequency.weekly,
        now: DateTime(2026, 5, 14, 9),
      );

      expect(result, DateTime(2026, 5, 19, 22));
    });

    test('skips old monthly occurrence to the next monthly date', () {
      final result = resolveFirstProcessableRecurringTransactionDate(
        nextRunAt: DateTime(2026, 5, 12, 22),
        frequency: RecurrenceFrequency.monthly,
        now: DateTime(2026, 5, 14, 9),
      );

      expect(result, DateTime(2026, 6, 12, 22));
    });
  });
}
