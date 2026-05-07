part of '../recent_transactions.dart';

void showCategoryTransactionsSheet(
  BuildContext context, {
  required Category category,
  required List<Transaction> transactions,
}) {
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _CategoryTransactionsSheet(
        category: category,
        transactions: transactions,
      );
    },
  );
}

class _CategoryTransactionsSheet extends StatelessWidget {
  const _CategoryTransactionsSheet({
    required this.category,
    required this.transactions,
  });

  final Category category;
  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    final categoryTransactions = transactions
        .where((t) => t.categoryId == category.id && t.type == category.type)
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
                subtitle: 'Tổng: ${formatCurrency(total)} đ',
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
