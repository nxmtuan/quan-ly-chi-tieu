part of '../recent_transactions.dart';

class _CategoryAmountRow extends StatelessWidget {
  const _CategoryAmountRow({
    required this.item,
    required this.total,
    required this.showDivider,
  });

  final _CategoryAmountItem item;
  final double total;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : ((item.amount / total) * 100).round();
    final isExpense = item.category.type == TransactionType.expense;
    final color = isExpense ? AppColors.danger : AppColors.success;
    final sign = isExpense ? '-' : '+';

    return AppBounceBuilder(
      onTap: () {
        showCategoryTransactionsSheet(context, category: item.category);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.scaled(4),
          vertical: context.scaled(12),
        ),
        child: Row(
          children: [
            Container(
              width: context.scaled(52),
              height: context.scaled(52),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(context.scaled(19)),
              ),
              child: Icon(
                item.category.iconData,
                color: item.color,
                size: context.scaled(24),
              ),
            ),
            SizedBox(width: context.scaled(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.appText.fieldValue,
                  ),
                  SizedBox(height: context.scaled(6)),
                  Text(
                    'Chiếm $percent% tổng',
                    style: context.appText.caption.copyWith(
                      color: context.appPalette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: context.scaled(12)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$sign${formatCurrency(item.amount)}',
                  style: context.appText.bodyStrong.copyWith(color: color),
                ),
                SizedBox(height: context.scaled(4)),
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.appPalette.textSecondary,
                  size: context.scaled(20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryAmountItem {
  const _CategoryAmountItem({
    required this.category,
    required this.amount,
    required this.color,
  });

  final Category category;
  final double amount;
  final Color color;
}
