part of '../recent_transactions.dart';

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({required this.selectedType, required this.onSelected});

  final TransactionType selectedType;
  final ValueChanged<TransactionType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _CategoryTab(
              label: 'Chi tiêu',
              isSelected: selectedType == TransactionType.expense,
              color: AppColors.danger,
              onTap: () => onSelected(TransactionType.expense),
            ),
          ),
          Expanded(
            child: _CategoryTab(
              label: 'Thu nhập',
              isSelected: selectedType == TransactionType.income,
              color: AppColors.success,
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
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(
          top: context.scaled(12),
          bottom: context.scaled(14),
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: context.appText.sectionTitle.copyWith(
            color: isSelected ? color : AppColors.textSecondary,
          ),
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
  });

  final _CategoryAmountItem item;
  final double total;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : ((item.amount / total) * 100).round();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.scaled(12),
            vertical: context.scaled(10),
          ),
          child: Row(
            children: [
              Container(
                width: context.scaled(34),
                height: context.scaled(34),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(context.scaled(12)),
                ),
                child: Icon(
                  item.category.iconData,
                  color: item.color,
                  size: context.scaled(18),
                ),
              ),
              SizedBox(width: context.scaled(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.appText.bodyStrong.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: context.scaled(3)),
                    Text(
                      '$percent%',
                      style: context.appText.captionStrong.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatCurrency(item.amount),
                style: context.appText.bodyStrong.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: context.scaled(4)),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: context.scaled(18),
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.only(left: context.scaled(56)),
            child: Divider(height: 1, color: AppColors.border),
          ),
      ],
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
