part of '../recurring_screen.dart';

void showRecurringAddSheet(
  BuildContext context, {
  required RecurringItemKind kind,
  RecurringItem? item,
  bool replaceSheet = false,
}) {
  showAppBottomSheet<void>(
    context: context,
    replacesCurrentSheet: replaceSheet,
    builder: (context) => _RecurringAddSheet(kind: kind, item: item),
  );
}

class _RecurringAddSheet extends ConsumerStatefulWidget {
  const _RecurringAddSheet({required this.kind, this.item});

  final RecurringItemKind kind;
  final RecurringItem? item;

  @override
  ConsumerState<_RecurringAddSheet> createState() => _RecurringAddSheetState();
}

class _RecurringAddSheetState extends ConsumerState<_RecurringAddSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late final FocusNode _amountFocusNode;
  late final FocusNode _noteFocusNode;
  TransactionType _type = TransactionType.expense;
  DateTime _startDate = DateTime.now();
  RecurrenceFrequency _frequency = RecurrenceFrequency.monthly;
  String? _categoryId;
  String? _sourceId;
  String? _promotedCategoryId;

  @override
  void initState() {
    super.initState();
    _amountFocusNode = FocusNode()..addListener(_handleFocusChanged);
    _noteFocusNode = FocusNode()..addListener(_handleFocusChanged);

    final item = widget.item;
    if (item != null) {
      _amountController.text = formatAmountInput(item.amount);
      _noteController.text = item.kind == RecurringItemKind.transaction
          ? item.note ?? ''
          : item.reminderText ?? '';
      _type = item.type;
      _startDate = item.startDate;
      _frequency = item.frequency;
      _categoryId = item.categoryId;
      _sourceId = item.sourceId;
      _promotedCategoryId = item.categoryId;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _amountFocusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _noteFocusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesByTypeProvider(_type));
    final moneySources = ref.watch(moneySourcesProvider);
    final actionColor = _type == TransactionType.expense
        ? const Color(0xFFFF1493)
        : AppColors.success;
    final isEditing = widget.item != null;
    if (_sourceId == null && moneySources.isNotEmpty) {
      _sourceId = moneySources.first.id;
    }
    final selectedMoneySource = _sourceId == null
        ? null
        : moneySources.where((source) => source.id == _sourceId).firstOrNull;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: AppSheetContainer(
        child: Column(
          children: [
            AppSheetHeader(
              title: isEditing
                  ? (widget.kind == RecurringItemKind.transaction
                        ? 'Sửa giao dịch định kỳ'
                        : 'Sửa nhắc nhở định kỳ')
                  : (widget.kind == RecurringItemKind.transaction
                        ? 'Thêm giao dịch định kỳ'
                        : 'Thêm nhắc nhở định kỳ'),
              subtitle: widget.kind == RecurringItemKind.transaction
                  ? 'Tự động thêm giao dịch theo chu kỳ'
                  : 'Nhận thông báo nhắc nhở theo chu kỳ',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  context.scaled(16),
                  0,
                  context.scaled(16),
                  context.scaled(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RecurringTypeTabs(
                      type: _type,
                      onChanged: (type) {
                        setState(() {
                          _type = type;
                          _categoryId = null;
                          _promotedCategoryId = null;
                        });
                      },
                    ),
                    SizedBox(height: context.scaled(12)),
                    _RecurringNoteCard(
                      controller: _noteController,
                      label: widget.kind == RecurringItemKind.transaction
                          ? 'Ghi chú'
                          : 'Lời nhắc',
                      icon: widget.kind == RecurringItemKind.transaction
                          ? Icons.notes_rounded
                          : Icons.notifications_active_rounded,
                      actionColor: actionColor,
                      focusNode: _noteFocusNode,
                      isFocused: _noteFocusNode.hasFocus,
                    ),
                    SizedBox(height: context.scaled(10)),
                    _RecurringAmountCard(
                      controller: _amountController,
                      actionColor: actionColor,
                      focusNode: _amountFocusNode,
                      isFocused: _amountFocusNode.hasFocus,
                    ),
                    SizedBox(height: context.scaled(10)),
                    _RecurringScheduleCard(
                      date: _startDate,
                      frequency: _frequency,
                      actionColor: actionColor,
                      onPickDate: _pickStartDate,
                      onChanged: (frequency) {
                        setState(() => _frequency = frequency);
                      },
                    ),
                    SizedBox(height: context.scaled(10)),
                    _RecurringCategoryPicker(
                      categories: categories,
                      selectedCategoryId: _categoryId,
                      actionColor: actionColor,
                      onSelected: (category) {
                        setState(() => _categoryId = category.id);
                      },
                      onShowAll: () => _showAllCategories(categories),
                      promotedCategoryId: _promotedCategoryId,
                    ),
                    SizedBox(height: context.scaled(10)),
                    _RecurringMoneySourcePicker(
                      selectedSource: selectedMoneySource,
                      actionColor: actionColor,
                      onShowAll: () => _showAllMoneySources(moneySources),
                    ),
                  ],
                ),
              ),
            ),
            AppSheetFooter(
              child: Row(
                children: [
                  Expanded(
                    child: AppBounceBuilder(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: context.scaled(16),
                        ),
                        decoration: BoxDecoration(
                          color: context.appPalette.surfaceMuted,
                          borderRadius: BorderRadius.circular(
                            context.scaled(16),
                          ),
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
                      label: isEditing
                          ? 'Cập nhật định kỳ'
                          : (widget.kind == RecurringItemKind.transaction
                                ? 'Thêm giao dịch'
                                : 'Thêm nhắc nhở'),
                      color: actionColor,
                      onTap: _save,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final selectedDate = await showTransactionCalendarSheet(
      context,
      initialDate: _startDate,
      title: 'Chọn ngày bắt đầu',
    );
    if (selectedDate != null && mounted) {
      setState(() => _startDate = selectedDate);
    }
  }

  Future<void> _showAllCategories(List<Category> categories) async {
    final selectedCategory = await showAllCategoriesSheet(
      context,
      categories: categories,
      initialSelectedCategoryId: _categoryId,
      transactionType: _type,
      actionColor: _type == TransactionType.expense
          ? const Color(0xFFFF1493)
          : AppColors.success,
    );

    if (selectedCategory != null && mounted) {
      setState(() {
        _categoryId = selectedCategory.id;
        _promotedCategoryId = selectedCategory.id;
      });
    }
  }

  Future<void> _showAllMoneySources(List<MoneySource> moneySources) async {
    final selectedSource = await showAllMoneySourcesSheet(
      context,
      moneySources: moneySources,
      initialSelectedSourceId: _sourceId,
      actionColor: _type == TransactionType.expense
          ? const Color(0xFFFF1493)
          : AppColors.success,
    );

    if (selectedSource != null && mounted) {
      setState(() => _sourceId = selectedSource.id);
    }
  }

  Future<void> _save() async {
    final amount = parseAmountInput(_amountController.text);
    if (amount == null || amount <= 0 || _sourceId == null) {
      AppToast.show(
        context,
        message: 'Vui lòng nhập đầy đủ thông tin',
        type: AppToastType.error,
      );
      return;
    }

    final existing = widget.item;
    final normalizedStart = widget.kind == RecurringItemKind.transaction
        ? normalizeRecurringTransactionDate(_startDate)
        : normalizeRecurringDate(_startDate);
    final nextRunAt =
        existing != null &&
            existing.frequency == _frequency &&
            existing.startDate == normalizedStart
        ? existing.nextRunAt
        : normalizedStart;
    final effectiveCategoryId =
        _categoryId ?? uncategorizedCategoryIdFor(_type);
    final item = RecurringItem(
      id: existing?.id ?? generateLocalEntityId(),
      kind: widget.kind,
      type: _type,
      amount: amount,
      categoryId: effectiveCategoryId,
      sourceId: _sourceId!,
      startDate: normalizedStart,
      frequency: _frequency,
      nextRunAt: nextRunAt,
      createdAt: existing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      note: widget.kind == RecurringItemKind.transaction
          ? _noteController.text.trim()
          : null,
      reminderText: widget.kind == RecurringItemKind.reminder
          ? _noteController.text.trim()
          : null,
      isActive: existing?.isActive ?? true,
      isDeleted: existing?.isDeleted ?? false,
      completedOccurrenceKeys: existing?.completedOccurrenceKeys ?? const [],
      preNotifiedOccurrenceKeys:
          existing?.preNotifiedOccurrenceKeys ?? const [],
      dueNotifiedOccurrenceKeys:
          existing?.dueNotifiedOccurrenceKeys ?? const [],
    );

    if (existing == null) {
      await ref.read(recurringItemsProvider.notifier).addItem(item);
    } else {
      await ref.read(recurringItemsProvider.notifier).updateItem(item);
    }
    if (mounted) {
      Navigator.of(context).pop();
      AppToast.show(
        context,
        message:
            '${existing == null ? 'Đã thêm' : 'Đã cập nhật'} ${widget.kind == RecurringItemKind.transaction ? 'giao dịch' : 'nhắc nhở'} định kỳ',
        type: AppToastType.success,
      );
    }
  }
}

void showRecurringDetailSheet(
  BuildContext context, {
  required RecurringItem item,
}) {
  showAppBottomSheet<void>(
    context: context,
    builder: (context) => _RecurringDetailSheet(item: item),
  );
}

class _RecurringDetailSheet extends ConsumerWidget {
  const _RecurringDetailSheet({required this.item});

  final RecurringItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.appPalette;
    final isExpense = item.type == TransactionType.expense;
    final color = isExpense ? const Color(0xFFFF1493) : AppColors.success;
    final sign = isExpense ? '-' : '+';
    final category =
        ref.watch(categoryByIdProvider(item.categoryId)) ??
        Category(
          id: item.categoryId,
          name: 'Khác',
          iconData: Icons.category_rounded,
          colorHex: AppColors.textSecondary.toARGB32(),
          type: item.type,
        );
    final source =
        ref.watch(moneySourceByIdProvider(item.sourceId)) ??
        defaultMoneySources.first;
    final title = item.kind == RecurringItemKind.transaction
        ? 'Giao dịch định kỳ'
        : 'Nhắc nhở định kỳ';
    final text = item.kind == RecurringItemKind.transaction
        ? item.note
        : item.reminderText;

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
              '$sign${formatCurrency(item.amount)}',
              style: context.appText.amountXL.copyWith(
                color: color,
                fontSize: context.scaledFont(32, min: 28),
              ),
            ),
            if (text != null && text.trim().isNotEmpty) ...[
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
                  text.trim(),
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
                    label: 'Ngày bắt đầu',
                    value: formatShortDate(item.startDate),
                  ),
                  Divider(color: palette.border, height: context.scaled(24)),
                  _buildRow(
                    context,
                    label: 'Tần suất',
                    value: item.frequency.label,
                  ),
                  Divider(color: palette.border, height: context.scaled(24)),
                  _buildRow(
                    context,
                    label: 'Kỳ tiếp theo',
                    value: formatShortDate(item.nextRunAt),
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
                  color: palette.dangerSoft,
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
                showRecurringAddSheet(
                  context,
                  kind: item.kind,
                  item: item,
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
                child: Text('Chỉnh sửa', style: context.appText.buttonLabel),
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
      title: item.kind == RecurringItemKind.transaction
          ? 'Xóa giao dịch định kỳ'
          : 'Xóa nhắc nhở định kỳ',
      message: 'Bạn có chắc muốn xóa mục định kỳ này không?',
      confirmText: 'Xóa',
      confirmTextColor: const Color(0xFFDC2626),
      confirmBackgroundColor: context.appPalette.dangerSoft,
    );

    if (confirmed == true && context.mounted) {
      await ref.read(recurringItemsProvider.notifier).deleteItem(item.id);
      if (context.mounted) {
        AppToast.show(
          context,
          message: 'Đã xóa mục định kỳ',
          type: AppToastType.success,
        );
        Navigator.of(context).pop();
      }
    }
  }

  Widget _buildRow(
    BuildContext context, {
    required String label,
    required String value,
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
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: context.appText.bodyStrong,
            ),
          ),
        ),
      ],
    );
  }
}

class _RecurringAmountInputFormatter extends TextInputFormatter {
  const _RecurringAmountInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final formatted = _formatRecurringAmountInput(digitsOnly);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

String _formatRecurringAmountInput(String digits) {
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

class _RecurringTypeTabs extends StatelessWidget {
  const _RecurringTypeTabs({required this.type, required this.onChanged});

  final TransactionType type;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      height: context.scaled(48),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(context.scaled(14)),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(
              alpha: context.isDarkMode ? 0.22 : 0.06,
            ),
            blurRadius: context.scaled(9),
            offset: Offset(0, context.scaled(3)),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _RecurringTypeButton(
              label: 'Chi tiêu',
              selected: type == TransactionType.expense,
              color: const Color(0xFFFF1493),
              icon: Icons.trending_up_rounded,
              onTap: () => onChanged(TransactionType.expense),
            ),
          ),
          Expanded(
            child: _RecurringTypeButton(
              label: 'Thu nhập',
              selected: type == TransactionType.income,
              color: AppColors.success,
              icon: Icons.trending_down_rounded,
              onTap: () => onChanged(TransactionType.income),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecurringTypeButton extends StatelessWidget {
  const _RecurringTypeButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return AppBounceBuilder(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: context.scaled(8)),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.06) : Colors.transparent,
          borderRadius: BorderRadius.circular(context.scaled(14)),
          border: selected
              ? Border.all(color: color.withValues(alpha: 0.24))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: context.scaled(26),
              height: context.scaled(26),
              decoration: BoxDecoration(
                color: palette.surfaceElevated,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                icon,
                color: selected ? color : palette.iconMuted,
                size: context.scaled(16),
              ),
            ),
            SizedBox(width: context.scaled(8)),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.appText.captionStrong.copyWith(
                  color: selected ? color : palette.iconMuted,
                  fontSize: context.scaledFont(12, min: 12),
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedContainer extends StatelessWidget {
  const _SegmentedContainer({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.scaled(4)),
      decoration: BoxDecoration(
        color: context.appPalette.surface,
        borderRadius: BorderRadius.circular(context.scaled(15)),
        border: Border.all(color: context.appPalette.border),
      ),
      child: Row(children: children),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: context.scaled(10)),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(context.scaled(12)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.appText.captionStrong.copyWith(
            color: selected ? color : context.appPalette.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _RecurringFormCard extends StatelessWidget {
  const _RecurringFormCard({
    required this.child,
    this.padding,
    this.borderColor,
    this.borderWidth,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final double? borderWidth;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(context.scaled(14)),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(context.scaled(14)),
        border: Border.all(
          color: borderColor ?? palette.border,
          width: borderWidth ?? 1,
        ),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(
              alpha: context.isDarkMode ? 0.18 : 0.025,
            ),
            blurRadius: context.scaled(6),
            offset: Offset(0, context.scaled(2)),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RecurringRequiredLabel extends StatelessWidget {
  const _RecurringRequiredLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: label,
        children: [
          TextSpan(
            text: '*',
            style: context.appText.fieldLabel.copyWith(color: color),
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

class _RecurringLeadingIcon extends StatelessWidget {
  const _RecurringLeadingIcon({
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.scaled(38),
      height: context.scaled(38),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(context.scaled(15)),
      ),
      child: Icon(icon, color: color, size: context.scaled(20)),
    );
  }
}

class _RecurringNoteCard extends StatelessWidget {
  const _RecurringNoteCard({
    required this.controller,
    required this.label,
    required this.icon,
    required this.actionColor,
    required this.focusNode,
    required this.isFocused,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color actionColor;
  final FocusNode focusNode;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    return _RecurringFormCard(
      borderColor: isFocused ? actionColor : null,
      borderWidth: isFocused ? 1.4 : 1,
      padding: EdgeInsets.symmetric(
        horizontal: context.scaled(14),
        vertical: context.scaled(10),
      ),
      child: Row(
        children: [
          _RecurringLeadingIcon(
            icon: icon,
            color: actionColor,
            backgroundColor: actionColor.withValues(alpha: 0.1),
          ),
          SizedBox(width: context.scaled(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: context.appText.fieldLabel.copyWith(
                    color: context.appPalette.iconMuted,
                  ),
                ),
                SizedBox(height: context.scaled(4)),
                TextField(
                  controller: controller,
                  focusNode: focusNode,
                  textCapitalization: TextCapitalization.sentences,
                  style: context.appText.fieldValue,
                  decoration: InputDecoration(
                    hintText: 'Nhập $label',
                    hintStyle: context.appText.fieldValue.copyWith(
                      color: context.appPalette.textSecondary.withValues(
                        alpha: 0.65,
                      ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecurringAmountCard extends StatelessWidget {
  const _RecurringAmountCard({
    required this.controller,
    required this.actionColor,
    required this.focusNode,
    required this.isFocused,
  });

  final TextEditingController controller;
  final Color actionColor;
  final FocusNode focusNode;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    return _RecurringFormCard(
      borderColor: isFocused ? actionColor : null,
      borderWidth: isFocused ? 1.4 : 1,
      padding: EdgeInsets.fromLTRB(
        context.scaled(14),
        context.scaled(12),
        context.scaled(14),
        context.scaled(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RecurringRequiredLabel(label: 'Số tiền', color: actionColor),
          SizedBox(height: context.scaled(6)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: const [_RecurringAmountInputFormatter()],
                  style: context.appText.amountXL.copyWith(
                    fontSize: context.scaledFont(28, min: 24),
                  ),
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

class _RecurringScheduleCard extends StatelessWidget {
  const _RecurringScheduleCard({
    required this.date,
    required this.frequency,
    required this.actionColor,
    required this.onPickDate,
    required this.onChanged,
  });

  final DateTime date;
  final RecurrenceFrequency frequency;
  final Color actionColor;
  final VoidCallback onPickDate;
  final ValueChanged<RecurrenceFrequency> onChanged;

  @override
  Widget build(BuildContext context) {
    return _RecurringFormCard(
      padding: EdgeInsets.fromLTRB(
        context.scaled(14),
        context.scaled(12),
        context.scaled(14),
        context.scaled(12),
      ),
      child: Column(
        children: [
          AppBounceBuilder(
            onTap: onPickDate,
            child: Row(
              children: [
                _RecurringLeadingIcon(
                  icon: Icons.calendar_month_rounded,
                  color: actionColor,
                  backgroundColor: actionColor.withValues(alpha: 0.1),
                ),
                SizedBox(width: context.scaled(10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RecurringRequiredLabel(
                        label: 'Ngày bắt đầu',
                        color: actionColor,
                      ),
                      SizedBox(height: context.scaled(6)),
                      Text(
                        formatLongDate(date),
                        style: context.appText.fieldValue,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.appPalette.iconMuted,
                  size: context.scaled(18),
                ),
              ],
            ),
          ),
          SizedBox(height: context.scaled(12)),
          _SegmentedContainer(
            children: [
              for (final item in RecurrenceFrequency.values)
                Expanded(
                  child: _SegmentButton(
                    label: item.label,
                    selected: frequency == item,
                    color: actionColor,
                    onTap: () => onChanged(item),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecurringCategoryPicker extends StatelessWidget {
  const _RecurringCategoryPicker({
    required this.categories,
    required this.selectedCategoryId,
    required this.actionColor,
    required this.onSelected,
    required this.onShowAll,
    required this.promotedCategoryId,
  });

  final List<Category> categories;
  final String? selectedCategoryId;
  final Color actionColor;
  final ValueChanged<Category> onSelected;
  final VoidCallback onShowAll;
  final String? promotedCategoryId;

  @override
  Widget build(BuildContext context) {
    final orderedCategories = _orderedCategories();
    final visibleCategories = orderedCategories.take(3).toList();

    return _RecurringFormCard(
      padding: EdgeInsets.fromLTRB(
        context.scaled(14),
        context.scaled(12),
        context.scaled(14),
        context.scaled(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RecurringRequiredLabel(label: 'Danh mục', color: actionColor),
          SizedBox(height: context.scaled(10)),
          if (categories.isEmpty)
            Text(
              'Chưa có danh mục',
              style: context.appText.bodyStrong.copyWith(
                color: context.appPalette.textSecondary,
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth =
                    (constraints.maxWidth - context.scaled(24)) / 4;

                return Wrap(
                  spacing: context.scaled(8),
                  runSpacing: context.scaled(8),
                  children: [
                    for (final category in visibleCategories)
                      SizedBox(
                        width: itemWidth,
                        child: _RecurringCategoryTile(
                          category: category,
                          selected: category.id == selectedCategoryId,
                          actionColor: actionColor,
                          onTap: () => onSelected(category),
                        ),
                      ),
                    SizedBox(
                      width: itemWidth,
                      child: _MoreRecurringTile(
                        height: context.scaled(110),
                        onTap: onShowAll,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
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

class _RecurringCategoryTile extends StatelessWidget {
  const _RecurringCategoryTile({
    required this.category,
    required this.selected,
    required this.actionColor,
    required this.onTap,
  });

  final Category category;
  final bool selected;
  final Color actionColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onTap,
      child: SizedBox(
        height: context.scaled(110),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.fromLTRB(
            context.scaled(6),
            context.scaled(10),
            context.scaled(6),
            context.scaled(8),
          ),
          decoration: BoxDecoration(
            color: selected
                ? actionColor.withValues(alpha: 0.045)
                : context.appPalette.surface,
            borderRadius: BorderRadius.circular(context.scaled(14)),
            border: Border.all(
              color: selected ? actionColor : context.appPalette.border,
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
                  color: category.color.withValues(alpha: 0.1),
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
                      ? actionColor
                      : context.appPalette.textPrimary,
                  fontSize: context.scaledFont(12, min: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecurringMoneySourcePicker extends StatelessWidget {
  const _RecurringMoneySourcePicker({
    required this.selectedSource,
    required this.actionColor,
    required this.onShowAll,
  });

  final MoneySource? selectedSource;
  final Color actionColor;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onShowAll,
      child: _RecurringFormCard(
        padding: EdgeInsets.symmetric(
          horizontal: context.scaled(14),
          vertical: context.scaled(10),
        ),
        child: Row(
          children: [
            _RecurringLeadingIcon(
              icon:
                  selectedSource?.iconData ??
                  Icons.account_balance_wallet_rounded,
              color: AppColors.primary,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            ),
            SizedBox(width: context.scaled(10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RecurringRequiredLabel(
                    label: 'Nguồn tiền',
                    color: actionColor,
                  ),
                  SizedBox(height: context.scaled(6)),
                  Text(
                    selectedSource?.name ?? 'Chọn nguồn tiền',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.appText.fieldValue.copyWith(
                      color: selectedSource == null
                          ? context.appPalette.textSecondary
                          : context.appPalette.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: context.appPalette.iconMuted,
              size: context.scaled(18),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreRecurringTile extends StatelessWidget {
  const _MoreRecurringTile({required this.height, required this.onTap});

  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onTap,
      child: Container(
        height: height,
        padding: EdgeInsets.fromLTRB(
          context.scaled(6),
          context.scaled(10),
          context.scaled(6),
          context.scaled(8),
        ),
        decoration: BoxDecoration(
          color: context.appPalette.surfaceMuted,
          borderRadius: BorderRadius.circular(context.scaled(14)),
          border: Border.all(color: context.appPalette.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MoreRecurringIcon(),
            SizedBox(height: context.scaled(10)),
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

class _MoreRecurringIcon extends StatelessWidget {
  const _MoreRecurringIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
