import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/adaptive.dart';
import '../../core/widgets/app_bounce_builder.dart';
import '../../core/widgets/app_page_header.dart';
import '../../models/transaction.dart';
import '../../providers/transaction_provider.dart';
import 'models/home_summary_scope.dart';
import '../transactions/add_transaction_sheet.dart';
import 'widgets/recent_transactions.dart';
import 'widgets/summary_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late HomeSummaryScope _selectedScope;
  TransactionType _selectedType = TransactionType.expense;
  TransactionType _previousSelectedType = TransactionType.expense;
  bool _showQuickAddButton = true;

  @override
  void initState() {
    super.initState();
    _selectedScope = HomeSummaryScope.month(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final scopeRange = _selectedScope.dateRange;
    final filteredTransactions = ref.watch(
      transactionsQueryProvider((
        categoryId: null,
        fromDate: scopeRange?.start,
        limit: null,
        toDate: scopeRange?.end,
        type: null,
      )),
    );
    final summary = TransactionSummary(
      income: filteredTransactions
          .where((transaction) => transaction.type == TransactionType.income)
          .fold<double>(0, (total, transaction) => total + transaction.amount),
      expense: filteredTransactions
          .where((transaction) => transaction.type == TransactionType.expense)
          .fold<double>(0, (total, transaction) => total + transaction.amount),
    );
    final now = DateTime.now();
    final expenseComparison = _expensePeriodComparison(now);

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: [
          NotificationListener<UserScrollNotification>(
            onNotification: _handleScrollNotification,
            child:
                CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            context.scaled(24),
                            context.scaled(22),
                            context.scaled(24),
                            0,
                          ),
                          sliver: const SliverToBoxAdapter(
                            child: AppPageHeader(
                              subtitle: 'Tổng quan',
                              title: 'Quản lý tài chính',
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            context.scaled(24),
                            context.scaled(24),
                            context.scaled(24),
                            0,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: SummaryCard(
                              summary: summary,
                              expenseComparison: expenseComparison,
                              scope: _selectedScope,
                              selectedType: _selectedType,
                              onSelectedType: (type) {
                                if (type == _selectedType) {
                                  return;
                                }

                                setState(() {
                                  _previousSelectedType = _selectedType;
                                  _selectedType = type;
                                });
                              },
                              onPreviousScope: _selectedScope.canGoPrevious
                                  ? _goToPreviousScope
                                  : null,
                              onNextScope: _selectedScope.canGoNext(now)
                                  ? _goToNextScope
                                  : null,
                              onPickScope: _pickMonth,
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            context.scaled(24),
                            context.scaled(16),
                            context.scaled(24),
                            context.scaled(176) +
                                MediaQuery.paddingOf(context).bottom,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 260),
                              reverseDuration: const Duration(
                                milliseconds: 220,
                              ),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              layoutBuilder: (currentChild, previousChildren) {
                                return Stack(
                                  alignment: Alignment.topCenter,
                                  children: [
                                    ...previousChildren,
                                    ?currentChild,
                                  ],
                                );
                              },
                              transitionBuilder: (child, animation) {
                                final isIncoming =
                                    child.key ==
                                    ValueKey<TransactionType>(_selectedType);
                                final slideDirection =
                                    _selectedType.index >=
                                        _previousSelectedType.index
                                    ? 1.0
                                    : -1.0;
                                final beginOffset = Offset(
                                  isIncoming
                                      ? 0.08 * slideDirection
                                      : -0.04 * slideDirection,
                                  0,
                                );

                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: beginOffset,
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: RecentTransactions(
                                key: ValueKey(_selectedType),
                                scope: _selectedScope,
                                transactions: filteredTransactions,
                                selectedType: _selectedType,
                              ),
                            ),
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
                    ),
          ),
          Positioned(
            right: context.scaled(24),
            bottom: context.scaled(26) + MediaQuery.paddingOf(context).bottom,
            child: IgnorePointer(
              ignoring: !_showQuickAddButton,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                offset: _showQuickAddButton
                    ? Offset.zero
                    : const Offset(0, 1.2),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: _showQuickAddButton ? 1 : 0,
                  child: _QuickAddButton(
                    onTap: () => showAddTransactionSheet(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ExpensePeriodComparison _expensePeriodComparison(DateTime now) {
    final currentExpense = _expenseTotal(
      fromDate: DateTime(now.year, now.month),
      toDate: DateTime(now.year, now.month, now.day, 23, 59, 59, 999),
    );
    final previousMonthStart = DateTime(now.year, now.month - 1);
    final previousMonthEnd = _sameDayPreviousMonthEnd(now);
    final previousExpense = _expenseTotal(
      fromDate: previousMonthStart,
      toDate: previousMonthEnd,
    );

    return ExpensePeriodComparison(
      currentExpense: currentExpense,
      previousExpense: previousExpense,
    );
  }

  double _expenseTotal({required DateTime fromDate, required DateTime toDate}) {
    final transactions = ref.watch(
      transactionsQueryProvider((
        categoryId: null,
        fromDate: fromDate,
        limit: null,
        toDate: toDate,
        type: TransactionType.expense,
      )),
    );

    return transactions.fold<double>(
      0,
      (total, transaction) => total + transaction.amount,
    );
  }

  void _goToPreviousScope() {
    setState(() => _selectedScope = _selectedScope.previous());
  }

  void _goToNextScope() {
    final now = DateTime.now();
    if (!_selectedScope.canGoNext(now)) {
      return;
    }

    setState(() => _selectedScope = _selectedScope.next());
  }

  Future<void> _pickMonth() async {
    final selectedScope = await showMonthPickerSheet(
      context,
      initialScope: _selectedScope,
      lastMonth: _monthStart(DateTime.now()),
    );

    if (selectedScope != null && mounted) {
      setState(() => _selectedScope = selectedScope);
    }
  }

  bool _handleScrollNotification(UserScrollNotification notification) {
    if (!mounted) {
      return false;
    }

    if (notification.direction == ScrollDirection.reverse) {
      if (_showQuickAddButton) {
        setState(() => _showQuickAddButton = false);
      }
    } else if (notification.direction == ScrollDirection.forward) {
      if (!_showQuickAddButton) {
        setState(() => _showQuickAddButton = true);
      }
    }

    return false;
  }
}

DateTime _monthStart(DateTime date) {
  return DateTime(date.year, date.month);
}

DateTime _sameDayPreviousMonthEnd(DateTime date) {
  final previousMonthStart = DateTime(date.year, date.month - 1);
  final previousMonthLastDay = DateTime(
    previousMonthStart.year,
    previousMonthStart.month + 1,
    0,
  ).day;
  final day = date.day > previousMonthLastDay ? previousMonthLastDay : date.day;

  return DateTime(
    previousMonthStart.year,
    previousMonthStart.month,
    day,
    23,
    59,
    59,
    999,
  );
}

class _QuickAddButton extends StatelessWidget {
  const _QuickAddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AppBounceBuilder(
      onTap: onTap,
      child: Container(
        width: context.scaled(60),
        height: context.scaled(60),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.primary.withValues(alpha: 0.72), colors.primary],
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white, width: context.scaled(2.4)),
        ),
        child: Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: context.scaled(30),
        ),
      ),
    );
  }
}
