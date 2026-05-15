import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_chi_tieu/src/models/budget.dart';

void main() {
  group('Budget', () {
    test('normalizes period to month start and clamps warning percent', () {
      final budget = Budget(
        id: 'budget-food',
        categoryId: 'food',
        limitAmount: 1000000,
        periodStart: DateTime(2026, 5, 15),
        warningPercent: 120,
      );

      expect(budget.periodStart, DateTime(2026, 5));
      expect(budget.warningPercent, 100);
      expect(
        budget.periodEnd,
        DateTime(2026, 6).subtract(const Duration(milliseconds: 1)),
      );
    });

    test('calculates progress, remaining and status thresholds', () {
      final budget = Budget(
        id: 'budget-food',
        categoryId: 'food',
        limitAmount: 1000000,
        periodStart: DateTime(2026, 5),
        warningPercent: 80,
      );

      expect(budget.progressWith(500000), 0.5);
      expect(budget.usagePercentWith(500000), 50);
      expect(budget.remainingAmountWith(500000), 500000);
      expect(budget.isNearLimitWith(800000), isTrue);
      expect(budget.isExceededWith(1000001), isTrue);
      expect(budget.progressWith(1500000), 1);
      expect(budget.remainingAmountWith(1500000), 0);
    });
  });
}
