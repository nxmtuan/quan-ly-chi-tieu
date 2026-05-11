part of '../summary_card.dart';

class _MonthSelectorBar extends StatelessWidget {
  const _MonthSelectorBar({
    required this.scope,
    required this.onPickScope,
    this.onPreviousScope,
    this.onNextScope,
  });

  final HomeSummaryScope scope;
  final VoidCallback? onPreviousScope;
  final VoidCallback onPickScope;
  final VoidCallback? onNextScope;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final scale = context.adaptiveScale;

    return Container(
      height: context.scaled(72),
      padding: EdgeInsets.symmetric(horizontal: context.scaled(18)),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(context.scaled(20)),
      ),
      child: Row(
        children: [
          AppBounceBuilder(
            onTap: onPreviousScope,
            child: Icon(
              Icons.chevron_left_rounded,
              color: onPreviousScope != null
                  ? colors.onSurface
                  : colors.onSurface.withValues(alpha: 0.24),
              size: context.scaled(28),
            ),
          ),
          Expanded(
            child: AppBounceBuilder(
              onTap: onPickScope,
              child: Text(
                scope.label,
                textAlign: TextAlign.center,
                style: context.appText.cardTitle.copyWith(
                  color: colors.onSurface,
                  fontSize: context.scaledFont(16, min: 15),
                  letterSpacing: -0.2 * scale,
                ),
              ),
            ),
          ),
          AppBounceBuilder(
            onTap: onNextScope,
            child: Icon(
              Icons.chevron_right_rounded,
              color: onNextScope != null
                  ? colors.onSurface
                  : colors.onSurface.withValues(alpha: 0.24),
              size: context.scaled(28),
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
    final palette = context.appPalette;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.scaled(18),
        vertical: context.scaled(14),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            palette.primarySoft.withValues(alpha: isDark ? 0.2 : 0.74),
            palette.primarySoft.withValues(alpha: isDark ? 0.16 : 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(context.scaled(16)),
        border: Border.all(
          color: palette.surfaceElevated.withValues(alpha: 0.8),
        ),
      ),
      child: Text(
        'Dư: ${formatCurrency(balance)}',
        textAlign: TextAlign.center,
        style: context.appText.amountMD.copyWith(color: AppColors.primary),
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
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final isDark = context.isDarkMode;
    final colors = Theme.of(context).colorScheme;
    final backgroundFill = isDark
        ? Color.alphaBlend(
            backgroundColor.withValues(alpha: isSelected ? 0.1 : 0.06),
            palette.surface,
          )
        : (isSelected ? backgroundColor : colors.surface);

    return AppBounceBuilder(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: context.scaled(120),
        padding: EdgeInsets.fromLTRB(
          context.scaled(16),
          context.scaled(16),
          context.scaled(14),
          context.scaled(14),
        ),
        decoration: BoxDecoration(
          color: backgroundFill,
          borderRadius: BorderRadius.circular(context.scaled(21)),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.32)
                : context.appPalette.surfaceElevated,
            width: isSelected ? 2.2 : 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: context.scaled(40),
                  height: context.scaled(40),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Icon(icon, size: context.scaled(23), color: color),
                ),
                SizedBox(width: context.scaled(10)),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.appText.cardTitle.copyWith(color: color),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              formatCurrency(amount),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.appText.amountSM.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
