part of '../add_transaction_sheet.dart';

void showTransactionDetailSheet(
  BuildContext context, {
  required Transaction transaction,
  required Category category,
}) {
  showAppBottomSheet<void>(
    context: context,
    builder: (context) {
      return _TransactionDetailSheet(
        transaction: transaction,
        category: category,
      );
    },
  );
}

class _TransactionDetailSheet extends ConsumerWidget {
  const _TransactionDetailSheet({
    required this.transaction,
    required this.category,
  });

  final Transaction transaction;
  final Category category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpense = transaction.type == TransactionType.expense;
    final color = isExpense ? const Color(0xFFFF1493) : AppColors.success;
    final sign = isExpense ? '-' : '+';
    final title = isExpense ? 'Giao dịch chi' : 'Giao dịch thu';

    return AppSheetScaffold(
      title: title,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: context.scaled(24)),
            Container(
              width: context.scaled(72),
              height: context.scaled(72),
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.iconData,
                color: category.color,
                size: context.scaled(32),
              ),
            ),
            SizedBox(height: context.scaled(12)),
            Text(
              '$sign${formatCurrency(transaction.amount)}',
              style: context.appText.amountXL.copyWith(
                color: color,
                fontSize: context.scaledFont(32, min: 28),
              ),
            ),
            if (transaction.note.isNotEmpty) ...[
              SizedBox(height: context.scaled(12)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.scaled(12),
                  vertical: context.scaled(8),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(context.scaled(8)),
                ),
                child: Text(
                  transaction.note,
                  textAlign: TextAlign.center,
                  style: context.appText.body.copyWith(
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
            ],
            SizedBox(height: context.scaled(24)),
            Container(
              padding: EdgeInsets.all(context.scaled(16)),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(context.scaled(16)),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildRow(context, label: 'Danh mục', value: category.name),
                  Divider(color: AppColors.border, height: context.scaled(24)),
                  _buildRow(
                    context,
                    label: 'Loại',
                    value: isExpense ? 'Chi tiêu' : 'Thu nhập',
                  ),
                  Divider(color: AppColors.border, height: context.scaled(24)),
                  _buildRow(context, label: 'Nguồn tiền', value: 'Tiền mặt'),
                  Divider(color: AppColors.border, height: context.scaled(24)),
                  _buildRow(
                    context,
                    label: 'Ngày giao dịch',
                    value: formatShortDate(transaction.date),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.scaled(8)),
          ],
        ),
      ),
      action: Row(
        children: [
          Expanded(
            child: AppBounceBuilder(
              onTap: () => _confirmDelete(context, ref),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: context.scaled(16)),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(context.scaled(16)),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Xóa',
                  style: context.appText.buttonLabel.copyWith(
                    color: const Color(0xFFDC2626),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: context.scaled(12)),
          Expanded(
            child: AppBounceBuilder(
              onTap: () {
                Navigator.of(context).pop();
                showAddTransactionSheet(
                  context,
                  transaction: transaction,
                  replaceSheet: true,
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: context.scaled(16)),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(context.scaled(16)),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: context.scaled(8),
                      offset: Offset(0, context.scaled(4)),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Chỉnh sửa',
                  style: context.appText.buttonLabel,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Xóa giao dịch',
      message: 'Bạn có chắc muốn xóa giao dịch này không?',
      confirmText: 'Xóa',
      confirmTextColor: const Color(0xFFDC2626),
      confirmBackgroundColor: const Color(0xFFFEE2E2),
    );

    if (confirmed == true && context.mounted) {
      ref.read(transactionsProvider.notifier).deleteTransaction(transaction.id);
      AppToast.show(
        context,
        message: 'Đã xóa giao dịch',
        type: AppToastType.success,
      );
      Navigator.of(context).pop();
    }
  }

  Widget _buildRow(
    BuildContext context, {
    required String label,
    String? value,
    Widget? valueWidget,
    Color? valueColor,
    double? valueSize,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: context.scaled(110),
          child: Text(
            label,
            style: context.appText.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: valueWidget ??
                Text(
                  value ?? '',
                  textAlign: TextAlign.right,
                  style: context.appText.bodyStrong.copyWith(
                    color: valueColor ?? AppColors.textPrimary,
                    fontSize: valueSize != null
                        ? context.scaledFont(valueSize, min: valueSize - 2)
                        : null,
                  ),
                ),
          ),
        ),
      ],
    );
  }
}
