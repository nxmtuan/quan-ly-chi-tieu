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

    return InkWell(
      onTap: () {
        if (category != null) {
          showTransactionDetailSheet(
            context,
            transaction: transaction,
            category: category!,
          );
        }
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
                color: (category?.color ?? color).withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(context.scaled(19)),
              ),
              child: Icon(
                category?.iconData ?? Icons.wallet_rounded,
                color: category?.color ?? color,
                size: context.scaled(24),
              ),
            ),
            SizedBox(width: context.scaled(14)),
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
                  SizedBox(height: context.scaled(6)),
                  Text(
                    '${category?.name ?? 'Other'} • ${formatShortDate(transaction.date)}',
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
                  '$sign${formatCurrency(transaction.amount)}',
                  style: context.appText.bodyStrong.copyWith(color: color),
                ),
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
