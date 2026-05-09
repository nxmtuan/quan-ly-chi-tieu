import '../../../core/utils/date_range.dart';
import '../../../core/utils/formatters.dart';

enum HomeSummaryScopeType { month, year, all }

class HomeSummaryScope {
  const HomeSummaryScope._({
    required this.type,
    required this.anchor,
  });

  final HomeSummaryScopeType type;
  final DateTime? anchor;

  factory HomeSummaryScope.month(DateTime date) {
    return HomeSummaryScope._(
      type: HomeSummaryScopeType.month,
      anchor: DateTime(date.year, date.month),
    );
  }

  factory HomeSummaryScope.year(int year) {
    return HomeSummaryScope._(
      type: HomeSummaryScopeType.year,
      anchor: DateTime(year),
    );
  }

  factory HomeSummaryScope.all() {
    return const HomeSummaryScope._(
      type: HomeSummaryScopeType.all,
      anchor: null,
    );
  }

  bool matches(DateTime date) {
    return switch (type) {
      HomeSummaryScopeType.month =>
        date.year == anchor!.year && date.month == anchor!.month,
      HomeSummaryScopeType.year => date.year == anchor!.year,
      HomeSummaryScopeType.all => true,
    };
  }

  bool canGoNext(DateTime now) {
    return switch (type) {
      HomeSummaryScopeType.month =>
        _monthStart(anchor!).isBefore(_monthStart(now)),
      HomeSummaryScopeType.year => anchor!.year < now.year,
      HomeSummaryScopeType.all => false,
    };
  }

  bool get canGoPrevious => type != HomeSummaryScopeType.all;

  HomeSummaryScope previous() {
    return switch (type) {
      HomeSummaryScopeType.month =>
        HomeSummaryScope.month(DateTime(anchor!.year, anchor!.month - 1)),
      HomeSummaryScopeType.year => HomeSummaryScope.year(anchor!.year - 1),
      HomeSummaryScopeType.all => this,
    };
  }

  HomeSummaryScope next() {
    return switch (type) {
      HomeSummaryScopeType.month =>
        HomeSummaryScope.month(DateTime(anchor!.year, anchor!.month + 1)),
      HomeSummaryScopeType.year => HomeSummaryScope.year(anchor!.year + 1),
      HomeSummaryScopeType.all => this,
    };
  }

  String get label {
    return switch (type) {
      HomeSummaryScopeType.month => formatMonthYear(anchor!),
      HomeSummaryScopeType.year => 'Năm ${anchor!.year}',
      HomeSummaryScopeType.all => 'Tất cả',
    };
  }

  DateRange? get dateRange {
    return switch (type) {
      HomeSummaryScopeType.month => monthDateRange(anchor!),
      HomeSummaryScopeType.year => yearDateRange(anchor!.year),
      HomeSummaryScopeType.all => null,
    };
  }
}

DateTime _monthStart(DateTime date) {
  return DateTime(date.year, date.month);
}
