part of '../recent_transactions.dart';

void showCategoryTransactionsSheet(
  BuildContext context, {
  required Category category,
}) {
  showAppBottomSheet<void>(
    context: context,
    builder: (context) {
      return _CategoryTransactionsSheet(category: category);
    },
  );
}

class _CategoryTransactionsSheet extends ConsumerStatefulWidget {
  const _CategoryTransactionsSheet({required this.category});

  final Category category;

  @override
  ConsumerState<_CategoryTransactionsSheet> createState() =>
      _CategoryTransactionsSheetState();
}

class _CategoryTransactionsSheetState
    extends ConsumerState<_CategoryTransactionsSheet> {
  late final List<DateTime> _months;
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final currentMonth = _monthStart(now);
    _months = [
      for (var index = 5; index >= 0; index--)
        DateTime(currentMonth.year, currentMonth.month - index),
    ];
    _selectedMonth = currentMonth;
  }

  @override
  Widget build(BuildContext context) {
    final chartStart = _months.first;
    final chartEnd = _monthEnd(_months.last);
    final categoryTransactions = ref.watch(
      transactionsQueryProvider((
        categoryId: widget.category.id,
        fromDate: chartStart,
        limit: null,
        toDate: chartEnd,
        type: widget.category.type,
      )),
    );

    final monthlyPoints = [
      for (final month in _months)
        _CategoryMonthlyPoint(
          month: month,
          amount: categoryTransactions
              .where((transaction) => _isSameMonth(transaction.date, month))
              .fold<double>(0, (sum, transaction) => sum + transaction.amount),
        ),
    ];
    final selectedTransactions =
        categoryTransactions
            .where(
              (transaction) => _isSameMonth(transaction.date, _selectedMonth),
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    final selectedTotal = selectedTransactions.fold<double>(
      0,
      (sum, t) => sum + t.amount,
    );

    return AppSheetScaffold(
      title: widget.category.name,
      subtitle:
          '${_monthLabel(_selectedMonth)} • ${formatCurrency(selectedTotal)}',
      bodyPadding: EdgeInsets.zero,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.scaled(16),
              context.scaled(4),
              context.scaled(16),
              context.scaled(12),
            ),
            child: _CategoryMonthlyChart(
              category: widget.category,
              points: monthlyPoints,
              selectedMonth: _selectedMonth,
              onSelected: (month) => setState(() => _selectedMonth = month),
            ),
          ),
          Expanded(
            child: selectedTransactions.isEmpty
                ? Center(
                    child: Text(
                      'Không có giao dịch nào trong ${_monthLabel(_selectedMonth).toLowerCase()}',
                      textAlign: TextAlign.center,
                      style: context.appText.bodyStrong.copyWith(
                        color: context.appPalette.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      context.scaled(16),
                      0,
                      context.scaled(16),
                      appSheetBottomPadding(context),
                    ),
                    itemCount: selectedTransactions.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: context.scaled(12)),
                    itemBuilder: (context, index) {
                      return TransactionRow(
                        transaction: selectedTransactions[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryMonthlyChart extends StatelessWidget {
  const _CategoryMonthlyChart({
    required this.category,
    required this.points,
    required this.selectedMonth,
    required this.onSelected,
  });

  final Category category;
  final List<_CategoryMonthlyPoint> points;
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final maxAmount = points.fold<double>(
      0,
      (value, point) => point.amount > value ? point.amount : value,
    );
    final chartHeight = context.scaled(198).clamp(180.0, 220.0).toDouble();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        context.scaled(14),
        context.scaled(14),
        context.scaled(14),
        context.scaled(12),
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(context.scaled(22)),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: context.scaled(40),
                height: context.scaled(40),
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(context.scaled(15)),
                ),
                child: Icon(
                  category.iconData,
                  color: category.color,
                  size: context.scaled(21),
                ),
              ),
              SizedBox(width: context.scaled(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Thống kê 6 tháng', style: context.appText.bodyStrong),
                    SizedBox(height: context.scaled(3)),
                    Text(
                      'Chọn tháng để xem danh sách chi tiết',
                      style: context.appText.caption.copyWith(
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.scaled(14)),
          SizedBox(
            height: chartHeight,
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: maxAmount == 0 ? 1 : maxAmount * 1.24,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  enabled: true,
                  handleBuiltInTouches: false,
                  touchCallback: (event, response) {
                    if (event is! FlTapUpEvent) {
                      return;
                    }

                    final groupIndex = response?.spot?.touchedBarGroupIndex;
                    if (groupIndex == null ||
                        groupIndex < 0 ||
                        groupIndex >= points.length) {
                      return;
                    }

                    onSelected(points[groupIndex].month);
                  },
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
                      reservedSize: context.scaled(34),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= points.length) {
                          return const SizedBox.shrink();
                        }

                        final point = points[index];
                        final selected = _isSameMonth(
                          point.month,
                          selectedMonth,
                        );

                        return SideTitleWidget(
                          meta: meta,
                          space: context.scaled(8),
                          child: Text(
                            'T${point.month.month}',
                            style: context.appText.captionStrong.copyWith(
                              color: selected
                                  ? category.color
                                  : palette.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (final entry in points.indexed)
                    _barGroup(
                      context,
                      index: entry.$1,
                      point: entry.$2,
                      selected: _isSameMonth(entry.$2.month, selectedMonth),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _barGroup(
    BuildContext context, {
    required int index,
    required _CategoryMonthlyPoint point,
    required bool selected,
  }) {
    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: point.amount,
          width: context.scaled(selected ? 24 : 20),
          color: selected
              ? category.color
              : category.color.withValues(
                  alpha: point.amount == 0 ? 0.16 : 0.4,
                ),
          borderRadius: BorderRadius.circular(context.scaled(9)),
          label: BarChartRodLabel(
            text: point.amount == 0 ? '' : formatCurrency(point.amount),
            style: context.appText.captionStrong.copyWith(
              color: context.appPalette.textSecondary,
              fontSize: context.scaledFont(10, min: 9),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryMonthlyPoint {
  const _CategoryMonthlyPoint({required this.month, required this.amount});

  final DateTime month;
  final double amount;
}

DateTime _monthStart(DateTime date) => DateTime(date.year, date.month);

DateTime _monthEnd(DateTime month) {
  return DateTime(
    month.year,
    month.month + 1,
  ).subtract(const Duration(milliseconds: 1));
}

bool _isSameMonth(DateTime left, DateTime right) {
  return left.year == right.year && left.month == right.month;
}

String _monthLabel(DateTime month) {
  return 'Tháng ${month.month}/${month.year}';
}
