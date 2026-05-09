class DateRange {
  const DateRange({
    required this.start,
    required this.end,
  });

  final DateTime start;
  final DateTime end;
}

DateRange dayDateRange(DateTime date) {
  final start = DateTime(date.year, date.month, date.day);
  return DateRange(
    start: start,
    end: DateTime(date.year, date.month, date.day, 23, 59, 59, 999),
  );
}

DateRange monthDateRange(DateTime date) {
  final start = DateTime(date.year, date.month);
  final nextMonth = DateTime(date.year, date.month + 1);
  return DateRange(
    start: start,
    end: nextMonth.subtract(const Duration(milliseconds: 1)),
  );
}

DateRange yearDateRange(int year) {
  final start = DateTime(year);
  final nextYear = DateTime(year + 1);
  return DateRange(
    start: start,
    end: nextYear.subtract(const Duration(milliseconds: 1)),
  );
}

DateRange weekDateRange(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  final start = normalized.subtract(Duration(days: normalized.weekday - 1));
  final end = start.add(const Duration(days: 7)).subtract(
    const Duration(milliseconds: 1),
  );
  return DateRange(start: start, end: end);
}
