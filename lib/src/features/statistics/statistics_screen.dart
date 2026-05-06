import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/flat_card.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';

part 'widgets/statistics_range_selector.dart';
part 'widgets/statistics_overview.dart';
part 'widgets/statistics_breakdown.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  var _selectedRange = 'Month';

  @override
  Widget build(BuildContext context) {
    final breakdown = _buildBreakdown(
      ref.watch(transactionsProvider),
      ref.watch(categoriesProvider),
    );
    final totalExpense = breakdown.fold<double>(
      0,
      (total, item) => total + item.amount,
    );

    return ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
          children: [
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.7,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Track where your money goes',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 22),
            _RangeSelector(
              selectedRange: _selectedRange,
              onChanged: (range) => setState(() => _selectedRange = range),
            ),
            const SizedBox(height: 22),
            _ExpenseOverviewCard(
              totalExpense: totalExpense,
              breakdown: breakdown,
            ),
            const SizedBox(height: 24),
            Text(
              'Breakdown',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            if (breakdown.isEmpty)
              const FlatCard(
                child: Center(child: Text('No breakdown available')),
              )
            else
              for (final item in breakdown)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _BreakdownRow(item: item),
                ),
          ],
        )
        .animate()
        .fadeIn(duration: 260.ms)
        .slideY(
          begin: 0.04,
          end: 0,
          duration: 340.ms,
          curve: Curves.easeOutCubic,
        );
  }

  List<_BreakdownItem> _buildBreakdown(
    List<Transaction> transactions,
    List<Category> categories,
  ) {
    final totalsByCategory = <String, double>{};

    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        totalsByCategory.update(
          transaction.categoryId,
          (amount) => amount + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

    final total = totalsByCategory.values.fold<double>(
      0,
      (sum, amount) => sum + amount,
    );

    if (total == 0) {
      return const [];
    }

    final items = <_BreakdownItem>[];

    for (final entry in totalsByCategory.entries) {
      final category = categories
          .where((category) => category.id == entry.key)
          .firstOrNull;
      if (category != null) {
        items.add(
          _BreakdownItem(
            category: category,
            amount: entry.value,
            percentage: entry.value / total * 100,
          ),
        );
      }
    }

    items.sort((a, b) => b.amount.compareTo(a.amount));
    return items;
  }
}
