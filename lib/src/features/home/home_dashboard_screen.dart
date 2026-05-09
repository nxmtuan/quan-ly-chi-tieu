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
  bool _showQuickAddButton = true;

  @override
  void initState() {
    super.initState();
    _selectedScope = HomeSummaryScope.month(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

    return ColoredBox(
      color: isDark ? colors.surface : const Color(0xFFFAF7FF),
      child: Stack(
        children: [
          NotificationListener<UserScrollNotification>(
            onNotification: _handleScrollNotification,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    context.scaled(24),
                    context.scaled(22),
                    context.scaled(24),
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child:
                        const AppPageHeader(
                              subtitle: 'Tổng quan',
                              title: 'Quản lý tài chính',
                            )
                            .animate()
                            .fadeIn(duration: 260.ms)
                            .slideY(
                              begin: -0.08,
                              end: 0,
                              duration: 320.ms,
                              curve: Curves.easeOutCubic,
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
                    child:
                        SummaryCard(
                              summary: summary,
                              scope: _selectedScope,
                              selectedType: _selectedType,
                              onSelectedType: (type) {
                                setState(() => _selectedType = type);
                              },
                              onPreviousScope: _selectedScope.canGoPrevious
                                  ? _goToPreviousScope
                                  : null,
                              onNextScope: _selectedScope.canGoNext(now)
                                  ? _goToNextScope
                                  : null,
                              onPickScope: _pickMonth,
                            )
                            .animate(delay: 80.ms)
                            .fadeIn(duration: 320.ms)
                            .slideY(
                              begin: 0.08,
                              end: 0,
                              duration: 360.ms,
                              curve: Curves.easeOutCubic,
                            ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    context.scaled(24),
                    context.scaled(16),
                    context.scaled(24),
                    context.scaled(176) + MediaQuery.paddingOf(context).bottom,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: RecentTransactions(
                      scope: _selectedScope,
                      transactions: filteredTransactions,
                      selectedType: _selectedType,
                    )
                        .animate(delay: 150.ms)
                        .fadeIn(duration: 320.ms)
                        .slideY(
                          begin: 0.06,
                          end: 0,
                          duration: 360.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
                ),
              ],
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

class _QuickAddButton extends StatelessWidget {
  const _QuickAddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBounceBuilder(
      onTap: onTap,
      child: Container(
        width: context.scaled(60),
        height: context.scaled(60),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primary.withValues(alpha: 0.72),
              colors.primary,
            ],
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.white,
            width: context.scaled(2.4),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: isDark ? 0.28 : 0.34),
              blurRadius: context.scaled(16),
              offset: Offset(0, context.scaled(8)),
            ),
          ],
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
