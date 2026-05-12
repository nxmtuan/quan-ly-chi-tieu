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
}
