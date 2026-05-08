part of '../recent_transactions.dart';

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({required this.selectedType, required this.onSelected});

  final TransactionType selectedType;
  final ValueChanged<TransactionType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.scaled(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.scaled(14)),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.06),
            blurRadius: context.scaled(9),
            offset: Offset(0, context.scaled(3)),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _CategoryTab(
              label: 'Chi tiêu',
              isSelected: selectedType == TransactionType.expense,
              color: const Color(0xFFFF1493),
              icon: Icons.trending_up_rounded,
              onTap: () => onSelected(TransactionType.expense),
            ),
          ),
          Expanded(
            child: _CategoryTab(
              label: 'Thu nhập',
              isSelected: selectedType == TransactionType.income,
              color: AppColors.success,
              icon: Icons.trending_down_rounded,
              onTap: () => onSelected(TransactionType.income),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.scaled(14)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: context.scaled(8)),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.06) : Colors.transparent,
          borderRadius: BorderRadius.circular(context.scaled(14)),
          border: isSelected
              ? Border.all(color: color.withValues(alpha: 0.24))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: context.scaled(26),
              height: context.scaled(26),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                icon,
                color: isSelected ? color : const Color(0xFF4B5563),
                size: context.scaled(16),
              ),
            ),
            SizedBox(width: context.scaled(8)),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.appText.captionStrong.copyWith(
                  color: isSelected ? color : const Color(0xFF4B5563),
                  fontSize: context.scaledFont(13, min: 12),
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryAmountRow extends StatelessWidget {
  const _CategoryAmountRow({
    required this.item,
    required this.total,
    required this.showDivider,
    required this.month,
    required this.transactions,
  });

  final _CategoryAmountItem item;
  final double total;
  final bool showDivider;
  final DateTime month;
  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : ((item.amount / total) * 100).round();
    final isExpense = item.category.type == TransactionType.expense;
    final color = isExpense ? AppColors.danger : AppColors.success;
    final sign = isExpense ? '-' : '+';

    return InkWell(
      onTap: () {
        showCategoryTransactionsSheet(
          context,
          category: item.category,
          month: month,
        );
      },
      borderRadius: BorderRadius.circular(context.scaled(12)),
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
                    style: context.appText.fieldValue.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: context.scaled(6)),
                  Text(
                    'Chiếm $percent% tổng',
                    style: context.appText.caption.copyWith(
                      color: AppColors.textSecondary,
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
                  style: context.appText.bodyStrong.copyWith(
                    color: color,
                  ),
                ),
                SizedBox(height: context.scaled(4)),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
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
