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
        MonthlyBarChartPoint(
          label: 'T${month.month}',
          month: month,
          amount: categoryTransactions
              .where((transaction) => _isSameMonth(transaction.date, month))
              .fold<double>(0, (sum, transaction) => sum + transaction.amount),
          selected: _isSameMonth(month, _selectedMonth),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          context.scaled(16),
          context.scaled(4),
          context.scaled(16),
          context.scaled(24),
        ),
        child: Column(
          children: [
            _CategoryMonthlyChart(
              category: widget.category,
              points: monthlyPoints,
              onSelected: (month) => setState(() => _selectedMonth = month),
            ),
            SizedBox(height: context.scaled(20)),
            if (selectedTransactions.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: context.scaled(32)),
                child: Text(
                  'Không có giao dịch nào trong ${_monthLabel(_selectedMonth).toLowerCase()}',
                  textAlign: TextAlign.center,
                  style: context.appText.bodyStrong.copyWith(
                    color: context.appPalette.textSecondary,
                  ),
                ),
              )
            else
              Column(
                children: [
                  for (
                    var index = 0;
                    index < selectedTransactions.length;
                    index++
                  ) ...[
                    TransactionRow(transaction: selectedTransactions[index]),
                    if (index != selectedTransactions.length - 1)
                      SizedBox(height: context.scaled(12)),
                  ],
                ],
              ),
          ],
        ),
      ),
      action: AppPrimaryButton(
        label: 'Đóng',
        color: AppColors.primary,
        onTap: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _CategoryMonthlyChart extends StatelessWidget {
  const _CategoryMonthlyChart({
    required this.category,
    required this.points,
    required this.onSelected,
  });

  final Category category;
  final List<MonthlyBarChartPoint> points;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
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
            child: MonthlyBarChart(
              points: points,
              color: category.color,
              showAmountLabels: true,
              onSelected: onSelected,
            ),
          ),
        ],
      ),
    );
  }
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
