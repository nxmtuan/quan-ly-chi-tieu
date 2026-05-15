import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/adaptive.dart';
import '../../core/utils/date_range.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/local_id.dart';
import '../../core/widgets/app_bounce_builder.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/app_toast.dart';
import '../../models/budget.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';

Future<Budget?> showBudgetSheet(
  BuildContext context, {
  Budget? budget,
  DateTime? initialMonth,
  bool replaceSheet = false,
}) {
  return showAppBottomSheet<Budget>(
    context: context,
    replacesCurrentSheet: replaceSheet,
    builder: (_) => _BudgetSheet(budget: budget, initialMonth: initialMonth),
  );
}

class _BudgetSheet extends ConsumerStatefulWidget {
  const _BudgetSheet({this.budget, this.initialMonth});

  final Budget? budget;
  final DateTime? initialMonth;

  @override
  ConsumerState<_BudgetSheet> createState() => _BudgetSheetState();
}

class _BudgetSheetState extends ConsumerState<_BudgetSheet> {
  late final TextEditingController _amountController;
  late final FocusNode _amountFocusNode;
  late DateTime _periodStart;
  late double _warningPercent;
  String? _selectedCategoryId;

  bool get _isEditing => widget.budget != null;

  @override
  void initState() {
    super.initState();
    final budget = widget.budget;
    final initialMonth = widget.initialMonth ?? DateTime.now();
    _selectedCategoryId = budget?.categoryId;
    _periodStart =
        budget?.periodStart ?? DateTime(initialMonth.year, initialMonth.month);
    _warningPercent = budget?.warningPercent ?? defaultBudgetWarningPercent;
    _amountController = TextEditingController(
      text: budget == null ? '' : _formatAmountInput(budget.limitAmount),
    );
    _amountFocusNode = FocusNode()..addListener(_handleFocusChanged);
  }

  void _handleFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseCategories = ref.watch(
      categoriesByTypeProvider(TransactionType.expense),
    );
    _selectedCategoryId ??= expenseCategories.firstOrNull?.id;
    final selectedMonthRange = monthDateRange(_periodStart);
    final existingTransactions = _selectedCategoryId == null
        ? const <Transaction>[]
        : ref.watch(
            transactionsQueryProvider((
              categoryId: _selectedCategoryId,
              fromDate: selectedMonthRange.start,
              limit: null,
              toDate: selectedMonthRange.end,
              type: TransactionType.expense,
            )),
          );
    final existingSpent = existingTransactions.fold<double>(
      0,
      (total, transaction) => total + transaction.amount,
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: AppSheetScaffold(
        title: _isEditing ? 'Chỉnh sửa ngân sách' : 'Tạo ngân sách',
        body: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: context.scaled(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionLabel(label: 'Danh mục chi tiêu'),
              SizedBox(height: context.scaled(10)),
              if (expenseCategories.isEmpty)
                _EmptyCategoryNotice()
              else
                _CategoryGrid(
                  categories: expenseCategories,
                  selectedCategoryId: _selectedCategoryId,
                  onSelected: (category) {
                    setState(() => _selectedCategoryId = category.id);
                  },
                ),
              SizedBox(height: context.scaled(14)),
              _BudgetAmountField(
                controller: _amountController,
                focusNode: _amountFocusNode,
                isFocused: _amountFocusNode.hasFocus,
              ),
              SizedBox(height: context.scaled(14)),
              _MonthPickerCard(
                month: _periodStart,
                onPrevious: () => setState(() {
                  _periodStart = DateTime(
                    _periodStart.year,
                    _periodStart.month - 1,
                  );
                }),
                onNext: () => setState(() {
                  _periodStart = DateTime(
                    _periodStart.year,
                    _periodStart.month + 1,
                  );
                }),
              ),
              SizedBox(height: context.scaled(14)),
              _ExistingSpendingNotice(
                transactionCount: existingTransactions.length,
                totalSpent: existingSpent,
              ),
              SizedBox(height: context.scaled(14)),
              _WarningSliderCard(
                warningPercent: _warningPercent,
                onChanged: (value) {
                  setState(() => _warningPercent = value.roundToDouble());
                },
              ),
            ],
          ),
        ),
        action: Row(
          children: [
            Expanded(
              child: AppBounceBuilder(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: context.scaled(16)),
                  decoration: BoxDecoration(
                    color: context.appPalette.surfaceMuted,
                    borderRadius: BorderRadius.circular(context.scaled(16)),
                    border: Border.all(color: context.appPalette.border),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Đóng',
                    style: context.appText.buttonLabel.copyWith(
                      color: context.appPalette.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: context.scaled(12)),
            Expanded(
              child: AppPrimaryButton(
                label: _isEditing ? 'Lưu thay đổi' : 'Tạo ngân sách',
                color: AppColors.primary,
                onTap: expenseCategories.isEmpty ? null : _save,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final categoryId = _selectedCategoryId;
    final limitAmount = _parseAmountInput(_amountController.text);

    if (categoryId == null || categoryId.isEmpty) {
      AppToast.show(
        context,
        message: 'Vui lòng chọn danh mục chi tiêu',
        type: AppToastType.error,
      );
      return;
    }

    if (limitAmount == null || limitAmount <= 0) {
      AppToast.show(
        context,
        message: 'Vui lòng nhập hạn mức ngân sách',
        type: AppToastType.error,
      );
      return;
    }

    final duplicate = ref
        .read(budgetsProvider)
        .firstWhere(
          (budget) =>
              budget.id != widget.budget?.id &&
              budget.categoryId == categoryId &&
              budget.periodStart == _periodStart,
          orElse: () => Budget(
            id: '',
            categoryId: '',
            limitAmount: 1,
            periodStart: _periodStart,
          ),
        );

    if (duplicate.id.isNotEmpty) {
      AppToast.show(
        context,
        message: 'Danh mục này đã có ngân sách trong tháng đã chọn',
        type: AppToastType.error,
      );
      return;
    }

    final existingBudget = widget.budget;
    final now = DateTime.now();
    final budget = Budget(
      id: existingBudget?.id ?? generateLocalEntityId(),
      categoryId: categoryId,
      limitAmount: limitAmount,
      periodStart: _periodStart,
      warningPercent: _warningPercent,
      createdAt: existingBudget?.createdAt ?? now,
      updatedAt: now,
    );

    if (_isEditing) {
      await ref.read(budgetsProvider.notifier).updateBudget(budget);
    } else {
      await ref.read(budgetsProvider.notifier).addBudget(budget);
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(budget);
    AppToast.show(
      context,
      message: _isEditing ? 'Đã cập nhật ngân sách' : 'Đã tạo ngân sách',
      type: AppToastType.success,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: context.appText.fieldLabel);
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<Category> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - context.scaled(16)) / 3;

        return Wrap(
          spacing: context.scaled(8),
          runSpacing: context.scaled(8),
          children: [
            for (final category in categories)
              SizedBox(
                width: itemWidth,
                child: _CategoryOption(
                  category: category,
                  selected: category.id == selectedCategoryId,
                  onTap: () => onSelected(category),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CategoryOption extends StatelessWidget {
  const _CategoryOption({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final Category category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: context.scaled(96),
        padding: EdgeInsets.symmetric(
          horizontal: context.scaled(7),
          vertical: context.scaled(9),
        ),
        decoration: BoxDecoration(
          color: selected
              ? category.color.withValues(alpha: 0.08)
              : context.appPalette.surface,
          borderRadius: BorderRadius.circular(context.scaled(16)),
          border: Border.all(
            color: selected ? category.color : context.appPalette.border,
            width: selected ? 1.2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: context.scaled(36),
              height: context.scaled(36),
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                category.iconData,
                color: category.color,
                size: context.scaled(19),
              ),
            ),
            SizedBox(height: context.scaled(8)),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.appText.captionStrong.copyWith(
                color: selected
                    ? category.color
                    : context.appPalette.textPrimary,
                fontSize: context.scaledFont(11.5, min: 10.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCategoryNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _FormCard(
      child: Text(
        'Chưa có danh mục chi tiêu để đặt ngân sách.',
        style: context.appText.body.copyWith(
          color: context.appPalette.textSecondary,
        ),
      ),
    );
  }
}

class _BudgetAmountField extends StatelessWidget {
  const _BudgetAmountField({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    return _FormCard(
      isFocused: isFocused,
      child: Row(
        children: [
          const _LeadingIcon(icon: Icons.payments_rounded),
          SizedBox(width: context.scaled(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: 'Hạn mức', required: true),
                SizedBox(height: context.scaled(5)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        keyboardType: TextInputType.number,
                        inputFormatters: const [_AmountInputFormatter()],
                        style: context.appText.fieldValue.copyWith(
                          fontSize: context.scaledFont(17, min: 16),
                        ),
                        cursorColor: AppColors.primary,
                        decoration: _fieldDecoration(context, '0'),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: context.scaled(1)),
                      child: Text('đ', style: context.appText.fieldValue),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthPickerCard extends StatelessWidget {
  const _MonthPickerCard({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _FormCard(
      child: Row(
        children: [
          const _LeadingIcon(icon: Icons.calendar_month_rounded),
          SizedBox(width: context.scaled(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: 'Tháng áp dụng'),
                SizedBox(height: context.scaled(5)),
                Text(formatMonthYear(month), style: context.appText.fieldValue),
              ],
            ),
          ),
          _SmallIconButton(icon: Icons.chevron_left_rounded, onTap: onPrevious),
          SizedBox(width: context.scaled(8)),
          _SmallIconButton(icon: Icons.chevron_right_rounded, onTap: onNext),
        ],
      ),
    );
  }
}

class _WarningSliderCard extends StatelessWidget {
  const _WarningSliderCard({
    required this.warningPercent,
    required this.onChanged,
  });

  final double warningPercent;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return _FormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _LeadingIcon(icon: Icons.notifications_active_rounded),
              SizedBox(width: context.scaled(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(label: 'Cảnh báo khi dùng đến'),
                    SizedBox(height: context.scaled(5)),
                    Text(
                      '${warningPercent.round()}% ngân sách',
                      style: context.appText.fieldValue,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.scaled(8)),
          Slider(
            value: warningPercent,
            min: 50,
            max: 100,
            divisions: 10,
            activeColor: AppColors.primary,
            inactiveColor: context.appPalette.surfaceMuted,
            label: '${warningPercent.round()}%',
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ExistingSpendingNotice extends StatelessWidget {
  const _ExistingSpendingNotice({
    required this.transactionCount,
    required this.totalSpent,
  });

  final int transactionCount;
  final double totalSpent;

  @override
  Widget build(BuildContext context) {
    final hasTransactions = transactionCount > 0;
    final color = hasTransactions
        ? AppColors.primary
        : context.appPalette.textSecondary;

    return _FormCard(
      child: Row(
        children: [
          Container(
            width: context.scaled(38),
            height: context.scaled(38),
            decoration: BoxDecoration(
              color: color.withValues(alpha: hasTransactions ? 0.1 : 0.08),
              borderRadius: BorderRadius.circular(context.scaled(14)),
            ),
            child: Icon(
              hasTransactions
                  ? Icons.playlist_add_check_rounded
                  : Icons.receipt_long_rounded,
              color: color,
              size: context.scaled(19),
            ),
          ),
          SizedBox(width: context.scaled(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasTransactions
                      ? 'Đã có chi tiêu trong tháng'
                      : 'Chưa có chi tiêu',
                  style: context.appText.fieldLabel.copyWith(
                    color: context.appPalette.iconMuted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: context.scaled(5)),
                Text(
                  hasTransactions
                      ? '$transactionCount giao dịch, ${formatCurrency(totalSpent)} sẽ được tính vào ngân sách'
                      : 'Ngân sách sẽ tự cập nhật khi có giao dịch mới',
                  style: context.appText.caption.copyWith(
                    color: context.appPalette.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  const _SmallIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onTap,
      child: Container(
        width: context.scaled(34),
        height: context.scaled(34),
        decoration: BoxDecoration(
          color: context.appPalette.surfaceMuted,
          borderRadius: BorderRadius.circular(context.scaled(12)),
          border: Border.all(color: context.appPalette.border),
        ),
        child: Icon(
          icon,
          color: context.appPalette.textPrimary,
          size: context.scaled(20),
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child, this.isFocused = false});

  final Widget child;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: EdgeInsets.symmetric(
        horizontal: context.scaled(14),
        vertical: context.scaled(12),
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(context.scaled(18)),
        border: Border.all(
          color: isFocused ? AppColors.primary : palette.border,
          width: isFocused ? 1.3 : 1,
        ),
      ),
      child: child,
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.scaled(38),
      height: context.scaled(38),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.scaled(14)),
      ),
      child: Icon(icon, color: AppColors.primary, size: context.scaled(19)),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, this.required = false});

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: label,
        children: [
          if (required)
            TextSpan(
              text: '*',
              style: context.appText.fieldLabel.copyWith(
                color: AppColors.primary,
              ),
            ),
        ],
      ),
      style: context.appText.fieldLabel.copyWith(
        color: context.appPalette.iconMuted,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

InputDecoration _fieldDecoration(BuildContext context, String hintText) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: context.appText.fieldValue.copyWith(
      color: context.appPalette.textSecondary.withValues(alpha: 0.65),
    ),
    filled: false,
    fillColor: Colors.transparent,
    isDense: true,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
    contentPadding: EdgeInsets.zero,
  );
}

String _formatAmountInput(num amount) {
  return _formatThousands(amount.round().toString());
}

double? _parseAmountInput(String input) {
  final rawDigits = input.replaceAll('.', '').trim();
  if (rawDigits.isEmpty) {
    return null;
  }

  return double.tryParse(rawDigits);
}

String _formatThousands(String digits) {
  if (digits.isEmpty) {
    return '';
  }

  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    final remaining = digits.length - index;
    buffer.write(digits[index]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write('.');
    }
  }

  return buffer.toString();
}

class _AmountInputFormatter extends TextInputFormatter {
  const _AmountInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final formatted = _formatThousands(digitsOnly);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
