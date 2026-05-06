import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../theme/app_colors.dart';
import 'flat_card.dart';

typedef CalendarEventLoader = List<Object> Function(DateTime day);

class AppTableCalendar extends StatelessWidget {
  const AppTableCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    this.onPageChanged,
    this.eventLoader,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime>? onPageChanged;
  final CalendarEventLoader? eventLoader;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final markerColor = colors.primary;
    final baseCellDecoration = BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
    );
    final outsideCellDecoration = BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
    );

    return FlatCard(
      radius: 28,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: TableCalendar<Object>(
        locale: 'vi_VN',
        firstDay: DateTime(2020),
        lastDay: DateTime(2035),
        focusedDay: focusedDay,
        currentDay: DateTime.now(),
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: false,
          leftChevronIcon: Icon(
            Icons.chevron_left_rounded,
            color: colors.onSurface,
            size: 28,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right_rounded,
            color: colors.onSurface,
            size: 28,
          ),
          titleTextStyle: TextStyle(
            color: colors.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
          headerPadding: const EdgeInsets.only(bottom: 14),
        ),
        daysOfWeekHeight: 28,
        rowHeight: 50,
        startingDayOfWeek: StartingDayOfWeek.monday,
        selectedDayPredicate: (day) => isSameDay(day, selectedDay),
        eventLoader: eventLoader == null ? null : (day) => eventLoader!(day),
        onDaySelected: (selectedDay, focusedDay) {
          onDaySelected(selectedDay);
          onPageChanged?.call(focusedDay);
        },
        onPageChanged: onPageChanged,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          defaultDecoration: baseCellDecoration,
          weekendDecoration: baseCellDecoration,
          outsideDecoration: outsideCellDecoration,
          defaultTextStyle: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
          weekendTextStyle: TextStyle(
            color: colors.onSurface.withValues(alpha: 0.8),
            fontWeight: FontWeight.w700,
          ),
          outsideTextStyle: TextStyle(
            color: colors.onSurface.withValues(alpha: 0.28),
            fontWeight: FontWeight.w600,
          ),
          todayTextStyle: TextStyle(
            color: colors.primary,
            fontWeight: FontWeight.w900,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
          todayDecoration: BoxDecoration(
            color: colors.primary.withValues(alpha: isDark ? 0.26 : 0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.primary.withValues(alpha: 0.22)),
          ),
          selectedDecoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: isDark ? 0.28 : 0.18),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          markerDecoration: BoxDecoration(
            color: markerColor,
            borderRadius: BorderRadius.circular(999),
          ),
          markersMaxCount: 3,
          markerMargin: const EdgeInsets.symmetric(horizontal: 1.2),
          markersAlignment: Alignment.bottomCenter,
          cellMargin: const EdgeInsets.all(4),
          cellPadding: EdgeInsets.zero,
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: colors.onSurface.withValues(alpha: 0.58),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
          weekendStyle: TextStyle(
            color: colors.onSurface.withValues(alpha: 0.42),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        calendarBuilders: CalendarBuilders<Object>(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) {
              return const SizedBox.shrink();
            }

            final markerCount = events.length > 3 ? 3 : events.length;
            return Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(markerCount, (index) {
                    final opacity = 1 - (index * 0.18);
                    return Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 1.4),
                      decoration: BoxDecoration(
                        color: markerColor.withValues(alpha: opacity),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  }),
                ),
              ),
            );
          },
          dowBuilder: (context, day) {
            final isWeekend =
                day.weekday == DateTime.saturday ||
                day.weekday == DateTime.sunday;

            return Center(
              child: Text(
                _weekdayLabel(day.weekday),
                style: TextStyle(
                  color: isWeekend
                      ? colors.onSurface.withValues(alpha: 0.42)
                      : colors.onSurface.withValues(alpha: 0.58),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

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
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            MediaQuery.of(context).padding.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outline,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            widget.subtitle!,
                            style: TextStyle(
                              color: colors.onSurface.withValues(alpha: 0.62),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
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
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(_selectedDay),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Áp dụng ngày này',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

DateTime normalizeCalendarDay(DateTime day) => _normalizeDate(day);

DateTime _normalizeDate(DateTime day) {
  return DateTime(day.year, day.month, day.day);
}

String _weekdayLabel(int weekday) {
  return switch (weekday) {
    DateTime.monday => 'T2',
    DateTime.tuesday => 'T3',
    DateTime.wednesday => 'T4',
    DateTime.thursday => 'T5',
    DateTime.friday => 'T6',
    DateTime.saturday => 'T7',
    _ => 'CN',
  };
}
