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
        padding: const EdgeInsets.only(top: 10, bottom: 12),
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
          style: TextStyle(
            color: isSelected ? color : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  item.category.iconData,
                  color: item.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatCurrency(item.amount),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.only(left: 64),
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
