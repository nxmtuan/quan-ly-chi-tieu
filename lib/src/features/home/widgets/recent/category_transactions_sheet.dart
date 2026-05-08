part of '../recent_transactions.dart';

void showCategoryTransactionsSheet(
  BuildContext context, {
  required Category category,
  required DateTime month,
}) {
  showAppBottomSheet<void>(
    context: context,
    builder: (context) {
      return _CategoryTransactionsSheet(
        category: category,
        month: month,
      );
    },
  );
}

class _CategoryTransactionsSheet extends ConsumerWidget {
  const _CategoryTransactionsSheet({
    required this.category,
    required this.month,
  });

  final Category category;
  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTransactions = ref.watch(transactionsProvider);
    final categoryTransactions = allTransactions
        .where((t) =>
            t.categoryId == category.id &&
            t.type == category.type &&
            t.date.year == month.year &&
            t.date.month == month.month)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final total = categoryTransactions.fold<double>(
      0,
      (sum, t) => sum + t.amount,
    );

    return AppSheetContainer(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            0,
            0,
            0,
            appSheetBottomPadding(context, extra: 16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSheetHeader(
                title: category.name,
                subtitle: 'Tổng: ${formatCurrency(total)}',
              ),
              SizedBox(height: context.scaled(16)),
              if (categoryTransactions.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: context.scaled(20)),
                  child: Text(
                    'Không có giao dịch nào',
                    style: context.appText.bodyStrong.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: context.scaled(16)),
                    itemCount: categoryTransactions.length,
                    separatorBuilder: (_, __) => SizedBox(height: context.scaled(12)),
                    itemBuilder: (context, index) {
                      return TransactionRow(
                        transaction: categoryTransactions[index],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
