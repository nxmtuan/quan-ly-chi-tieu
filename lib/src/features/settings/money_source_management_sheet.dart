import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/adaptive.dart';
import '../../core/utils/local_id.dart';
import '../../core/widgets/app_bounce_builder.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/app_toast.dart';
import '../../models/money_source.dart';
import '../../providers/money_source_provider.dart';
import '../../providers/storage_provider.dart';

Future<void> showMoneySourceManagementSheet(
  BuildContext context,
  WidgetRef ref,
) {
  return showAppBottomSheet<void>(
    context: context,
    builder: (_) => const _MoneySourceManagementSheet(),
  );
}

class _MoneySourceManagementSheet extends ConsumerWidget {
  const _MoneySourceManagementSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moneySources = ref.watch(moneySourcesProvider);

    return AppSheetScaffold(
      title: 'Quản lý nguồn tiền',
      body: moneySources.isEmpty
          ? Center(
              child: Text(
                'Chưa có nguồn tiền nào',
                style: context.appText.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.only(bottom: context.scaled(16)),
              itemCount: moneySources.length,
              separatorBuilder: (_, _) => SizedBox(height: context.scaled(12)),
              itemBuilder: (context, index) {
                final source = moneySources[index];
                return _ManagedMoneySourceRow(
                  source: source,
                  onEdit: isDefaultMoneySourceId(source.id)
                      ? null
                      : () => _openEditor(context, source: source),
                  onDelete: isDefaultMoneySourceId(source.id)
                      ? null
                      : () => _deleteSource(context, ref, source),
                );
              },
            ),
      action: AppPrimaryButton(
        label: 'Thêm nguồn tiền',
        color: AppColors.primary,
        onTap: () => _openEditor(context),
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context, {
    MoneySource? source,
  }) async {
    await showAppBottomSheet<void>(
      context: context,
      builder: (_) => _MoneySourceEditorSheet(source: source),
    );
  }

  Future<void> _deleteSource(
    BuildContext context,
    WidgetRef ref,
    MoneySource source,
  ) async {
    final hasTransactions = ref
        .read(transactionStorageProvider)
        .hasActiveTransactionsForSource(source.id);
    if (hasTransactions) {
      AppToast.show(
        context,
        message: 'Không thể xóa nguồn tiền đang được giao dịch sử dụng',
        type: AppToastType.error,
      );
      return;
    }

    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Xóa nguồn tiền',
      message: 'Nguồn tiền này sẽ bị xóa khỏi danh sách chọn.',
      confirmText: 'Xóa',
      confirmTextColor: const Color(0xFFDC2626),
      confirmBackgroundColor: const Color(0xFFFEE2E2),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await ref.read(moneySourcesProvider.notifier).deleteMoneySource(source.id);
    if (context.mounted) {
      AppToast.show(
        context,
        message: 'Đã xóa nguồn tiền',
        type: AppToastType.success,
      );
    }
  }
}

class _ManagedMoneySourceRow extends StatelessWidget {
  const _ManagedMoneySourceRow({
    required this.source,
    required this.onEdit,
    required this.onDelete,
  });

  final MoneySource source;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.scaled(16),
        vertical: context.scaled(14),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.scaled(22)),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: context.scaled(46),
            height: context.scaled(46),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(context.scaled(16)),
            ),
            child: Icon(
              source.iconData,
              color: AppColors.primary,
              size: context.scaled(22),
            ),
          ),
          SizedBox(width: context.scaled(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source.name,
                  style: context.appText.bodyStrong.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (isDefaultMoneySourceId(source.id)) ...[
                  SizedBox(height: context.scaled(3)),
                  Text(
                    'Nguồn tiền mặc định',
                    style: context.appText.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onEdit != null) ...[
            _ActionButton(
              icon: Icons.edit_rounded,
              onTap: onEdit!,
            ),
            SizedBox(width: context.scaled(8)),
          ],
          if (onDelete != null)
            _ActionButton(
              icon: Icons.delete_rounded,
              color: AppColors.danger,
              backgroundColor: AppColors.danger.withValues(alpha: 0.1),
              onTap: onDelete!,
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.color = AppColors.textPrimary,
    this.backgroundColor = const Color(0xFFF8FAFC),
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onTap,
      child: Container(
        width: context.scaled(38),
        height: context.scaled(38),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(context.scaled(14)),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: color, size: context.scaled(18)),
      ),
    );
  }
}

class _MoneySourceEditorSheet extends ConsumerStatefulWidget {
  const _MoneySourceEditorSheet({this.source});

  final MoneySource? source;

  @override
  ConsumerState<_MoneySourceEditorSheet> createState() =>
      _MoneySourceEditorSheetState();
}

class _MoneySourceEditorSheetState
    extends ConsumerState<_MoneySourceEditorSheet> {
  late final TextEditingController _nameController;
  late final FocusNode _nameFocusNode;
  late IconData _iconData;

  bool get _isEditing => widget.source != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.source?.name ?? '');
    _nameFocusNode = FocusNode()..addListener(_handleFocusChanged);
    _iconData =
        widget.source?.iconData ?? Icons.account_balance_wallet_rounded;
  }

  void _handleFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSheetScaffold(
      title: _isEditing ? 'Chỉnh sửa nguồn tiền' : 'Thêm nguồn tiền',
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: context.scaled(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel(label: 'Tên nguồn tiền'),
            SizedBox(height: context.scaled(10)),
            _NameField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              isFocused: _nameFocusNode.hasFocus,
            ),
            SizedBox(height: context.scaled(18)),
            _SectionLabel(label: 'Biểu tượng'),
            SizedBox(height: context.scaled(10)),
            Wrap(
              spacing: context.scaled(10),
              runSpacing: context.scaled(10),
              children: [
                for (final icon in moneySourceIconOptions)
                  _IconOption(
                    icon: icon,
                    selected: icon == _iconData,
                    onTap: () => setState(() => _iconData = icon),
                  ),
              ],
            ),
          ],
        ),
      ),
      action: AppPrimaryButton(
        label: _isEditing ? 'Lưu thay đổi' : 'Tạo nguồn tiền',
        color: AppColors.primary,
        onTap: _save,
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      AppToast.show(
        context,
        message: 'Vui lòng nhập tên nguồn tiền',
        type: AppToastType.error,
      );
      return;
    }

    final source = MoneySource(
      id: widget.source?.id ?? generateLocalEntityId(),
      name: name,
      iconData: _iconData,
    );

    if (_isEditing) {
      await ref.read(moneySourcesProvider.notifier).updateMoneySource(source);
    } else {
      await ref.read(moneySourcesProvider.notifier).addMoneySource(source);
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
    AppToast.show(
      context,
      message: _isEditing ? 'Đã cập nhật nguồn tiền' : 'Đã tạo nguồn tiền',
      type: AppToastType.success,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: context.appText.fieldLabel.copyWith(
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(context.scaled(18)),
        border: Border.all(
          color: isFocused ? AppColors.primary : AppColors.border,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: context.scaled(16)),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: context.appText.bodyStrong.copyWith(
          color: AppColors.textPrimary,
        ),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          filled: false,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            vertical: context.scaled(14),
          ),
          hintText: 'Nhập tên nguồn tiền',
          hintStyle: context.appText.body.copyWith(
            color: const Color(0xFFB3BAC8),
          ),
        ),
      ),
    );
  }
}

class _IconOption extends StatelessWidget {
  const _IconOption({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: context.scaled(52),
        height: context.scaled(52),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(context.scaled(18)),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          color: selected ? AppColors.primary : AppColors.textPrimary,
          size: context.scaled(22),
        ),
      ),
    );
  }
}
