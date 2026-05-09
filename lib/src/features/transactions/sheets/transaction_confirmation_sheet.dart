part of '../add_transaction_sheet.dart';

Future<bool> showTransactionConfirmationSheet(
  BuildContext context, {
  required Transaction transaction,
  required Category category,
  required MoneySource source,
}) async {
  final result = await showAppBottomSheet<bool>(
    context: context,
    builder: (context) => _TransactionConfirmationSheet(
      transaction: transaction,
      category: category,
      source: source,
    ),
  );

  return result ?? false;
}

class _TransactionConfirmationSheet extends StatelessWidget {
  const _TransactionConfirmationSheet({
    required this.transaction,
    required this.category,
    required this.source,
  });

  final Transaction transaction;
  final Category category;
  final MoneySource source;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final isExpense = transaction.type == TransactionType.expense;
    final color = isExpense ? const Color(0xFFFF1493) : AppColors.success;
    final sign = isExpense ? '-' : '+';

    return AppSheetScaffold(
      title: 'Xác nhận',
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
            if (transaction.hasNote) ...[
              SizedBox(height: context.scaled(12)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.scaled(12),
                  vertical: context.scaled(8),
                ),
                decoration: BoxDecoration(
                  color: palette.inputBackground,
                  borderRadius: BorderRadius.circular(context.scaled(8)),
                ),
                child: Text(
                  transaction.note!,
                  textAlign: TextAlign.center,
                  style: context.appText.body.copyWith(
                    color: palette.iconMuted,
                  ),
                ),
              ),
            ],
            SizedBox(height: context.scaled(24)),
            Container(
              padding: EdgeInsets.all(context.scaled(16)),
              decoration: BoxDecoration(
                color: palette.surfaceMuted,
                borderRadius: BorderRadius.circular(context.scaled(16)),
                border: Border.all(color: palette.border),
              ),
              child: Column(
                children: [
                  _buildRow(context, label: 'Danh mục', value: category.name),
                  Divider(color: palette.border, height: context.scaled(24)),
                  _buildRow(
                    context,
                    label: 'Loại',
                    value: isExpense ? 'Chi tiêu' : 'Thu nhập',
                  ),
                  Divider(color: palette.border, height: context.scaled(24)),
                  _buildRow(context, label: 'Nguồn tiền', value: source.name),
                  Divider(color: palette.border, height: context.scaled(24)),
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
              onTap: () => Navigator.of(context).pop(false),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: context.scaled(16)),
                decoration: BoxDecoration(
                  color: palette.inputBackground,
                  borderRadius: BorderRadius.circular(context.scaled(16)),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Chỉnh sửa',
                  style: context.appText.buttonLabel.copyWith(
                    color: palette.iconMuted,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: context.scaled(12)),
          Expanded(
            child: AppBounceBuilder(
              onTap: () => Navigator.of(context).pop(true),
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
                child: Text('Lưu', style: context.appText.buttonLabel),
              ),
            ),
          ),
        ],
      ),
    );
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
              color: context.appPalette.textSecondary,
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
                    color: valueColor ?? context.appPalette.textPrimary,
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
