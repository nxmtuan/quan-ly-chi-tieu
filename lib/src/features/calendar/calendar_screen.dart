import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_range.dart';
import '../../core/utils/adaptive.dart';
import '../../core/widgets/app_bounce_builder.dart';
import '../../core/widgets/app_page_header.dart';
import '../../core/widgets/app_refresh_indicator.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/app_table_calendar.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/flat_card.dart';
import '../../core/widgets/transaction_marker_calendar.dart';
import '../../models/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../home/widgets/recent_transactions.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _selectedDay;
  late DateTime _previousSelectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _normalizeCalendarDay(DateTime.now());
    _previousSelectedDay = _selectedDay;
    _focusedDay = DateTime(_selectedDay.year, _selectedDay.month);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDayRange = dayDateRange(_selectedDay);
    final dailyTransactions = ref.watch(
      transactionsQueryProvider((
        categoryId: null,
        fromDate: selectedDayRange.start,
        limit: null,
        toDate: selectedDayRange.end,
        type: null,
      )),
    );
    final income = dailyTransactions
        .where((transaction) => transaction.type == TransactionType.income)
        .fold<double>(0, (total, transaction) => total + transaction.amount);
    final expense = dailyTransactions
        .where((transaction) => transaction.type == TransactionType.expense)
        .fold<double>(0, (total, transaction) => total + transaction.amount);

    return AppRefreshIndicator(
      child:
          ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  context.scaled(24),
                  context.scaled(22),
                  context.scaled(24),
                  context.scaled(120) + MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  const AppPageHeader(
                    subtitle: 'Lịch',
                    title: 'Thống kê giao dịch',
                  ),
                  SizedBox(height: context.scaled(22)),
                  TransactionMarkerCalendar(
                    selectedDay: _selectedDay,
                    initialFocusedDay: _focusedDay,
                    showShadow: false,
                    onDaySelected: (selectedDay) {
                      final normalizedDay = _normalizeCalendarDay(selectedDay);
                      if (DateUtils.isSameDay(normalizedDay, _selectedDay)) {
                        return;
                      }
                      setState(() {
                        _previousSelectedDay = _selectedDay;
                        _selectedDay = normalizedDay;
                        _focusedDay = DateTime(
                          normalizedDay.year,
                          normalizedDay.month,
                        );
                      });
                    },
                    onFocusedDayChanged: (focusedDay) {
                      final normalizedMonth = DateTime(
                        focusedDay.year,
                        focusedDay.month,
                      );
                      if (normalizedMonth == _focusedDay) {
                        return;
                      }
                      setState(() => _focusedDay = normalizedMonth);
                    },
                    onHeaderTapped: (_) => _pickMonth(),
                  ),
                  SizedBox(height: context.scaled(18)),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    reverseDuration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        alignment: Alignment.topCenter,
                        children: [...previousChildren, ?currentChild],
                      );
                    },
                    transitionBuilder: (child, animation) {
                      final isIncoming =
                          child.key == ValueKey<DateTime>(_selectedDay);
                      final slideDirection =
                          _selectedDay.isAfter(_previousSelectedDay)
                          ? 1.0
                          : -1.0;
                      final beginOffset = Offset(
                        isIncoming
                            ? 0.08 * slideDirection
                            : -0.04 * slideDirection,
                        0,
                      );

                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: beginOffset,
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _CalendarDayContent(
                      key: ValueKey(_selectedDay),
                      day: _selectedDay,
                      transactions: dailyTransactions,
                      income: income,
                      expense: expense,
                      headline: _calendarHeadline(_selectedDay),
                    ),
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
              ),
    );
  }

  String _calendarHeadline(DateTime day) {
    if (DateUtils.isSameDay(day, DateTime.now())) {
      return 'Hôm nay';
    }

    return 'Ngày đã chọn';
  }

  DateTime _normalizeCalendarDay(DateTime day) {
    return DateTime(day.year, day.month, day.day);
  }

  Future<void> _pickMonth() async {
    final pickedMonth = await showCalendarMonthPickerSheet(
      context,
      initialMonth: _focusedDay,
    );

    if (pickedMonth == null || !mounted) {
      return;
    }

    final nextSelectedDay = _dateInMonth(
      pickedMonth.year,
      pickedMonth.month,
      _selectedDay.day,
    );

    setState(() {
      _previousSelectedDay = _selectedDay;
      _focusedDay = DateTime(pickedMonth.year, pickedMonth.month);
      _selectedDay = nextSelectedDay;
    });
  }

  DateTime _dateInMonth(int year, int month, int preferredDay) {
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = preferredDay > lastDay ? lastDay : preferredDay;
    return DateTime(year, month, day);
  }
}

Future<DateTime?> showCalendarMonthPickerSheet(
  BuildContext context, {
  required DateTime initialMonth,
}) {
  return showAppBottomSheet<DateTime>(
    context: context,
    builder: (context) => _CalendarMonthPickerSheet(initialMonth: initialMonth),
  );
}

class _CalendarMonthPickerSheet extends StatefulWidget {
  const _CalendarMonthPickerSheet({required this.initialMonth});

  final DateTime initialMonth;

  @override
  State<_CalendarMonthPickerSheet> createState() =>
      _CalendarMonthPickerSheetState();
}

class _CalendarMonthPickerSheetState extends State<_CalendarMonthPickerSheet> {
  late int _displayedYear;
  late DateTime _selectedMonth;

  int get _firstYear => defaultCalendarFirstDay().year;
  int get _lastYear => defaultCalendarLastDay().year;

  @override
  void initState() {
    super.initState();
    _displayedYear = widget.initialMonth.year
        .clamp(_firstYear, _lastYear)
        .toInt();
    _selectedMonth = DateTime(_displayedYear, widget.initialMonth.month);
  }

  @override
  Widget build(BuildContext context) {
    return AppSheetScaffold(
      title: 'Chọn tháng',
      subtitle: 'Chọn năm, chọn tháng, rồi chọn ngày trên lịch',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: context.scaled(8)),
          _YearStepper(
            year: _displayedYear,
            canGoPrevious: _displayedYear > _firstYear,
            canGoNext: _displayedYear < _lastYear,
            onPrevious: () => _setDisplayedYear(_displayedYear - 1),
            onNext: () => _setDisplayedYear(_displayedYear + 1),
          ),
          SizedBox(height: context.scaled(18)),
          Expanded(child: _buildMonthGrid(context)),
        ],
      ),
      action: Row(
        children: [
          Expanded(
            child: AppBounceBuilder(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: context.scaled(16)),
                decoration: BoxDecoration(
                  color: context.appPalette.surfaceMuted,
                  borderRadius: BorderRadius.circular(context.scaled(16)),
                  border: Border.all(color: context.appPalette.border),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Đóng',
                  style: context.appText.buttonLabel.copyWith(
                    color: context.appPalette.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: context.scaled(12)),
          Expanded(
            child: AppPrimaryButton(
              label: 'Chọn tháng',
              color: AppColors.primary,
              radius: context.scaled(16),
              onTap: () => Navigator.of(context).pop(_selectedMonth),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthGrid(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 12,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: context.scaled(12),
        mainAxisSpacing: context.scaled(12),
        childAspectRatio: 2.55,
      ),
      itemBuilder: (context, index) {
        final month = index + 1;
        final candidate = DateTime(_displayedYear, month);
        final isSelected =
            _selectedMonth.year == _displayedYear &&
            _selectedMonth.month == month;

        return _MonthOption(
          label: 'Tháng $month',
          selected: isSelected,
          onTap: () => setState(() => _selectedMonth = candidate),
        );
      },
    );
  }

  void _setDisplayedYear(int year) {
    setState(() {
      _displayedYear = year.clamp(_firstYear, _lastYear).toInt();
      _selectedMonth = DateTime(_displayedYear, _selectedMonth.month);
    });
  }
}

class _YearStepper extends StatelessWidget {
  const _YearStepper({
    required this.year,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  final int year;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.scaled(8),
        vertical: context.scaled(8),
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(context.scaled(14)),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          _PickerIconButton(
            icon: Icons.chevron_left_rounded,
            onTap: canGoPrevious ? onPrevious : null,
          ),
          Expanded(
            child: Text(
              'Năm $year',
              textAlign: TextAlign.center,
              style: context.appText.bodyStrong.copyWith(
                fontSize: context.scaledFont(16, min: 15),
              ),
            ),
          ),
          _PickerIconButton(
            icon: Icons.chevron_right_rounded,
            onTap: canGoNext ? onNext : null,
          ),
        ],
      ),
    );
  }
}

class _PickerIconButton extends StatelessWidget {
  const _PickerIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return AppBounceBuilder(
      onTap: onTap,
      child: Container(
        width: context.scaled(38),
        height: context.scaled(38),
        decoration: BoxDecoration(
          color: context.appPalette.surfaceMuted,
          borderRadius: BorderRadius.circular(context.scaled(14)),
        ),
        child: Icon(
          icon,
          color: enabled
              ? context.appPalette.textPrimary
              : context.appPalette.textSecondary.withValues(alpha: 0.35),
          size: context.scaled(22),
        ),
      ),
    );
  }
}

class _MonthOption extends StatelessWidget {
  const _MonthOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return AppBounceBuilder(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : palette.surface,
          borderRadius: BorderRadius.circular(context.scaled(16)),
          border: Border.all(
            color: selected ? AppColors.primary : palette.border,
          ),
        ),
        child: Text(
          label,
          style: context.appText.bodyStrong.copyWith(
            color: selected ? Colors.white : palette.textPrimary,
            fontSize: context.scaledFont(12, min: 12),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _CalendarDayContent extends StatelessWidget {
  const _CalendarDayContent({
    super.key,
    required this.day,
    required this.transactions,
    required this.income,
    required this.expense,
    required this.headline,
  });

  final DateTime day;
  final List<Transaction> transactions;
  final double income;
  final double expense;
  final String headline;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FlatCard(
          radius: context.scaled(26),
          showShadow: false,
          padding: EdgeInsets.fromLTRB(
            context.scaled(18),
            context.scaled(18),
            context.scaled(18),
            context.scaled(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(headline, style: context.appText.sectionTitle),
              SizedBox(height: context.scaled(6)),
              Text(
                formatLongDate(day),
                style: context.appText.secondaryStrong.copyWith(
                  color: context.appPalette.textSecondary,
                ),
              ),
              SizedBox(height: context.scaled(16)),
              Row(
                children: [
                  Expanded(
                    child: _MetricPill(
                      label: 'Thu',
                      amount: income,
                      color: AppColors.success,
                    ),
                  ),
                  SizedBox(width: context.scaled(10)),
                  Expanded(
                    child: _MetricPill(
                      label: 'Chi',
                      amount: expense,
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: context.scaled(18)),
        if (transactions.isEmpty)
          FlatCard(
            radius: context.scaled(26),
            showShadow: false,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: context.scaled(10)),
              child: Center(
                child: Text(
                  'Ngày này chưa có giao dịch nào',
                  style: context.appText.bodyStrong.copyWith(
                    color: context.appPalette.textSecondary,
                  ),
                ),
              ),
            ),
          )
        else
          FlatCard(
            radius: context.scaled(22),
            showShadow: false,
            padding: EdgeInsets.all(context.scaled(14)),
            child: Column(
              children: [
                for (final entry in transactions.indexed) ...[
                  TransactionRow(transaction: entry.$2),
                  if (entry.$1 < transactions.length - 1)
                    Divider(
                      height: context.scaled(1),
                      color: context.appPalette.border,
                    ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.scaled(14),
        vertical: context.scaled(12),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(context.scaled(18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.appText.captionStrong.copyWith(color: color),
          ),
          SizedBox(height: context.scaled(6)),
          Text(formatCurrency(amount), style: context.appText.amountMD),
        ],
      ),
    );
  }
}
