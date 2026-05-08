import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/adaptive.dart';
import '../../core/widgets/app_bounce_builder.dart';
import '../../models/auth_user.dart';
import '../../models/transaction.dart';
import '../../providers/auth_provider.dart';
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
    final scale = context.adaptiveScale;
    final authUser = ref.watch(authProvider);
    final allTransactions = ref.watch(transactionsProvider);
    final filteredTransactions = [
      for (final transaction in allTransactions)
        if (_selectedScope.matches(transaction.date)) transaction,
    ];
    final summary = TransactionSummary(
      income: filteredTransactions
          .where((transaction) => transaction.type == TransactionType.income)
          .fold<double>(0, (total, transaction) => total + transaction.amount),
      expense: filteredTransactions
          .where((transaction) => transaction.type == TransactionType.expense)
          .fold<double>(0, (total, transaction) => total + transaction.amount),
    );
    final transactions = [...filteredTransactions]
      ..sort((a, b) => b.date.compareTo(a.date));
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
                        Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tổng quan',
                                        style: context.appText.pageEyebrow,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Quản lý tài chính',
                                        style:
                                            context.appText.pageTitle.copyWith(
                                              color: colors.onSurface,
                                              fontSize: context.scaledFont(
                                                27,
                                                min: 24,
                                              ),
                                              letterSpacing: -1.0 * scale,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                _ProfileAvatarButton(
                                  authUser: authUser,
                                  onTap: () => context.go('/settings'),
                                ),
                              ],
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
                      transactions: transactions,
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

class _ProfileAvatarButton extends StatelessWidget {
  const _ProfileAvatarButton({required this.authUser, required this.onTap});

  final AuthUser? authUser;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avatarLabel = _avatarLabel(authUser);
    final size = context.scaled(60);
    final innerPadding = context.scaled(6);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.scaled(18)),
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(innerPadding),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(context.scaled(18)),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: context.scaled(isDark ? 10 : 18),
              offset: Offset(0, context.scaled(8)),
            ),
          ],
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: authUser == null
                ? AppColors.primary.withValues(alpha: 0.12)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(context.scaled(14)),
          ),
          child: _buildAvatarContent(context, avatarLabel),
        ),
      ),
    );
  }

  Widget _buildAvatarContent(BuildContext context, String avatarLabel) {
    final radius = context.scaled(14);
    final photoUrl = authUser?.photoUrl;
    if (photoUrl == null || photoUrl.isEmpty) {
      return _AvatarFallback(label: avatarLabel);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        photoUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _AvatarFallback(label: avatarLabel);
        },
      ),
    );
  }

  String _avatarLabel(AuthUser? authUser) {
    final source = authUser?.name.trim();
    if (source == null || source.isEmpty) {
      return 'A';
    }

    return source.substring(0, 1).toUpperCase();
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: context.appText.pageTitle.copyWith(
          color: AppColors.primary,
          fontSize: context.scaledFont(22, min: 18),
          letterSpacing: -0.5,
        ),
      ),
    );
  }
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
