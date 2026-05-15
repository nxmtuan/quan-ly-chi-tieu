import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/adaptive.dart';
import '../../core/utils/date_range.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_bounce_builder.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/app_toast.dart';
import '../../models/budget.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../providers/budget_provider.dart';
import '../../providers/transaction_provider.dart';
import 'budget_sheet.dart';

void showBudgetDetailSheet(
  BuildContext context, {
  required Budget budget,
  required Category? category,
  required double spentAmount,
}) {
  showAppBottomSheet<void>(
    context: context,
    builder: (context) {
      return _BudgetDetailSheet(
        budget: budget,
        category: category,
        spentAmount: spentAmount,
      );
    },
  );
}

class _BudgetDetailSheet extends ConsumerStatefulWidget {
  const _BudgetDetailSheet({
    required this.budget,
    required this.category,
    required this.spentAmount,
  });

  final Budget budget;
  final Category? category;
  final double spentAmount;

  @override
  ConsumerState<_BudgetDetailSheet> createState() => _BudgetDetailSheetState();
}

class _BudgetDetailSheetState extends ConsumerState<_BudgetDetailSheet> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.budget.periodStart;
  }

  @override
  Widget build(BuildContext context) {
    final budget = widget.budget;
    final selectedRange = monthDateRange(_selectedMonth);
    final monthTransactions = ref.watch(
      transactionsQueryProvider((
        categoryId: budget.categoryId,
        fromDate: selectedRange.start,
        limit: null,
        toDate: selectedRange.end,
        type: TransactionType.expense,
      )),
    );
    final spentAmount = monthTransactions.fold<double>(
      0,
      (total, transaction) => total + transaction.amount,
    );
    final chartPeriods = _lastSixMonths(budget.periodStart);
    final chartTransactions = ref.watch(
      transactionsQueryProvider((
        categoryId: budget.categoryId,
        fromDate: chartPeriods.first.start,
        limit: null,
        toDate: chartPeriods.last.end,
        type: TransactionType.expense,
      )),
    );
    final chartData = [
      for (final period in chartPeriods)
        _ChartBarData(
          label: period.label,
          month: period.start,
          amount: _sumTransactionsInRange(chartTransactions, period),
          selected: _isSameMonth(period.start, _selectedMonth),
        ),
    ];
    final status = _BudgetDetailStatus.fromBudget(budget, spentAmount);

    return AppSheetScaffold(
      title: 'Chi tiết ngân sách',
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: context.scaled(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BudgetOverviewSection(
              chart: _SpendingChartSection(
                category: widget.category,
                data: chartData,
                budgetLimit: budget.limitAmount,
                onMonthSelected: (month) {
                  setState(() => _selectedMonth = month);
                },
              ),
              info: _BudgetInfoSection(
                budget: budget,
                category: widget.category,
                spentAmount: spentAmount,
                selectedMonth: _selectedMonth,
                status: status,
              ),
            ),
            SizedBox(height: context.scaled(40)),
            _BudgetTransactionsSection(
              transactions: monthTransactions,
              category: widget.category,
              month: _selectedMonth,
            ),
          ],
        ),
      ),
      action: Row(
        children: [
          Expanded(
            child: AppBounceBuilder(
              onTap: () => _confirmDelete(context, ref),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: context.scaled(16)),
                decoration: BoxDecoration(
                  color: context.appPalette.dangerSoft,
                  borderRadius: BorderRadius.circular(context.scaled(16)),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Xóa',
                  style: context.appText.buttonLabel.copyWith(
                    color: const Color(0xFFDC2626),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: context.scaled(12)),
          Expanded(
            child: AppBounceBuilder(
              onTap: () {
                Navigator.of(context).pop();
                showBudgetSheet(context, budget: budget, replaceSheet: true);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: context.scaled(16)),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(context.scaled(16)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: context.scaled(8),
                      offset: Offset(0, context.scaled(4)),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text('Chỉnh sửa', style: context.appText.buttonLabel),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Xóa ngân sách',
      message: 'Ngân sách này sẽ bị xóa khỏi tháng đã chọn.',
      confirmText: 'Xóa',
      confirmTextColor: const Color(0xFFDC2626),
      confirmBackgroundColor: context.appPalette.dangerSoft,
    );

    if (confirmed == true && context.mounted) {
      await ref.read(budgetsProvider.notifier).deleteBudget(widget.budget.id);
      if (!context.mounted) {
        return;
      }
      AppToast.show(
        context,
        message: 'Đã xóa ngân sách',
        type: AppToastType.success,
      );
      Navigator.of(context).pop();
    }
  }
}

class _SpendingChartSection extends StatelessWidget {
  const _SpendingChartSection({
    required this.category,
    required this.data,
    required this.budgetLimit,
    required this.onMonthSelected,
  });

  final Category? category;
  final List<_ChartBarData> data;
  final double budgetLimit;
  final ValueChanged<DateTime> onMonthSelected;

  @override
  Widget build(BuildContext context) {
    final categoryColor = category?.color ?? AppColors.primary;

    return SizedBox(
      height: context.scaled(190),
      child: _BudgetBarChart(
        data: data,
        color: categoryColor,
        budgetLimit: budgetLimit,
        onSelected: onMonthSelected,
      ),
    );
  }
}

class _BudgetOverviewSection extends StatelessWidget {
  const _BudgetOverviewSection({required this.chart, required this.info});

  final Widget chart;
  final Widget info;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      padding: EdgeInsets.all(context.scaled(10)),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(context.scaled(10)),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Lịch sử chi tiêu', style: context.appText.bodyStrong),
          SizedBox(height: context.scaled(10)),
          chart,
          SizedBox(height: context.scaled(8)),
          info,
        ],
      ),
    );
  }
}

class _BudgetBarChart extends StatelessWidget {
  const _BudgetBarChart({
    required this.data,
    required this.color,
    required this.budgetLimit,
    required this.onSelected,
  });

  final List<_ChartBarData> data;
  final Color color;
  final double budgetLimit;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final maxAmount = data.fold<double>(
      0,
      (current, item) => math.max(current, item.amount),
    );
    final chartMaxAmount = math.max(maxAmount, budgetLimit);
    final maxY = chartMaxAmount <= 0 ? 1.0 : chartMaxAmount * 1.16;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 680),
      curve: Curves.easeOutCubic,
      builder: (context, animationValue, child) {
        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            minY: 0,
            gridData: const FlGridData(show: false),
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: budgetLimit,
                  color: AppColors.primary.withValues(alpha: 0.55),
                  strokeWidth: context.scaled(1.2),
                  dashArray: const [7, 6],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(bottom: context.scaled(4)),
                    labelResolver: (_) =>
                        formatCurrency(budgetLimit).replaceAll(' ₫', ''),
                    style: context.appText.captionStrong.copyWith(
                      color: AppColors.primary,
                      fontSize: context.scaledFont(10, min: 9),
                    ),
                  ),
                ),
              ],
            ),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              touchCallback: (event, response) {
                if (!event.isInterestedForInteractions || response == null) {
                  return;
                }

                final groupIndex = response.spot?.touchedBarGroupIndex;
                if (groupIndex == null ||
                    groupIndex < 0 ||
                    groupIndex >= data.length) {
                  return;
                }

                onSelected(data[groupIndex].month);
              },
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => palette.textPrimary,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    formatCurrency(data[group.x].amount),
                    context.appText.captionStrong.copyWith(color: Colors.white),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: context.scaled(36),
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= data.length) {
                      return const SizedBox.shrink();
                    }

                    return SideTitleWidget(
                      meta: meta,
                      space: context.scaled(8),
                      child: Text(
                        data[index].label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.appText.caption.copyWith(
                          color: palette.textSecondary,
                          fontSize: context.scaledFont(10, min: 9),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              for (var index = 0; index < data.length; index++)
                BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: data[index].amount * animationValue,
                      width: context.scaled(54),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(context.scaled(6)),
                      ),
                      color: data[index].selected
                          ? color
                          : data[index].amount > 0
                          ? color.withValues(alpha: 0.42)
                          : palette.surfaceMuted,
                    ),
                  ],
                ),
            ],
          ),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      },
    );
  }
}

class _BudgetInfoSection extends StatelessWidget {
  const _BudgetInfoSection({
    required this.budget,
    required this.category,
    required this.spentAmount,
    required this.selectedMonth,
    required this.status,
  });

  final Budget budget;
  final Category? category;
  final double spentAmount;
  final DateTime selectedMonth;
  final _BudgetDetailStatus status;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final progress = budget.progressWith(spentAmount);
    final usagePercent = budget.usagePercentWith(spentAmount);
    final categoryColor = category?.color ?? AppColors.primary;

    return Container(
      padding: EdgeInsets.all(context.scaled(4)),
      color: palette.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: context.scaled(48),
                height: context.scaled(48),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(context.scaled(17)),
                ),
                child: Icon(
                  category?.iconData ?? Icons.category_rounded,
                  color: categoryColor,
                  size: context.scaled(22),
                ),
              ),
              SizedBox(width: context.scaled(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category?.name ?? 'Danh mục đã xóa',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.appText.fieldValue,
                    ),
                    SizedBox(height: context.scaled(6)),
                    Text(
                      status.label,
                      style: context.appText.captionStrong.copyWith(
                        color: status.color,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${usagePercent.round()}%',
                style: context.appText.bodyStrong.copyWith(color: status.color),
              ),
            ],
          ),
          SizedBox(height: context.scaled(14)),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: context.scaled(9),
              backgroundColor: palette.surfaceMuted,
              valueColor: AlwaysStoppedAnimation(status.color),
            ),
          ),
          SizedBox(height: context.scaled(14)),
          Row(
            children: [
              Expanded(
                child: _BudgetMetric(
                  label: 'Đã dùng',
                  value: formatCurrency(spentAmount),
                  valueColor: status.color,
                ),
              ),
              SizedBox(width: context.scaled(8)),
              Expanded(
                child: _BudgetMetric(
                  label: 'Còn lại',
                  value: formatCurrency(
                    budget.remainingAmountWith(spentAmount),
                  ),
                  alignCenter: true,
                ),
              ),
              SizedBox(width: context.scaled(8)),
              Expanded(
                child: _BudgetMetric(
                  label: 'Tối đa',
                  value: formatCurrency(budget.limitAmount),
                  alignEnd: true,
                ),
              ),
            ],
          ),
          SizedBox(height: context.scaled(12)),
          _MonthChip(month: selectedMonth),
        ],
      ),
    );
  }
}

class _BudgetMetric extends StatelessWidget {
  const _BudgetMetric({
    required this.label,
    required this.value,
    this.valueColor,
    this.alignCenter = false,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool alignCenter;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final alignment = alignEnd
        ? CrossAxisAlignment.end
        : alignCenter
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: context.appText.caption.copyWith(
            color: context.appPalette.textSecondary,
          ),
        ),
        SizedBox(height: context.scaled(4)),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd
              ? TextAlign.end
              : alignCenter
              ? TextAlign.center
              : TextAlign.start,
          style: context.appText.captionStrong.copyWith(
            color: valueColor ?? context.appPalette.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _MonthChip extends StatelessWidget {
  const _MonthChip({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.scaled(8),
        vertical: context.scaled(5),
      ),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_month_rounded,
            color: palette.textSecondary,
            size: context.scaled(13),
          ),
          SizedBox(width: context.scaled(4)),
          Text(
            formatMonthYear(month),
            style: context.appText.captionStrong.copyWith(
              color: palette.textSecondary,
              fontSize: context.scaledFont(11, min: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetTransactionsSection extends StatelessWidget {
  const _BudgetTransactionsSection({
    required this.transactions,
    required this.category,
    required this.month,
  });

  final List<Transaction> transactions;
  final Category? category;
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.scaled(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chi tiêu ${formatMonthYear(month)}',
            style: context.appText.bodyStrong,
          ),
          SizedBox(height: context.scaled(10)),
          if (transactions.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.scaled(16)),
              child: Center(
                child: Text(
                  'Chưa có giao dịch trong tháng này',
                  style: context.appText.caption.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ),
            )
          else
            for (var index = 0; index < transactions.length; index++) ...[
              _BudgetTransactionRow(
                transaction: transactions[index],
                category: category,
              ),
              if (index < transactions.length - 1)
                Divider(color: palette.border, height: context.scaled(1)),
            ],
        ],
      ),
    );
  }
}

class _BudgetTransactionRow extends StatelessWidget {
  const _BudgetTransactionRow({
    required this.transaction,
    required this.category,
  });

  final Transaction transaction;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    final color = category?.color ?? AppColors.danger;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.scaled(11)),
      child: Row(
        children: [
          Container(
            width: context.scaled(42),
            height: context.scaled(42),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(context.scaled(15)),
            ),
            child: Icon(
              category?.iconData ?? Icons.receipt_long_rounded,
              color: color,
              size: context.scaled(20),
            ),
          ),
          SizedBox(width: context.scaled(11)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.hasNote
                      ? transaction.note!
                      : category?.name ?? 'Chi tiêu',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.appText.bodyStrong,
                ),
                SizedBox(height: context.scaled(4)),
                Text(
                  formatShortDate(transaction.date),
                  style: context.appText.caption.copyWith(
                    color: context.appPalette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.scaled(10)),
          Text(
            '-${formatCurrency(transaction.amount)}',
            textAlign: TextAlign.right,
            style: context.appText.bodyStrong.copyWith(color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}

class _BudgetDetailStatus {
  const _BudgetDetailStatus({required this.label, required this.color});

  final String label;
  final Color color;

  factory _BudgetDetailStatus.fromBudget(Budget budget, double spentAmount) {
    if (budget.isExceededWith(spentAmount)) {
      return const _BudgetDetailStatus(
        label: 'Đã vượt ngân sách',
        color: AppColors.danger,
      );
    }

    if (budget.isNearLimitWith(spentAmount)) {
      return const _BudgetDetailStatus(
        label: 'Gần vượt ngân sách',
        color: AppColors.warning,
      );
    }

    return const _BudgetDetailStatus(
      label: 'Trong hạn mức',
      color: AppColors.primary,
    );
  }
}

class _ChartPeriod {
  const _ChartPeriod({
    required this.label,
    required this.start,
    required this.end,
  });

  final String label;
  final DateTime start;
  final DateTime end;
}

class _ChartBarData {
  const _ChartBarData({
    required this.label,
    required this.month,
    required this.amount,
    required this.selected,
  });

  final String label;
  final DateTime month;
  final double amount;
  final bool selected;
}

List<_ChartPeriod> _lastSixMonths(DateTime anchorMonth) {
  final periods = [
    for (var offset = 0; offset < 6; offset++)
      _monthChartPeriod(DateTime(anchorMonth.year, anchorMonth.month - offset)),
  ];
  return periods.reversed.toList();
}

String _monthLabel(DateTime month) {
  final now = DateTime.now();
  if (month.year == now.year) {
    return 'T${month.month}';
  }

  return 'T${month.month}/${month.year}';
}

_ChartPeriod _monthChartPeriod(DateTime month) {
  final range = monthDateRange(month);
  return _ChartPeriod(
    label: _monthLabel(month),
    start: range.start,
    end: range.end,
  );
}

bool _isSameMonth(DateTime left, DateTime right) {
  return left.year == right.year && left.month == right.month;
}

double _sumTransactionsInRange(
  List<Transaction> transactions,
  _ChartPeriod period,
) {
  return transactions
      .where(
        (transaction) =>
            !transaction.date.isBefore(period.start) &&
            !transaction.date.isAfter(period.end),
      )
      .fold<double>(0, (total, transaction) => total + transaction.amount);
}
