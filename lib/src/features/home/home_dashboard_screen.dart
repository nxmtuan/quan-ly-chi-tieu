import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          sliver: SliverToBoxAdapter(
            child:
                Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tổng quan',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: colors.onSurface.withValues(
                                        alpha: 0.64,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Quản lý chi tiêu',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.7,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: colors.shadow.withValues(
                                  alpha: isDark ? 0.3 : 0.05,
                                ),
                                blurRadius: isDark ? 8 : 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.notifications_none_rounded,
                            color: colors.onSurface,
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
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
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
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 120),
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
    );
  }
}
