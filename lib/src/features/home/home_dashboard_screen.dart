import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/transaction_provider.dart';
import 'widgets/recent_transactions.dart';
import 'widgets/summary_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(transactionSummaryProvider);
    final transactions = ref.watch(recentTransactionsProvider);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your Money Flow',
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF64748B).withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          sliver: SliverToBoxAdapter(child: SummaryCard(summary: summary)),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 120),
          sliver: SliverToBoxAdapter(
            child: RecentTransactions(transactions: transactions),
          ),
        ),
      ],
    );
  }
}
