import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/adaptive.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/flat_card.dart';
import '../../../core/widgets/app_bounce_builder.dart';
import '../../../models/category.dart';
import '../../../models/transaction.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../models/home_summary_scope.dart';
import '../../transactions/add_transaction_sheet.dart';

part 'recent/category_chart.dart';
part 'recent/category_breakdown.dart';
part 'recent/transaction_row.dart';
part 'recent/category_transactions_sheet.dart';

class RecentTransactions extends ConsumerStatefulWidget {
  const RecentTransactions({
    super.key,
    required this.scope,
    required this.transactions,
    required this.selectedType,
  });

  final HomeSummaryScope scope;
  final List<Transaction> transactions;
  final TransactionType selectedType;

  @override
  ConsumerState<RecentTransactions> createState() => _RecentTransactionsState();
}

class _RecentTransactionsState extends ConsumerState<RecentTransactions> {
  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final items = _buildCategoryItems(categories);
    final total = items.fold<double>(0, (sum, item) => sum + item.amount);
    final chartHeight = context.scaled(350);
    final chartLift = context.scaled(6);
    final chartGap = context.scaled(16);

    return Padding(
      padding: EdgeInsets.only(top: chartLift),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.only(top: chartHeight + chartGap - chartLift),
            child: FlatCard(
              radius: context.scaled(22),
              padding: EdgeInsets.all(context.scaled(14)),
              showShadow: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (items.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(context.scaled(20)),
                      child: Center(
                        child: Text(
                          widget.selectedType == TransactionType.expense
                              ? 'Chưa có khoản chi nào'
                              : 'Chưa có khoản thu nào',
                          style: context.appText.bodyStrong.copyWith(
                            color: context.appPalette.textSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    for (final entry in items.indexed) ...[
                      _CategoryAmountRow(
                            item: entry.$2,
                            total: total,
                            scope: widget.scope,
                            transactions: widget.transactions,
                            showDivider: false,
                          )
                          .animate(delay: Duration(milliseconds: 38 * entry.$1))
                          .fadeIn(duration: 240.ms)
                          .slideX(
                            begin: 0.04,
                            end: 0,
                            duration: 280.ms,
                            curve: Curves.easeOutCubic,
                          ),
                      if (entry.$1 < items.length - 1)
                        Divider(
                          height: context.scaled(1),
                          color: context.appPalette.border,
                        ),
                    ],
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, -chartLift),
            child: SizedBox(
              height: chartHeight,
              child: total == 0
                  ? const FlatCard(
                      showShadow: false,
                      child: Center(child: Text('Chưa có dữ liệu')),
                    )
                  : _CategoryDonutChart(items: items, total: total),
            ),
          ),
        ],
      ),
    );
  }

  List<_CategoryAmountItem> _buildCategoryItems(List<Category> categories) {
    final totals = <String, double>{};

    for (final transaction in widget.transactions) {
      if (transaction.type != widget.selectedType) {
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
              type: widget.selectedType,
            ),
          ),
          amount: entry.value,
          color: AppColors.textSecondary,
        ),
    ]..sort((a, b) => b.amount.compareTo(a.amount));

    return [
      for (final item in items)
        _CategoryAmountItem(
          category: item.category,
          amount: item.amount,
          color: item.category.color,
        ),
    ];
  }
}
