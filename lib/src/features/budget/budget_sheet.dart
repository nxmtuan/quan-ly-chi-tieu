import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/adaptive.dart';
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
import '../transactions/add_transaction_sheet.dart';

Future<Budget?> showBudgetSheet(
  BuildContext context, {
  Budget? budget,
  Budget? templateBudget,
  bool replaceSheet = false,
}) {
  return showAppBottomSheet<Budget>(
    context: context,
    replacesCurrentSheet: replaceSheet,
    builder: (_) =>
        _BudgetSheet(budget: budget, templateBudget: templateBudget),
  );
}

class _BudgetSheet extends ConsumerStatefulWidget {
  const _BudgetSheet({this.budget, this.templateBudget});

  final Budget? budget;
  final Budget? templateBudget;

  @override
  ConsumerState<_BudgetSheet> createState() => _BudgetSheetState();
}

class _BudgetSheetState extends ConsumerState<_BudgetSheet> {
  late final TextEditingController _amountController;
  late final FocusNode _amountFocusNode;
  late DateTime _periodStart;
  late double _warningPercent;
  String? _selectedCategoryId;
  String? _promotedCategoryId;

  bool get _isEditing => widget.budget != null;

  @override
  void initState() {
    super.initState();
    final budget = widget.budget;
    final templateBudget = widget.templateBudget;
    final initialMonth = _isEditing
        ? budget!.periodStart
        : _currentMonth(DateTime.now());
    _selectedCategoryId = budget?.categoryId ?? templateBudget?.categoryId;
    _promotedCategoryId = _selectedCategoryId;
    _periodStart = _currentMonth(initialMonth);
    _warningPercent =
        budget?.warningPercent ??
        templateBudget?.warningPercent ??
        defaultBudgetWarningPercent;
    _amountController = TextEditingController(
      text: budget == null && templateBudget == null
          ? ''
          : _formatAmountInput((budget ?? templateBudget)!.limitAmount),
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
    final usedCategoryIds = {
      for (final budget in ref.watch(budgetsForMonthProvider(_periodStart)))
        if (budget.id != widget.budget?.id) budget.categoryId,
    };
    final selectableCategories = [
      for (final category in expenseCategories)
        if (!usedCategoryIds.contains(category.id)) category,
    ];

    if (_selectedCategoryId == null ||
        usedCategoryIds.contains(_selectedCategoryId)) {
      _selectedCategoryId = selectableCategories.firstOrNull?.id;
      _promotedCategoryId = _selectedCategoryId;
    }
    final canSave = _isEditing
        ? expenseCategories.isNotEmpty
        : selectableCategories.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: AppSheetScaffold(
        title:
            '${_isEditing ? 'Sửa ngân sách' : 'Tạo ngân sách'} ${_lowerMonthLabel(_periodStart)}',
        body: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: context.scaled(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BudgetAmountField(
                controller: _amountController,
                focusNode: _amountFocusNode,
                isFocused: _amountFocusNode.hasFocus,
              ),
              SizedBox(height: context.scaled(14)),
              _FormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel(label: 'Danh mục chi tiêu'),
                    SizedBox(height: context.scaled(10)),
                    if (expenseCategories.isEmpty)
                      const _EmptyCategoryNotice()
                    else
                      _BudgetCategoryPicker(
                        categories: expenseCategories,
                        selectedCategoryId: _selectedCategoryId,
                        promotedCategoryId: _promotedCategoryId,
                        disabledCategoryIds: usedCategoryIds,
                        onSelected: (category) {
                          if (usedCategoryIds.contains(category.id)) {
                            return;
                          }
                          setState(() {
                            _selectedCategoryId = category.id;
                            _promotedCategoryId = category.id;
                          });
                        },
                        onShowAll: () => _showAllCategories(
                          expenseCategories,
                          disabledCategoryIds: usedCategoryIds,
                        ),
                      ),
                  ],
                ),
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
                onTap: canSave ? _save : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAllCategories(
    List<Category> categories, {
    required Set<String> disabledCategoryIds,
  }) async {
    final selectedCategory = await showAllCategoriesSheet(
      context,
      categories: categories,
      initialSelectedCategoryId: _selectedCategoryId,
      transactionType: TransactionType.expense,
      actionColor: AppColors.primary,
      disabledCategoryIds: disabledCategoryIds,
    );

    if (selectedCategory != null && mounted) {
      setState(() {
        _selectedCategoryId = selectedCategory.id;
        _promotedCategoryId = selectedCategory.id;
      });
    }
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

class _BudgetCategoryPicker extends StatelessWidget {
  const _BudgetCategoryPicker({
    required this.categories,
    required this.selectedCategoryId,
    required this.promotedCategoryId,
    required this.disabledCategoryIds,
    required this.onSelected,
    required this.onShowAll,
  });

  final List<Category> categories;
  final String? selectedCategoryId;
  final String? promotedCategoryId;
  final Set<String> disabledCategoryIds;
  final ValueChanged<Category> onSelected;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final orderedCategories = _orderedCategories();
    final visibleCategories = orderedCategories.take(3).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - context.scaled(24)) / 4;

        return Wrap(
          spacing: context.scaled(8),
          runSpacing: context.scaled(8),
          children: [
            for (final category in visibleCategories)
              SizedBox(
                width: itemWidth,
                child: _CategoryOption(
                  category: category,
                  selected: category.id == selectedCategoryId,
                  disabled: disabledCategoryIds.contains(category.id),
                  actionColor: AppColors.primary,
                  onTap: () => onSelected(category),
                ),
              ),
            SizedBox(
              width: itemWidth,
              child: _MoreCategoriesOption(onTap: onShowAll),
            ),
          ],
        );
      },
    );
  }

  List<Category> _orderedCategories() {
    if (promotedCategoryId == null) {
      return categories;
    }

    final selectedCategory = categories
        .where((category) => category.id == promotedCategoryId)
        .firstOrNull;

    if (selectedCategory == null) {
      return categories;
    }

    return [
      selectedCategory,
      for (final category in categories)
        if (category.id != selectedCategory.id) category,
    ];
  }
}

class _CategoryOption extends StatelessWidget {
  const _CategoryOption({
    required this.category,
    required this.selected,
    required this.disabled,
    required this.actionColor,
    required this.onTap,
  });

  final Category category;
  final bool selected;
  final bool disabled;
  final Color actionColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: context.scaled(104),
        padding: EdgeInsets.symmetric(
          horizontal: context.scaled(6),
          vertical: context.scaled(10),
        ),
        decoration: BoxDecoration(
          color: disabled
              ? context.appPalette.surfaceMuted
              : selected
              ? actionColor.withValues(alpha: 0.045)
              : context.appPalette.surface,
          borderRadius: BorderRadius.circular(context.scaled(10)),
          border: Border.all(
            color: disabled
                ? context.appPalette.border.withValues(alpha: 0.7)
                : selected
                ? actionColor
                : context.appPalette.border,
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
                color: disabled
                    ? context.appPalette.textSecondary.withValues(alpha: 0.45)
                    : category.color,
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
                color: disabled
                    ? context.appPalette.textSecondary.withValues(alpha: 0.5)
                    : selected
                    ? actionColor
                    : context.appPalette.textPrimary,
                fontSize: context.scaledFont(12, min: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreCategoriesOption extends StatelessWidget {
  const _MoreCategoriesOption({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onTap,
      child: Container(
        height: context.scaled(104),
        padding: EdgeInsets.symmetric(
          horizontal: context.scaled(6),
          vertical: context.scaled(10),
        ),
        decoration: BoxDecoration(
          color: context.appPalette.surfaceMuted,
          borderRadius: BorderRadius.circular(context.scaled(10)),
          border: Border.all(color: context.appPalette.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: context.scaled(36),
              height: context.scaled(36),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                Icons.more_horiz_rounded,
                color: AppColors.primary,
                size: context.scaled(20),
              ),
            ),
            SizedBox(height: context.scaled(9)),
            Text(
              'Khác',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.appText.captionStrong.copyWith(
                color: context.appPalette.textPrimary,
                fontSize: context.scaledFont(12, min: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCategoryNotice extends StatelessWidget {
  const _EmptyCategoryNotice();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Chưa có danh mục chi tiêu để đặt ngân sách.',
      style: context.appText.body.copyWith(
        color: context.appPalette.textSecondary,
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
      padding: EdgeInsets.fromLTRB(
        context.scaled(14),
        context.scaled(12),
        context.scaled(14),
        context.scaled(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(label: 'Hạn mức', required: true),
          SizedBox(height: context.scaled(6)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: const [_AmountInputFormatter()],
                  style: context.appText.amountXL.copyWith(
                    fontSize: context.scaledFont(28, min: 24),
                  ),
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: context.appText.amountXL.copyWith(
                      color: context.appPalette.textSecondary.withValues(
                        alpha: 0.55,
                      ),
                      fontSize: context.scaledFont(28, min: 24),
                    ),
                    filled: false,
                    fillColor: Colors.transparent,
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              SizedBox(width: context.scaled(8)),
              Padding(
                padding: EdgeInsets.only(bottom: context.scaled(3)),
                child: Text(
                  'đ',
                  style: context.appText.amountXL.copyWith(
                    fontSize: context.scaledFont(28, min: 24),
                  ),
                ),
              ),
            ],
          ),
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

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child, this.isFocused = false, this.padding});

  final Widget child;
  final bool isFocused;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding:
          padding ??
          EdgeInsets.symmetric(
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

DateTime _currentMonth([DateTime? date]) {
  final value = date ?? DateTime.now();
  return DateTime(value.year, value.month);
}

String _lowerMonthLabel(DateTime month) {
  return formatMonthYear(month).replaceFirst('Tháng', 'tháng');
}
