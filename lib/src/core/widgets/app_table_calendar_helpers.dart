part of 'app_table_calendar.dart';

Map<DateTime, List<T>> buildCalendarEventIndex<T>(
  Iterable<T> items,
  DateTime Function(T item) dateOf,
) {
  final eventsByDay = <DateTime, List<T>>{};

  for (final item in items) {
    final day = normalizeCalendarDay(dateOf(item));
    (eventsByDay[day] ??= <T>[]).add(item);
  }

  return eventsByDay;
}

DateTime normalizeCalendarDay(DateTime day) => _normalizeDate(day);

DateTime _normalizeDate(DateTime day) {
  return DateTime(day.year, day.month, day.day);
}

String weekdayLabel(int weekday) {
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
