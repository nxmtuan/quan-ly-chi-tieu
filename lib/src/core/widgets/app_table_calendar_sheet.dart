part of 'app_table_calendar.dart';

Future<DateTime?> showAppCalendarSheet(
  BuildContext context, {
  required DateTime initialDate,
  CalendarEventLoader? eventLoader,
  String title = 'Chọn ngày',
  String? subtitle,
  DateTime? firstDay,
  DateTime? lastDay,
}) {
  return showAppBottomSheet<DateTime>(
    context: context,
    builder: (context) => _CalendarBottomSheet(
      initialDate: initialDate,
      eventLoader: eventLoader,
      title: title,
      subtitle: subtitle,
      firstDay: firstDay,
      lastDay: lastDay,
    ),
  );
}

class _CalendarBottomSheet extends StatefulWidget {
  const _CalendarBottomSheet({
    required this.initialDate,
    required this.title,
    this.subtitle,
    this.firstDay,
    this.lastDay,
    this.eventLoader,
  });

  final DateTime initialDate;
  final String title;
  final String? subtitle;
  final DateTime? firstDay;
  final DateTime? lastDay;
  final CalendarEventLoader? eventLoader;

  @override
  State<_CalendarBottomSheet> createState() => _CalendarBottomSheetState();
}

class _CalendarBottomSheetState extends State<_CalendarBottomSheet> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  DateTime get _firstDay =>
      _normalizeDate(widget.firstDay ?? defaultCalendarFirstDay());

  DateTime get _lastDay =>
      _normalizeDate(widget.lastDay ?? defaultCalendarLastDay());

  @override
  void initState() {
    super.initState();
    _selectedDay = _normalizeDate(widget.initialDate);
    _focusedDay = _normalizeDate(widget.initialDate);
  }

  @override
  Widget build(BuildContext context) {
    return AppSheetScaffold(
      title: widget.title,
      subtitle: widget.subtitle,
      radius: context.scaled(30),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadow.withValues(alpha: 0.12),
          blurRadius: context.scaled(16),
          offset: Offset(0, -context.scaled(6)),
        ),
      ],
      body: AppTableCalendar(
        focusedDay: _focusedDay,
        selectedDay: _selectedDay,
        eventLoader: widget.eventLoader,
        firstDay: widget.firstDay,
        lastDay: widget.lastDay,
        onDaySelected: (selectedDay) {
          setState(() => _selectedDay = _normalizeDate(selectedDay));
        },
        onPageChanged: (focusedDay) {
          setState(() => _focusedDay = _normalizeDate(focusedDay));
        },
        onHeaderTapped: (_) => _pickMonth(),
      ),
      action: Row(
        children: [
          Expanded(
            child: AppBounceBuilder(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                height: context.scaled(50),
                decoration: BoxDecoration(
                  color: context.appPalette.surfaceMuted,
                  borderRadius: BorderRadius.circular(context.scaled(17)),
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
              label: 'Áp dụng ngày này',
              color: Theme.of(context).colorScheme.primary,
              height: context.scaled(50),
              radius: context.scaled(17),
              onTap: () => Navigator.of(context).pop(_selectedDay),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickMonth() async {
    final pickedMonth = await _showCalendarSheetMonthPicker(
      context,
      initialMonth: _focusedDay,
      firstDay: _firstDay,
      lastDay: _lastDay,
    );

    if (pickedMonth == null || !mounted) {
      return;
    }

    final nextSelectedDay = _dateInMonth(
      pickedMonth.year,
      pickedMonth.month,
      _selectedDay.day,
      firstDay: _firstDay,
      lastDay: _lastDay,
    );

    setState(() {
      _focusedDay = DateTime(pickedMonth.year, pickedMonth.month);
      _selectedDay = nextSelectedDay;
    });
  }
}

Future<DateTime?> _showCalendarSheetMonthPicker(
  BuildContext context, {
  required DateTime initialMonth,
  required DateTime firstDay,
  required DateTime lastDay,
}) {
  return showAppBottomSheet<DateTime>(
    context: context,
    builder: (context) => _CalendarSheetMonthPicker(
      initialMonth: initialMonth,
      firstDay: firstDay,
      lastDay: lastDay,
    ),
  );
}

class _CalendarSheetMonthPicker extends StatefulWidget {
  const _CalendarSheetMonthPicker({
    required this.initialMonth,
    required this.firstDay,
    required this.lastDay,
  });

  final DateTime initialMonth;
  final DateTime firstDay;
  final DateTime lastDay;

  @override
  State<_CalendarSheetMonthPicker> createState() =>
      _CalendarSheetMonthPickerState();
}

class _CalendarSheetMonthPickerState extends State<_CalendarSheetMonthPicker> {
  late int _displayedYear;
  late DateTime _selectedMonth;

  int get _firstYear => widget.firstDay.year;
  int get _lastYear => widget.lastDay.year;

  @override
  void initState() {
    super.initState();
    final initialMonth = _clampMonth(
      DateTime(widget.initialMonth.year, widget.initialMonth.month),
    );
    _displayedYear = initialMonth.year;
    _selectedMonth = initialMonth;
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
          _CalendarSheetYearStepper(
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
        final isEnabled = _isSelectableMonth(candidate);
        final isSelected =
            _selectedMonth.year == _displayedYear &&
            _selectedMonth.month == month;

        return _CalendarSheetMonthOption(
          label: 'Tháng $month',
          selected: isSelected,
          enabled: isEnabled,
          onTap: () => setState(() => _selectedMonth = candidate),
        );
      },
    );
  }

  void _setDisplayedYear(int year) {
    setState(() {
      _displayedYear = year.clamp(_firstYear, _lastYear).toInt();
      final candidate = DateTime(_displayedYear, _selectedMonth.month);
      _selectedMonth = _isSelectableMonth(candidate)
          ? candidate
          : _clampMonth(candidate);
    });
  }

  bool _isSelectableMonth(DateTime month) {
    final monthStart = DateTime(month.year, month.month);
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    return !monthEnd.isBefore(widget.firstDay) &&
        !monthStart.isAfter(widget.lastDay);
  }

  DateTime _clampMonth(DateTime month) {
    final firstMonth = DateTime(widget.firstDay.year, widget.firstDay.month);
    final lastMonth = DateTime(widget.lastDay.year, widget.lastDay.month);
    if (month.isBefore(firstMonth)) {
      return firstMonth;
    }
    if (month.isAfter(lastMonth)) {
      return lastMonth;
    }
    return month;
  }
}

class _CalendarSheetYearStepper extends StatelessWidget {
  const _CalendarSheetYearStepper({
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
          _CalendarSheetPickerIconButton(
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
          _CalendarSheetPickerIconButton(
            icon: Icons.chevron_right_rounded,
            onTap: canGoNext ? onNext : null,
          ),
        ],
      ),
    );
  }
}

class _CalendarSheetPickerIconButton extends StatelessWidget {
  const _CalendarSheetPickerIconButton({
    required this.icon,
    required this.onTap,
  });

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

class _CalendarSheetMonthOption extends StatelessWidget {
  const _CalendarSheetMonthOption({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return AppBounceBuilder(
      onTap: enabled ? onTap : null,
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
            color: !enabled
                ? palette.textSecondary.withValues(alpha: 0.42)
                : selected
                ? Colors.white
                : palette.textPrimary,
            fontSize: context.scaledFont(12, min: 12),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

DateTime _dateInMonth(
  int year,
  int month,
  int preferredDay, {
  required DateTime firstDay,
  required DateTime lastDay,
}) {
  final lastDayOfMonth = DateTime(year, month + 1, 0).day;
  final day = preferredDay > lastDayOfMonth ? lastDayOfMonth : preferredDay;
  final candidate = DateTime(year, month, day);
  if (candidate.isBefore(firstDay)) {
    return firstDay;
  }
  if (candidate.isAfter(lastDay)) {
    return lastDay;
  }
  return candidate;
}
