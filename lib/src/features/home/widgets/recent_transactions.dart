import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/flat_card.dart';
import '../../../models/category.dart';
import '../../../models/transaction.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../transactions/add_transaction_sheet.dart';

part 'recent/category_chart.dart';
part 'recent/category_breakdown.dart';
part 'recent/transaction_row.dart';

const _modernChartPalette = [
  Color(0xFFE91E63),
  Color(0xFF8E24AA),
  Color(0xFFFF7043),
  Color(0xFF00A6A6),
  Color(0xFF42A5F5),
  Color(0xFFFFC107),
  Color(0xFF7E57C2),
  Color(0xFF66BB6A),
];

class RecentTransactions extends ConsumerStatefulWidget {
  const RecentTransactions({super.key, required this.transactions});

  final List<Transaction> transactions;

  @override
  ConsumerState<RecentTransactions> createState() => _RecentTransactionsState();
}

class _RecentTransactionsState extends ConsumerState<RecentTransactions> {
  TransactionType _selectedType = TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final items = _buildCategoryItems(categories);
    final total = items.fold<double>(0, (sum, item) => sum + item.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 340,
          child: total == 0
              ? const FlatCard(child: Center(child: Text('Chưa có dữ liệu')))
              : _CategoryDonutChart(items: items, total: total),
        ),
        const SizedBox(height: 18),
        FlatCard(
          padding: EdgeInsets.zero,
          radius: 24,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _CategoryTabs(
                  selectedType: _selectedType,
                  onSelected: (type) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                ),
              ),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _selectedType == TransactionType.expense
                        ? 'Chưa có khoản chi nào'
                        : 'Chưa có khoản thu nào',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                for (final entry in items.indexed)
                  _CategoryAmountRow(
                        item: entry.$2,
                        total: total,
                        showDivider: entry.$1 != items.length - 1,
                      )
                      .animate(delay: Duration(milliseconds: 38 * entry.$1))
                      .fadeIn(duration: 240.ms)
                      .slideX(
                        begin: 0.04,
                        end: 0,
                        duration: 280.ms,
                        curve: Curves.easeOutCubic,
                      ),
            ],
          ),
        ),
      ],
    );
  }

  List<_CategoryAmountItem> _buildCategoryItems(List<Category> categories) {
    final totals = <String, double>{};

    for (final transaction in widget.transactions) {
      if (transaction.type != _selectedType) {
        continue;
      }

      totals.update(
        transaction.categoryId,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    final items = [
      for (final entry in totals.entries)
        _CategoryAmountItem(
          category: categories.firstWhere(
            (category) => category.id == entry.key,
            orElse: () => Category(
              id: entry.key,
              name: 'Khác',
              iconData: Icons.category_rounded,
              colorHex: AppColors.textSecondary.toARGB32(),
              type: _selectedType,
            ),
          ),
          amount: entry.value,
          color: AppColors.textSecondary,
        ),
    ]..sort((a, b) => b.amount.compareTo(a.amount));

    return [
      for (final entry in items.indexed)
        _CategoryAmountItem(
          category: entry.$2.category,
          amount: entry.$2.amount,
          color: _modernChartPalette[entry.$1 % _modernChartPalette.length],
        ),
    ];
  }
}
