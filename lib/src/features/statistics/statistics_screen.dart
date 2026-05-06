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
                fontWeight: FontWeight.w900,
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
            FlatCard(
              radius: 30,
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Expense Overview',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        formatCurrency(totalExpense),
                        style: const TextStyle(
                          color: AppColors.coral,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 220,
                    child: totalExpense == 0
                        ? const Center(
                            child: Text(
                              'No expense data yet',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 58,
                              startDegreeOffset: -90,
                              sections: [
                                for (final item in breakdown)
                                  PieChartSectionData(
                                    value: item.amount,
                                    color: item.category.color,
                                    radius: 38,
                                    title:
                                        '${item.percentage.toStringAsFixed(0)}%',
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Breakdown',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
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

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.selectedRange, required this.onChanged});

  final String selectedRange;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const ranges = ['Week', 'Month', 'Year'];

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          for (final range in ranges)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(range),
                borderRadius: BorderRadius.circular(18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: selectedRange == range
                        ? AppColors.lavender
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    range,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selectedRange == range
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.item});

  final _BreakdownItem item;

  @override
  Widget build(BuildContext context) {
    return FlatCard(
      radius: 24,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.category.color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(item.category.iconData, color: item.category.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: item.percentage / 100,
                    minHeight: 7,
                    backgroundColor: AppColors.background,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      item.category.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.percentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                formatCurrency(item.amount),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BreakdownItem {
  const _BreakdownItem({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  final Category category;
  final double amount;
  final double percentage;
}
