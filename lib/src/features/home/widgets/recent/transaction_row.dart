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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      radius: 24,
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
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${category?.name ?? 'Other'} • ${formatShortDate(transaction.date)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  if (value == 'edit') {
                    showAddTransactionSheet(context, transaction: transaction);
                  }
                  if (value == 'delete') {
                    ref
                        .read(transactionsProvider.notifier)
                        .deleteTransaction(transaction.id);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
                child: const Icon(
                  Icons.more_horiz_rounded,
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
