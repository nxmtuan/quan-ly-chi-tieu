part of '../statistics_screen.dart';

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.item});

  final _BreakdownItem item;

  @override
  Widget build(BuildContext context) {
    return FlatCard(
      radius: context.scaled(24),
      padding: EdgeInsets.all(context.scaled(16)),
      child: Row(
        children: [
          Container(
            width: context.scaled(44),
            height: context.scaled(44),
            decoration: BoxDecoration(
              color: item.category.color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(context.scaled(16)),
            ),
            child: Icon(
              item.category.iconData,
              color: item.category.color,
              size: context.scaled(22),
            ),
          ),
          SizedBox(width: context.scaled(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.category.name,
                  style: context.appText.bodyStrong.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: context.scaled(8)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: item.percentage / 100,
                    minHeight: 7,
                    backgroundColor: AppColors.background,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      item.category.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.scaled(14)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.percentage.toStringAsFixed(0)}%',
                style: context.appText.bodyStrong.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: context.scaled(5)),
              Text(
                formatCurrency(item.amount),
                style: context.appText.captionStrong.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BreakdownItem {
  const _BreakdownItem({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  final Category category;
  final double amount;
  final double percentage;
}
