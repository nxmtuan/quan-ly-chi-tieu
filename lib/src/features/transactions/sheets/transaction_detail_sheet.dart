part of '../add_transaction_sheet.dart';

void showTransactionDetailSheet(
  BuildContext context, {
  required Transaction transaction,
  required Category category,
}) {
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _TransactionDetailSheet(
        transaction: transaction,
        category: category,
      );
    },
  );
}

class _TransactionDetailSheet extends StatelessWidget {
  const _TransactionDetailSheet({
    required this.transaction,
    required this.category,
  });

  final Transaction transaction;
  final Category category;

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    final color = isExpense ? const Color(0xFFFF1493) : AppColors.success;
    final sign = isExpense ? '-' : '+';
    final title = isExpense ? 'Giao dịch chi' : 'Giao dịch thu';

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
                title: title,
              ),
              SizedBox(height: context.scaled(20)),
              // 1. Icon danh mục to ở giữa
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
              
              // 2. Số tiền
              Text(
                '$sign${formatCurrency(transaction.amount)}',
                style: context.appText.amountXL.copyWith(
                  color: color,
                  fontSize: context.scaledFont(32, min: 28),
                ),
              ),
              
              // 3. Ghi chú (nếu có)
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
              
              // 4. Khung thông tin còn lại
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.scaled(20)),
                child: Container(
                  padding: EdgeInsets.all(context.scaled(16)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(context.scaled(16)),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _buildRow(
                        context,
                        label: 'Danh mục',
                        value: category.name,
                      ),
                      Divider(color: AppColors.border, height: context.scaled(24)),
                      _buildRow(
                        context,
                        label: 'Loại',
                        value: isExpense ? 'Chi tiêu' : 'Thu nhập',
                      ),
                      Divider(color: AppColors.border, height: context.scaled(24)),
                      _buildRow(
                        context,
                        label: 'Nguồn tiền',
                        value: 'Tiền mặt',
                      ),
                      Divider(color: AppColors.border, height: context.scaled(24)),
                      _buildRow(
                        context,
                        label: 'Ngày giao dịch',
                        value: formatShortDate(transaction.date),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: context.scaled(32)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.scaled(20)),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(context.scaled(16)),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: context.scaled(16)),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(context.scaled(16)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Đóng',
                            style: context.appText.buttonLabel.copyWith(
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: context.scaled(12)),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          showAddTransactionSheet(context, transaction: transaction);
                        },
                        borderRadius: BorderRadius.circular(context.scaled(16)),
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
              ),
            ],
          ),
        ),
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
                    fontSize: valueSize != null ? context.scaledFont(valueSize, min: valueSize - 2) : null,
                  ),
                ),
          ),
        ),
      ],
    );
  }
}
