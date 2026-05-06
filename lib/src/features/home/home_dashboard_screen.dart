import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/transaction_provider.dart';
import 'widgets/recent_transactions.dart';
import 'widgets/summary_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summary = ref.watch(transactionSummaryProvider);
    final transactions = ref.watch(recentTransactionsProvider);

    return ColoredBox(
      color: isDark ? colors.surface : const Color(0xFFFAF7FF),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
            sliver: SliverToBoxAdapter(
              child:
                  Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tổng quan',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.78,
                                        ),
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Quản lý chi tiêu',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: colors.onSurface,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -1.2,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 66,
                            height: 66,
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.shadow.withValues(
                                    alpha: isDark ? 0.3 : 0.08,
                                  ),
                                  blurRadius: isDark ? 10 : 22,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_none_rounded,
                                  color: colors.onSurface,
                                  size: 31,
                                ),
                                Positioned(
                                  top: 14,
                                  right: 14,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF2F72),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
            padding: const EdgeInsets.fromLTRB(32, 30, 32, 0),
            sliver: SliverToBoxAdapter(
              child: SummaryCard(summary: summary)
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
            padding: const EdgeInsets.fromLTRB(32, 18, 32, 106),
            sliver: SliverToBoxAdapter(
              child: RecentTransactions(transactions: transactions)
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
    );
  }
}
