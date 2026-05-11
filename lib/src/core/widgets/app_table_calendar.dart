import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/adaptive.dart';
import 'app_sheet.dart';
import 'flat_card.dart';

part 'app_table_calendar_sheet.dart';
part 'app_table_calendar_helpers.dart';

typedef CalendarEventLoader = List<Object> Function(DateTime day);

class AppTableCalendar extends StatelessWidget {
  const AppTableCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    this.onPageChanged,
    this.eventLoader,
    this.showShadow = true,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime>? onPageChanged;
  final CalendarEventLoader? eventLoader;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final markerColor = colors.primary;
    final baseCellDecoration = BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(context.scaled(16)),
    );
    final outsideCellDecoration = BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(context.scaled(16)),
    );

    return FlatCard(
      radius: context.scaled(26),
      showShadow: showShadow,
      padding: EdgeInsets.fromLTRB(
        context.scaled(16),
        context.scaled(18),
        context.scaled(16),
        context.scaled(16),
      ),
      child: TableCalendar<Object>(
        locale: 'vi_VN',
        firstDay: DateTime(2020),
        lastDay: DateTime(2035),
        focusedDay: focusedDay,
        currentDay: DateTime.now(),
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(
            Icons.chevron_left_rounded,
            color: colors.onSurface,
            size: context.scaled(26),
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right_rounded,
            color: colors.onSurface,
            size: context.scaled(26),
          ),
          titleTextStyle: TextStyle(
            color: colors.onSurface,
            fontSize: context.scaledFont(18, min: 16),
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          headerPadding: EdgeInsets.only(bottom: context.scaled(14)),
        ),
        daysOfWeekHeight: context.scaled(28),
        rowHeight: context.scaled(46),
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
            fontSize: context.scaledFont(13, min: 12),
          ),
          weekendTextStyle: TextStyle(
            color: colors.onSurface.withValues(alpha: 0.8),
            fontWeight: FontWeight.w700,
            fontSize: context.scaledFont(13, min: 12),
          ),
          outsideTextStyle: TextStyle(
            color: colors.onSurface.withValues(alpha: 0.28),
            fontWeight: FontWeight.w600,
            fontSize: context.scaledFont(13, min: 12),
          ),
          todayTextStyle: TextStyle(
            color: colors.primary,
            fontWeight: FontWeight.w700,
            fontSize: context.scaledFont(13, min: 12),
          ),
          selectedTextStyle: context.appText.bodyStrong.copyWith(
            color: Colors.white,
            fontSize: context.scaledFont(13, min: 12),
          ),
          todayDecoration: BoxDecoration(
            color: colors.primary.withValues(alpha: isDark ? 0.26 : 0.12),
            borderRadius: BorderRadius.circular(context.scaled(16)),
            border: Border.all(color: colors.primary.withValues(alpha: 0.22)),
          ),
          selectedDecoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(context.scaled(16)),
          ),
          markerDecoration: BoxDecoration(
            color: markerColor,
            borderRadius: BorderRadius.circular(999),
          ),
          markersMaxCount: 3,
          markerMargin: EdgeInsets.symmetric(horizontal: context.scaled(1.2)),
          markersAlignment: Alignment.bottomCenter,
          cellMargin: EdgeInsets.all(context.scaled(4)),
          cellPadding: EdgeInsets.zero,
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: colors.onSurface.withValues(alpha: 0.58),
            fontSize: context.scaledFont(12, min: 11),
            fontWeight: FontWeight.w800,
          ),
          weekendStyle: TextStyle(
            color: colors.onSurface.withValues(alpha: 0.42),
            fontSize: context.scaledFont(12, min: 11),
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
                padding: EdgeInsets.only(bottom: context.scaled(5)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(markerCount, (index) {
                    final opacity = 1 - (index * 0.18);
                    return Container(
                      width: context.scaled(4.5),
                      height: context.scaled(4.5),
                      margin: EdgeInsets.symmetric(
                        horizontal: context.scaled(1.3),
                      ),
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
                weekdayLabel(day.weekday),
                style: TextStyle(
                  color: isWeekend
                      ? colors.onSurface.withValues(alpha: 0.42)
                      : colors.onSurface.withValues(alpha: 0.58),
                  fontSize: context.scaledFont(12, min: 11),
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
