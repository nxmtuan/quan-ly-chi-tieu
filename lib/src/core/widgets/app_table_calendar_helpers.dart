part of 'app_table_calendar.dart';

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
