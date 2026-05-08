import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/adaptive.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_table_calendar.dart';
import '../../core/widgets/flat_card.dart';
import '../../models/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../home/widgets/recent_transactions.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = normalizeCalendarDay(DateTime.now());
    _focusedDay = _selectedDay;
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final eventsByDay = buildCalendarEventIndex(
      transactions,
      (transaction) => transaction.date,
    );
    final dailyTransactions = eventsByDay[_selectedDay] ?? const <Transaction>[];
    final income = dailyTransactions
        .where((transaction) => transaction.type == TransactionType.income)
        .fold<double>(0, (total, transaction) => total + transaction.amount);
    final expense = dailyTransactions
        .where((transaction) => transaction.type == TransactionType.expense)
        .fold<double>(0, (total, transaction) => total + transaction.amount);

    return ListView(
          padding: EdgeInsets.fromLTRB(
            context.scaled(24),
            context.scaled(22),
            context.scaled(24),
            context.scaled(120) + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lịch',
                  style: context.appText.pageEyebrow,
                ),
                const SizedBox(height: 5),
                Text(
                  'Thống kê giao dịch',
                  style: context.appText.pageTitle.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: context.scaledFont(27, min: 24),
                    letterSpacing: -1.0 * context.adaptiveScale,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.scaled(22)),
            AppTableCalendar(
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              eventLoader: (day) =>
                  eventsByDay[normalizeCalendarDay(day)] ?? const [],
              onDaySelected: (selectedDay) {
                setState(
                  () => _selectedDay = normalizeCalendarDay(selectedDay),
                );
              },
              onPageChanged: (focusedDay) {
                setState(() => _focusedDay = normalizeCalendarDay(focusedDay));
              },
            ),
            SizedBox(height: context.scaled(18)),
            FlatCard(
              radius: context.scaled(26),
              padding: EdgeInsets.fromLTRB(
                context.scaled(18),
                context.scaled(18),
                context.scaled(18),
                context.scaled(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _calendarHeadline(_selectedDay),
                    style: context.appText.sectionTitle.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: context.scaled(6)),
                  Text(
                    formatLongDate(_selectedDay),
                    style: context.appText.secondaryStrong.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: context.scaled(16)),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricPill(
                          label: 'Thu',
                          amount: income,
                          color: AppColors.success,
                        ),
                      ),
                      SizedBox(width: context.scaled(10)),
                      Expanded(
                        child: _MetricPill(
                          label: 'Chi',
                          amount: expense,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: context.scaled(18)),
            if (dailyTransactions.isEmpty)
              FlatCard(
                radius: context.scaled(26),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: context.scaled(10)),
                  child: Center(
                    child: Text(
                      'Ngày này chưa có giao dịch nào',
                      style: context.appText.bodyStrong.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              )
            else
              FlatCard(
                radius: context.scaled(22),
                padding: EdgeInsets.all(context.scaled(14)),
                child: Column(
                  children: [
                    for (final entry in dailyTransactions.indexed) ...[
                      TransactionRow(transaction: entry.$2),
                      if (entry.$1 < dailyTransactions.length - 1)
                        Divider(height: context.scaled(1), color: AppColors.border),
                    ],
                  ],
                ),
              ),
          ],
        )
        .animate()
        .fadeIn(duration: 260.ms)
        .slideY(
          begin: 0.04,
          end: 0,
          duration: 340.ms,
          curve: Curves.easeOutCubic,
        );
  }

  String _calendarHeadline(DateTime day) {
    if (DateUtils.isSameDay(day, DateTime.now())) {
      return 'Hôm nay';
    }

    return 'Ngày đã chọn';
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.scaled(14),
        vertical: context.scaled(12),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(context.scaled(18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.appText.captionStrong.copyWith(color: color),
          ),
          SizedBox(height: context.scaled(6)),
          Text(
            formatCurrency(amount),
            style: context.appText.amountMD.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
