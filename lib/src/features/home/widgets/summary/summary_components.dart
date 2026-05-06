part of '../summary_card.dart';

class _MonthSelectorBar extends StatelessWidget {
  const _MonthSelectorBar({
    required this.displayedMonth,
    required this.canGoNext,
    required this.onPreviousMonth,
    required this.onPickMonth,
    this.onNextMonth,
  });

  final DateTime displayedMonth;
  final bool canGoNext;
  final VoidCallback onPreviousMonth;
  final VoidCallback onPickMonth;
  final VoidCallback? onNextMonth;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: isDark ? 12 : 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onPreviousMonth,
            borderRadius: BorderRadius.circular(999),
            child: Icon(
              Icons.chevron_left_rounded,
              color: colors.onSurface,
              size: 31,
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: onPickMonth,
              borderRadius: BorderRadius.circular(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Text(
                    formatMonthYear(displayedMonth),
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: onNextMonth,
            borderRadius: BorderRadius.circular(999),
            child: Icon(
              Icons.chevron_right_rounded,
              color: canGoNext
                  ? colors.onSurface
                  : colors.onSurface.withValues(alpha: 0.24),
              size: 31,
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceBanner extends StatelessWidget {
  const _BalanceBanner({required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLight.withValues(alpha: isDark ? 0.2 : 0.74),
            AppColors.primaryLight.withValues(alpha: isDark ? 0.16 : 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
      ),
      child: Text(
        'Dư: ${formatCurrency(balance)}',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
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
    required this.backgroundColor,
  });

  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 138,
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [backgroundColor, colors.surface],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(icon, size: 27, color: color),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            formatCurrency(amount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 25,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
        ],
      ),
    );
  }
}
