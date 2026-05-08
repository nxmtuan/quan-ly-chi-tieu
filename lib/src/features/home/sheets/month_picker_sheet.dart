part of '../widgets/summary_card.dart';

Future<DateTime?> showMonthPickerSheet(
  BuildContext context, {
  required DateTime initialMonth,
  required DateTime lastMonth,
}) {
  return showAppBottomSheet<DateTime>(
    context: context,
    builder: (context) {
      return _MonthPickerSheet(
        initialMonth: initialMonth,
        lastMonth: lastMonth,
      );
    },
  );
}

class _MonthPickerSheet extends StatefulWidget {
  const _MonthPickerSheet({
    required this.initialMonth,
    required this.lastMonth,
  });

  final DateTime initialMonth;
  final DateTime lastMonth;

  @override
  State<_MonthPickerSheet> createState() => _MonthPickerSheetState();
}

class _MonthPickerSheetState extends State<_MonthPickerSheet> {
  late int _displayedYear;
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(
      widget.initialMonth.year,
      widget.initialMonth.month,
    );
    _displayedYear = _selectedMonth.year;
  }

  @override
  Widget build(BuildContext context) {
    final canGoNextYear = _displayedYear < widget.lastMonth.year;

    return AppSheetScaffold(
      title: 'Chọn tháng',
      body: Column(
        children: [
          SizedBox(height: context.scaled(8)),
          // Year navigation
          Row(
            children: [
              AppBounceBuilder(
                onTap: () => setState(() => _displayedYear -= 1),
                child: Padding(
                  padding: EdgeInsets.all(context.scaled(8)),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: context.scaled(26),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '$_displayedYear',
                  textAlign: TextAlign.center,
                  style: context.appText.sectionTitle.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: context.scaledFont(18, min: 16),
                  ),
                ),
              ),
              AppBounceBuilder(
                onTap: canGoNextYear
                    ? () => setState(() => _displayedYear += 1)
                    : null,
                child: Padding(
                  padding: EdgeInsets.all(context.scaled(8)),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: context.scaled(26),
                    color: canGoNextYear
                        ? AppColors.textPrimary
                        : AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.scaled(16)),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 12,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: context.scaled(10),
              mainAxisSpacing: context.scaled(10),
              childAspectRatio: 2.2,
            ),
            itemBuilder: (context, index) {
              final month = index + 1;
              final candidateMonth = DateTime(_displayedYear, month);
              final isSelected =
                  _selectedMonth.year == _displayedYear &&
                  _selectedMonth.month == month;
              final isDisabled = candidateMonth.isAfter(widget.lastMonth);

              return AppBounceBuilder(
                onTap: isDisabled
                    ? null
                    : () =>
                        setState(() => _selectedMonth = candidateMonth),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isDisabled
                        ? const Color(0xFFF8FAFC)
                        : Colors.white,
                    borderRadius:
                        BorderRadius.circular(context.scaled(16)),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : isDisabled
                          ? AppColors.border.withValues(alpha: 0.6)
                          : AppColors.border,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Tháng $month',
                    style: context.appText.bodyStrong.copyWith(
                      color: isSelected
                          ? Colors.white
                          : isDisabled
                          ? AppColors.textSecondary.withValues(alpha: 0.4)
                          : AppColors.textPrimary,
                      fontSize: context.scaledFont(12, min: 12),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      action: AppPrimaryButton(
        label: 'Chọn tháng',
        color: AppColors.primary,
        onTap: () => Navigator.of(context).pop(_selectedMonth),
      ),
    );
  }
}
