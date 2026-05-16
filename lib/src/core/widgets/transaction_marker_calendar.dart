import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/transaction_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/adaptive.dart';
import '../utils/date_range.dart';
import 'app_bounce_builder.dart';
import 'app_sheet.dart';
import 'app_table_calendar.dart';

class TransactionMarkerCalendar extends ConsumerStatefulWidget {
  const TransactionMarkerCalendar({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
    this.initialFocusedDay,
    this.onFocusedDayChanged,
    this.onHeaderTapped,
    this.showShadow = true,
  });

  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  final DateTime? initialFocusedDay;
  final ValueChanged<DateTime>? onFocusedDayChanged;
  final ValueChanged<DateTime>? onHeaderTapped;
  final bool showShadow;

  @override
  ConsumerState<TransactionMarkerCalendar> createState() =>
      _TransactionMarkerCalendarState();
}

class _TransactionMarkerCalendarState
    extends ConsumerState<TransactionMarkerCalendar> {
  late DateTime _focusedDay;
  late List<DateTime> _loadedMarkerBlockHeads;

  @override
  void initState() {
    super.initState();
    _resetCache(widget.initialFocusedDay ?? widget.selectedDay);
  }

  @override
  void didUpdateWidget(covariant TransactionMarkerCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    final previousFocus = oldWidget.initialFocusedDay ?? oldWidget.selectedDay;
    final nextFocus = widget.initialFocusedDay ?? widget.selectedDay;
    if (!_isSameMonth(previousFocus, nextFocus)) {
      _resetCache(nextFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final markerMaps = [
      for (final blockHead in _loadedMarkerBlockHeads)
        ref.watch(
          transactionEventsByDayProvider((
            fromDate: _markerBlockRange(blockHead).start,
            toDate: _markerBlockRange(blockHead).end,
          )),
        ),
    ];
    final eventsByDay = _mergeEventsByDay(markerMaps);

    return AppTableCalendar(
      focusedDay: _focusedDay,
      selectedDay: normalizeCalendarDay(widget.selectedDay),
      eventLoader: (day) => eventsByDay[normalizeCalendarDay(day)] ?? const [],
      onDaySelected: (selectedDay) {
        widget.onDaySelected(normalizeCalendarDay(selectedDay));
      },
      onPageChanged: (focusedDay) {
        final normalized = normalizeCalendarDay(focusedDay);
        setState(() {
          _focusedDay = normalized;
          _updateMarkerBlockCache(normalized);
        });
        widget.onFocusedDayChanged?.call(normalized);
      },
      onHeaderTapped: widget.onHeaderTapped,
      showShadow: widget.showShadow,
    );
  }

  void _resetCache(DateTime focusedDay) {
    _focusedDay = normalizeCalendarDay(focusedDay);
    _loadedMarkerBlockHeads = [_monthStart(_focusedDay)];
  }

  DateTime _monthStart(DateTime day) => DateTime(day.year, day.month);

  DateTime _oldestMonthInBlock(DateTime blockHead) {
    return DateTime(blockHead.year, blockHead.month - 1);
  }

  DateRange _markerBlockRange(DateTime blockHead) {
    final start = _oldestMonthInBlock(blockHead);
    final nextMonth = DateTime(blockHead.year, blockHead.month + 1);
    return DateRange(
      start: start,
      end: nextMonth.subtract(const Duration(milliseconds: 1)),
    );
  }

  void _updateMarkerBlockCache(DateTime focusedDay) {
    final focusedMonth = _monthStart(focusedDay);
    final oldestBlockHead = _loadedMarkerBlockHeads.last;
    final newestBlockHead = _loadedMarkerBlockHeads.first;

    if (focusedMonth == _oldestMonthInBlock(oldestBlockHead)) {
      _loadedMarkerBlockHeads = [
        ..._loadedMarkerBlockHeads,
        DateTime(oldestBlockHead.year, oldestBlockHead.month - 2),
      ];
      if (_loadedMarkerBlockHeads.length > 2) {
        _loadedMarkerBlockHeads = _loadedMarkerBlockHeads.sublist(1);
      }
      return;
    }

    if (focusedMonth == newestBlockHead) {
      _loadedMarkerBlockHeads = [
        DateTime(newestBlockHead.year, newestBlockHead.month + 2),
        ..._loadedMarkerBlockHeads,
      ];
      if (_loadedMarkerBlockHeads.length > 2) {
        _loadedMarkerBlockHeads = _loadedMarkerBlockHeads.sublist(0, 2);
      }
    }
  }

  Map<DateTime, List<DateTime>> _mergeEventsByDay(
    Iterable<Map<DateTime, List<DateTime>>> markerMaps,
  ) {
    final merged = <DateTime, List<DateTime>>{};

    for (final markerMap in markerMaps) {
      for (final entry in markerMap.entries) {
        (merged[entry.key] ??= <DateTime>[]).addAll(entry.value);
      }
    }

    return merged;
  }

  bool _isSameMonth(DateTime left, DateTime right) {
    return left.year == right.year && left.month == right.month;
  }
}

Future<DateTime?> showTransactionCalendarSheet(
  BuildContext context, {
  required DateTime initialDate,
  String title = 'Chọn ngày giao dịch',
  String? subtitle,
}) {
  return showAppBottomSheet<DateTime>(
    context: context,
    builder: (context) => _TransactionCalendarBottomSheet(
      initialDate: initialDate,
      title: title,
      subtitle: subtitle,
    ),
  );
}

class _TransactionCalendarBottomSheet extends StatefulWidget {
  const _TransactionCalendarBottomSheet({
    required this.initialDate,
    required this.title,
    this.subtitle,
  });

  final DateTime initialDate;
  final String title;
  final String? subtitle;

  @override
  State<_TransactionCalendarBottomSheet> createState() =>
      _TransactionCalendarBottomSheetState();
}

class _TransactionCalendarBottomSheetState
    extends State<_TransactionCalendarBottomSheet> {
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = normalizeCalendarDay(widget.initialDate);
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
      body: TransactionMarkerCalendar(
        selectedDay: _selectedDay,
        initialFocusedDay: _selectedDay,
        onDaySelected: (selectedDay) {
          setState(() => _selectedDay = normalizeCalendarDay(selectedDay));
        },
      ),
      action: Row(
        children: [
          Expanded(
            child: AppBounceBuilder(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                height: 50,
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
              label: 'Áp dụng ngày này',
              color: Theme.of(context).colorScheme.primary,
              height: 50,
              radius: 16,
              onTap: () => Navigator.of(context).pop(_selectedDay),
            ),
          ),
        ],
      ),
    );
  }
}
