part of 'app_table_calendar.dart';

Future<DateTime?> showAppCalendarSheet(
  BuildContext context, {
  required DateTime initialDate,
  CalendarEventLoader? eventLoader,
  String title = 'Chọn ngày',
  String? subtitle,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _CalendarBottomSheet(
        initialDate: initialDate,
        eventLoader: eventLoader,
        title: title,
        subtitle: subtitle,
      );
    },
  );
}

class _CalendarBottomSheet extends StatefulWidget {
  const _CalendarBottomSheet({
    required this.initialDate,
    required this.title,
    this.subtitle,
    this.eventLoader,
  });

  final DateTime initialDate;
  final String title;
  final String? subtitle;
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
    return AppSheetContainer(
      radius: 32,
      boxShadow: [
        BoxShadow(
          color: AppColors.shadow.withValues(alpha: 0.12),
          blurRadius: 18,
          offset: const Offset(0, -6),
        ),
      ],
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            appSheetBottomPadding(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSheetHeader(title: widget.title, subtitle: widget.subtitle),
              const SizedBox(height: 8),
              AppTableCalendar(
                focusedDay: _focusedDay,
                selectedDay: _selectedDay,
                eventLoader: widget.eventLoader,
                onDaySelected: (selectedDay) {
                  setState(() => _selectedDay = _normalizeDate(selectedDay));
                },
                onPageChanged: (focusedDay) {
                  setState(() => _focusedDay = _normalizeDate(focusedDay));
                },
              ),
              const SizedBox(height: 14),
              AppPrimaryButton(
                label: 'Áp dụng ngày này',
                color: Theme.of(context).colorScheme.primary,
                height: 52,
                radius: 18,
                onTap: () => Navigator.of(context).pop(_selectedDay),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
