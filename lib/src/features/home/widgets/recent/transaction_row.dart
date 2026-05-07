part of '../recent_transactions.dart';

class TransactionRow extends ConsumerWidget {
  const TransactionRow({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _TransactionRow(
      transaction: transaction,
      category: ref.watch(categoryByIdProvider(transaction.categoryId)),
    );
  }
}

class _TransactionRow extends ConsumerWidget {
  const _TransactionRow({required this.transaction, required this.category});

  final Transaction transaction;
  final Category? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = transaction.isExpense ? AppColors.danger : AppColors.success;
    final sign = transaction.isExpense ? '-' : '+';

    return FlatCard(
      padding: EdgeInsets.zero,
      radius: 24,
      child: InkWell(
        onTap: () {
          if (category != null) {
            showTransactionDetailSheet(
              context,
              transaction: transaction,
              category: category!,
            );
          }
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: (category?.color ?? color).withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: Icon(
                  category?.iconData ?? Icons.wallet_rounded,
                  color: category?.color ?? color,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.note.isEmpty
                          ? category?.name ?? 'Transaction'
                          : transaction.note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.appText.fieldValue.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${category?.name ?? 'Other'} • ${formatShortDate(transaction.date)}',
                      style: context.appText.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$sign${formatCurrency(transaction.amount)}',
                    style: context.appText.bodyStrong.copyWith(
                      color: color,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
