import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/adaptive.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/flat_card.dart';
import '../../core/widgets/app_bounce_builder.dart';
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
          padding: EdgeInsets.fromLTRB(
            context.scaled(24),
            context.scaled(16),
            context.scaled(24),
            context.scaled(120) + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            Text(
              'Statistics',
              style: context.appText.pageTitle.copyWith(
                fontSize: context.scaledFont(27, min: 24),
              ),
            ),
            SizedBox(height: context.scaled(8)),
            Text(
              'Track where your money goes',
              style: context.appText.pageSubtitle.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: context.scaled(22)),
            _RangeSelector(
              selectedRange: _selectedRange,
              onChanged: (range) => setState(() => _selectedRange = range),
            ),
            SizedBox(height: context.scaled(22)),
            _ExpenseOverviewCard(
              totalExpense: totalExpense,
              breakdown: breakdown,
            ),
            SizedBox(height: context.scaled(24)),
            Text(
              'Breakdown',
              style: context.appText.sectionTitle,
            ),
            SizedBox(height: context.scaled(16)),
            if (breakdown.isEmpty)
              const FlatCard(
                child: Center(child: Text('No breakdown available')),
              )
            else
              for (final item in breakdown)
                Padding(
                  padding: EdgeInsets.only(bottom: context.scaled(12)),
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
