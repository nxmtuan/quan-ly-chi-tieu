part of '../recent_transactions.dart';

void showCategoryTransactionsSheet(
  BuildContext context, {
  required Category category,
  required HomeSummaryScope scope,
}) {
  showAppBottomSheet<void>(
    context: context,
    builder: (context) {
      return _CategoryTransactionsSheet(
        category: category,
        scope: scope,
      );
    },
  );
}

class _CategoryTransactionsSheet extends ConsumerWidget {
  const _CategoryTransactionsSheet({
    required this.category,
    required this.scope,
  });

  final Category category;
  final HomeSummaryScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTransactions = ref.watch(transactionsProvider);
    final categoryTransactions = allTransactions
        .where((t) =>
            t.categoryId == category.id &&
            t.type == category.type &&
            scope.matches(t.date))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final total = categoryTransactions.fold<double>(
      0,
      (sum, t) => sum + t.amount,
    );

    return AppSheetScaffold(
      title: category.name,
      subtitle: 'Tổng: ${formatCurrency(total)}',
      bodyPadding: EdgeInsets.zero,
      body: categoryTransactions.isEmpty
          ? Center(
              child: Text(
                'Không có giao dịch nào',
                style: context.appText.bodyStrong.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: context.scaled(16),
                vertical: context.scaled(8),
              ),
              itemCount: categoryTransactions.length,
              separatorBuilder: (_, _) =>
                  SizedBox(height: context.scaled(12)),
              itemBuilder: (context, index) {
                return TransactionRow(
                  transaction: categoryTransactions[index],
                );
              },
            ),
    );
  }
}
