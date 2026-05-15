part of '../recent_transactions.dart';

class _CategoryAmountRow extends StatelessWidget {
  const _CategoryAmountRow({
    required this.item,
    required this.total,
    required this.showDivider,
    required this.selected,
  });

  final _CategoryAmountItem item;
  final double total;
  final bool showDivider;
  final bool selected;

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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: context.scaled(10),
          vertical: context.scaled(10),
        ),
        decoration: BoxDecoration(
          color: selected
              ? item.color.withValues(alpha: context.isDarkMode ? 0.16 : 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(context.scaled(10)),
          border: Border.all(
            color: selected ? item.color : Colors.transparent,
            width: selected ? 1.2 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: context.scaled(52),
              height: context.scaled(52),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: selected ? 0.18 : 0.13),
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
    this.highlightCategoryIds,
  });

  final Category category;
  final double amount;
  final Color color;
  final Set<String>? highlightCategoryIds;

  Set<String> get highlightCategoryIdsOrSelf =>
      highlightCategoryIds ?? {category.id};
}
