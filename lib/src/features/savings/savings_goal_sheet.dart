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
import '../../core/widgets/app_table_calendar.dart';
import '../../core/widgets/app_toast.dart';
import '../../models/savings_goal.dart';
import '../../providers/savings_goal_provider.dart';

Future<SavingsGoal?> showSavingsGoalSheet(
  BuildContext context, {
  SavingsGoal? goal,
  bool replaceSheet = false,
}) {
  return showAppBottomSheet<SavingsGoal>(
    context: context,
    replacesCurrentSheet: replaceSheet,
    builder: (_) => _SavingsGoalSheet(goal: goal),
  );
}

class _SavingsGoalSheet extends ConsumerStatefulWidget {
  const _SavingsGoalSheet({this.goal});

  final SavingsGoal? goal;

  @override
  ConsumerState<_SavingsGoalSheet> createState() => _SavingsGoalSheetState();
}

class _SavingsGoalSheetState extends ConsumerState<_SavingsGoalSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _targetController;
  late final TextEditingController _noteController;
  late final FocusNode _titleFocusNode;
  late final FocusNode _targetFocusNode;
  late final FocusNode _noteFocusNode;
  late DateTime _startDate;
  DateTime? _deadline;

  bool get _isEditing => widget.goal != null;

  @override
  void initState() {
    super.initState();
    final goal = widget.goal;
    _titleController = TextEditingController(text: goal?.title ?? '');
    _targetController = TextEditingController(
      text: goal == null ? '' : _formatAmountInput(goal.targetAmount),
    );
    _noteController = TextEditingController(text: goal?.note ?? '');
    _startDate = goal?.startDate ?? _today();
    _deadline = goal?.deadline;
    _titleFocusNode = FocusNode()..addListener(_handleFocusChanged);
    _targetFocusNode = FocusNode()..addListener(_handleFocusChanged);
    _noteFocusNode = FocusNode()..addListener(_handleFocusChanged);
  }

  void _handleFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _noteController.dispose();
    _titleFocusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _targetFocusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _noteFocusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: AppSheetScaffold(
        title: _isEditing ? 'Chỉnh sửa mục tiêu' : 'Thêm mục tiêu tiết kiệm',
        body: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: context.scaled(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SavingsTextField(
                label: 'Tên mục tiêu',
                hintText: 'Ví dụ: Mua laptop',
                controller: _titleController,
                focusNode: _titleFocusNode,
                isFocused: _titleFocusNode.hasFocus,
                icon: Icons.flag_rounded,
                required: true,
                textCapitalization: TextCapitalization.sentences,
              ),
              SizedBox(height: context.scaled(12)),
              _SavingsAmountField(
                label: 'Số tiền mục tiêu',
                controller: _targetController,
                focusNode: _targetFocusNode,
                isFocused: _targetFocusNode.hasFocus,
                required: true,
              ),
              SizedBox(height: context.scaled(12)),
              _DatePickerCard(
                label: 'Ngày bắt đầu',
                value: formatShortDate(_startDate),
                icon: Icons.play_circle_rounded,
                onTap: _pickStartDate,
              ),
              SizedBox(height: context.scaled(12)),
              _DatePickerCard(
                label: 'Deadline',
                value: _deadline == null
                    ? 'Không có deadline'
                    : formatShortDate(_deadline!),
                icon: Icons.event_rounded,
                onTap: _pickDeadline,
                onClear: _deadline == null
                    ? null
                    : () => setState(() => _deadline = null),
              ),
              SizedBox(height: context.scaled(12)),
              _SavingsTextField(
                label: 'Ghi chú',
                hintText: 'Ghi chú thêm nếu cần',
                controller: _noteController,
                focusNode: _noteFocusNode,
                isFocused: _noteFocusNode.hasFocus,
                icon: Icons.edit_note_rounded,
                textCapitalization: TextCapitalization.sentences,
                minLines: 3,
                maxLines: null,
              ),
            ],
          ),
        ),
        action: AppPrimaryButton(
          label: _isEditing ? 'Lưu thay đổi' : 'Tạo mục tiêu',
          color: AppColors.primary,
          onTap: _save,
        ),
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final today = _today();
    final firstDay = _isEditing && _startDate.isBefore(today)
        ? _startDate
        : today;
    final picked = await showAppCalendarSheet(
      context,
      initialDate: _startDate,
      firstDay: firstDay,
      title: 'Chọn ngày bắt đầu',
      subtitle: 'Không thể chọn ngày trong quá khứ',
    );

    if (picked != null && mounted) {
      setState(() {
        _startDate = _dateOnly(picked);
        if (_deadline != null && _deadline!.isBefore(_startDate)) {
          _deadline = null;
        }
      });
    }
  }

  Future<void> _pickDeadline() async {
    final picked = await showAppCalendarSheet(
      context,
      initialDate: _deadline ?? _startDate,
      firstDay: _startDate,
      title: 'Chọn deadline',
      subtitle: 'Có thể bỏ trống nếu chưa có hạn hoàn thành',
    );

    if (picked != null && mounted) {
      setState(() => _deadline = _dateOnly(picked));
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final targetAmount = _parseAmountInput(_targetController.text);

    if (title.isEmpty) {
      AppToast.show(
        context,
        message: 'Vui lòng nhập tên mục tiêu',
        type: AppToastType.error,
      );
      return;
    }

    if (targetAmount == null || targetAmount <= 0) {
      AppToast.show(
        context,
        message: 'Vui lòng nhập số tiền mục tiêu',
        type: AppToastType.error,
      );
      return;
    }

    if (!_isEditing && _startDate.isBefore(_today())) {
      AppToast.show(
        context,
        message: 'Ngày bắt đầu không được ở quá khứ',
        type: AppToastType.error,
      );
      return;
    }

    if (_deadline != null && _deadline!.isBefore(_startDate)) {
      AppToast.show(
        context,
        message: 'Deadline không được trước ngày bắt đầu',
        type: AppToastType.error,
      );
      return;
    }

    final existingGoal = widget.goal;
    final now = DateTime.now();
    final goal = SavingsGoal(
      id: existingGoal?.id ?? generateLocalEntityId(),
      title: title,
      targetAmount: targetAmount,
      savedAmount: existingGoal?.savedAmount ?? 0,
      startDate: _startDate,
      deadline: _deadline,
      note: _noteController.text,
      createdAt: existingGoal?.createdAt ?? now,
      updatedAt: now,
    );

    if (_isEditing) {
      await ref.read(savingsGoalsProvider.notifier).updateGoal(goal);
    } else {
      await ref.read(savingsGoalsProvider.notifier).addGoal(goal);
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(goal);
    AppToast.show(
      context,
      message: _isEditing ? 'Đã cập nhật mục tiêu' : 'Đã tạo mục tiêu',
      type: AppToastType.success,
    );
  }
}

class _SavingsTextField extends StatelessWidget {
  const _SavingsTextField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.icon,
    this.required = false,
    this.textCapitalization = TextCapitalization.none,
    this.minLines,
    this.maxLines = 1,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final IconData icon;
  final bool required;
  final TextCapitalization textCapitalization;
  final int? minLines;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return _FormCard(
      isFocused: isFocused,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LeadingIcon(icon: icon),
          SizedBox(width: context.scaled(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(label: label, required: required),
                SizedBox(height: context.scaled(5)),
                TextField(
                  controller: controller,
                  focusNode: focusNode,
                  minLines: minLines,
                  maxLines: maxLines,
                  textCapitalization: textCapitalization,
                  style: context.appText.fieldValue,
                  cursorColor: AppColors.primary,
                  decoration: _fieldDecoration(context, hintText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingsAmountField extends StatelessWidget {
  const _SavingsAmountField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    this.required = false,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final bool required;

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
                _FieldLabel(label: label, required: required),
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

class _DatePickerCard extends StatelessWidget {
  const _DatePickerCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onTap,
      child: _FormCard(
        child: Row(
          children: [
            _LeadingIcon(icon: icon),
            SizedBox(width: context.scaled(10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel(label: label),
                  SizedBox(height: context.scaled(5)),
                  Text(value, style: context.appText.fieldValue),
                ],
              ),
            ),
            if (onClear != null) ...[
              AppBounceBuilder(
                onTap: onClear,
                child: Icon(
                  Icons.close_rounded,
                  color: context.appPalette.textSecondary,
                  size: context.scaled(20),
                ),
              ),
              SizedBox(width: context.scaled(8)),
            ],
            Icon(
              Icons.chevron_right_rounded,
              color: context.appPalette.textSecondary,
              size: context.scaled(20),
            ),
          ],
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

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
