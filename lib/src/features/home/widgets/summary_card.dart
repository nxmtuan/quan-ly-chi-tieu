import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/transaction_provider.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.summary});

  final TransactionSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: isDark ? 8 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              children: [
                Icon(
                  Icons.chevron_left_rounded,
                  color: colors.onSurface.withValues(alpha: 0.62),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 16,
                        color: colors.onSurface.withValues(alpha: 0.72),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tháng ${DateTime.now().month}/${DateTime.now().year}',
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.onSurface.withValues(alpha: 0.62),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SummaryMetricCard(
                  label: 'Chi tiêu',
                  amount: summary.expense,
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.danger,
                  isHighlighted: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryMetricCard(
                  label: 'Thu nhập',
                  amount: summary.income,
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.success,
                  isHighlighted: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(
                alpha: isDark ? 0.18 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.visibility_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Thu - Chi = ${formatCurrency(summary.balance)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetricCard extends StatelessWidget {
  const _SummaryMetricCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.isHighlighted,
  });

  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isHighlighted ? color : colors.outlineVariant,
          width: isHighlighted ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formatCurrency(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}
