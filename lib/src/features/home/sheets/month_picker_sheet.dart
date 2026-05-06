part of '../widgets/summary_card.dart';

Future<DateTime?> showMonthPickerSheet(
  BuildContext context, {
  required DateTime initialMonth,
  required DateTime lastMonth,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
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

    return AppSheetContainer(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            MediaQuery.of(context).padding.bottom + 14,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppSheetHeader(
                title: 'Chọn tháng',
                subtitle: 'Chỉ chọn theo tháng, không chọn ngày.',
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  InkWell(
                    onTap: () => setState(() => _displayedYear -= 1),
                    borderRadius: BorderRadius.circular(999),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.chevron_left_rounded, size: 28),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '$_displayedYear',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: canGoNextYear
                        ? () => setState(() => _displayedYear += 1)
                        : null,
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 28,
                        color: canGoNextYear
                            ? AppColors.textPrimary
                            : AppColors.textSecondary.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 12,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.2,
                ),
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final candidateMonth = DateTime(_displayedYear, month);
                  final isSelected =
                      _selectedMonth.year == _displayedYear &&
                      _selectedMonth.month == month;
                  final isDisabled = candidateMonth.isAfter(widget.lastMonth);

                  return InkWell(
                    onTap: isDisabled
                        ? null
                        : () => setState(() => _selectedMonth = candidateMonth),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : isDisabled
                            ? const Color(0xFFF8FAFC)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
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
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isDisabled
                              ? AppColors.textSecondary.withValues(alpha: 0.4)
                              : AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              AppPrimaryButton(
                label: 'Chọn tháng',
                color: AppColors.primary,
                onTap: () => Navigator.of(context).pop(_selectedMonth),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
