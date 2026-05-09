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
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';

Future<void> showCategoryManagementSheet(
  BuildContext context,
  WidgetRef ref,
) {
  return showAppBottomSheet<void>(
    context: context,
    builder: (_) => const _CategoryManagementSheet(),
  );
}

class _CategoryManagementSheet extends ConsumerStatefulWidget {
  const _CategoryManagementSheet();

  @override
  ConsumerState<_CategoryManagementSheet> createState() =>
      _CategoryManagementSheetState();
}

class _CategoryManagementSheetState
    extends ConsumerState<_CategoryManagementSheet> {
  TransactionType _selectedType = TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesByTypeProvider(_selectedType));

    return AppSheetScaffold(
      title: 'Quản lý danh mục',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CategoryTypeTabs(
            selectedType: _selectedType,
            onSelected: (type) => setState(() => _selectedType = type),
          ),
          SizedBox(height: context.scaled(18)),
          Expanded(
            child: categories.isEmpty
                ? Center(
                    child: Text(
                      'Chưa có danh mục nào',
                      style: context.appText.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.only(bottom: context.scaled(16)),
                    itemCount: categories.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: context.scaled(12)),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _ManagedCategoryRow(
                        category: category,
                        onEdit: () => _openEditor(category: category),
                        onDelete: () => _deleteCategory(category),
                      );
                    },
                  ),
          ),
        ],
      ),
      action: AppPrimaryButton(
        label: 'Thêm danh mục',
        color: AppColors.primary,
        onTap: () => _openEditor(),
      ),
    );
  }

  Future<void> _openEditor({Category? category}) async {
    await showAppBottomSheet<void>(
      context: context,
      builder: (_) => _CategoryEditorSheet(
        initialType: category?.type ?? _selectedType,
        category: category,
      ),
    );
  }

  Future<void> _deleteCategory(Category category) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Xóa danh mục',
      message: 'Các giao dịch trong danh mục này cũng sẽ bị xóa.',
      confirmText: 'Xóa',
      confirmTextColor: const Color(0xFFDC2626),
      confirmBackgroundColor: const Color(0xFFFEE2E2),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await ref
        .read(transactionsProvider.notifier)
        .deleteTransactionsByCategory(category.id);
    await ref.read(categoriesProvider.notifier).deleteCategory(category.id);
    if (!mounted) {
      return;
    }
    AppToast.show(
      context,
      message: 'Đã xóa danh mục',
      type: AppToastType.success,
    );
  }
}

class _CategoryTypeTabs extends StatelessWidget {
  const _CategoryTypeTabs({
    required this.selectedType,
    required this.onSelected,
  });

  final TransactionType selectedType;
  final ValueChanged<TransactionType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.scaled(3)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.scaled(18)),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _CategoryTypeTab(
              label: 'Danh mục chi',
              color: AppColors.danger,
              isActive: selectedType == TransactionType.expense,
              onTap: () => onSelected(TransactionType.expense),
            ),
          ),
          Expanded(
            child: _CategoryTypeTab(
              label: 'Danh mục thu',
              color: AppColors.success,
              isActive: selectedType == TransactionType.income,
              onTap: () => onSelected(TransactionType.income),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTypeTab extends StatelessWidget {
  const _CategoryTypeTab({
    required this.label,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(vertical: context.scaled(14)),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(context.scaled(15)),
          border: isActive
              ? Border.all(color: color.withValues(alpha: 0.28))
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: context.appText.bodyStrong.copyWith(
            color: isActive ? color : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ManagedCategoryRow extends StatelessWidget {
  const _ManagedCategoryRow({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final canDelete = !isDefaultCategoryId(category.id);

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
              color: category.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(context.scaled(16)),
            ),
            child: Icon(
              category.iconData,
              color: category.color,
              size: context.scaled(22),
            ),
          ),
          SizedBox(width: context.scaled(14)),
          Expanded(
            child: Text(
              category.name,
              style: context.appText.bodyStrong.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _CategoryActionButton(
            icon: Icons.edit_rounded,
            onTap: onEdit,
          ),
          if (canDelete) ...[
            SizedBox(width: context.scaled(8)),
            _CategoryActionButton(
              icon: Icons.delete_rounded,
              color: AppColors.danger,
              backgroundColor: AppColors.danger.withValues(alpha: 0.1),
              onTap: onDelete,
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryActionButton extends StatelessWidget {
  const _CategoryActionButton({
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
        child: Icon(
          icon,
          color: color,
          size: context.scaled(18),
        ),
      ),
    );
  }
}

class _CategoryEditorSheet extends ConsumerStatefulWidget {
  const _CategoryEditorSheet({
    required this.initialType,
    this.category,
  });

  final TransactionType initialType;
  final Category? category;

  @override
  ConsumerState<_CategoryEditorSheet> createState() =>
      _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends ConsumerState<_CategoryEditorSheet> {
  late final TextEditingController _nameController;
  late final FocusNode _nameFocusNode;
  late TransactionType _type;
  late IconData _iconData;
  late int _colorHex;

  bool get _isEditing => widget.category != null;
  bool get _isDefaultCategory =>
      widget.category != null && isDefaultCategoryId(widget.category!.id);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _nameFocusNode = FocusNode()..addListener(_handleFocusChanged);
    _type = widget.category?.type ?? widget.initialType;
    _iconData = widget.category?.iconData ?? Icons.category_rounded;
    _colorHex = widget.category?.colorHex ?? AppColors.primary.toARGB32();
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
      title: _isEditing ? 'Chỉnh sửa danh mục' : 'Thêm danh mục',
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: context.scaled(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _EditorSectionLabel(label: 'Loại danh mục'),
            SizedBox(height: context.scaled(10)),
            _EditorTypeToggleGroup(
              value: _type,
              enabled: !_isDefaultCategory,
              onChanged: (value) => setState(() => _type = value),
            ),
            SizedBox(height: context.scaled(18)),
            _EditorSectionLabel(label: 'Tên danh mục'),
            SizedBox(height: context.scaled(10)),
            _EditorNameField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              isFocused: _nameFocusNode.hasFocus && !_isDefaultCategory,
              readOnly: _isDefaultCategory,
            ),
            SizedBox(height: context.scaled(18)),
            _EditorSectionLabel(label: 'Biểu tượng'),
            SizedBox(height: context.scaled(10)),
            Wrap(
              spacing: context.scaled(10),
              runSpacing: context.scaled(10),
              children: [
                for (final icon in categoryIconOptions)
                  _EditorIconOption(
                    icon: icon,
                    selected: icon == _iconData,
                    onTap: () => setState(() => _iconData = icon),
                  ),
              ],
            ),
            SizedBox(height: context.scaled(18)),
            _EditorSectionLabel(label: 'Màu sắc'),
            SizedBox(height: context.scaled(10)),
            Wrap(
              spacing: context.scaled(10),
              runSpacing: context.scaled(10),
              children: [
                for (final color in categoryColorOptions)
                  _EditorColorOption(
                    color: color,
                    selected: _colorHex == color.toARGB32(),
                    enabled: !_isDefaultCategory,
                    onTap: () => setState(() => _colorHex = color.toARGB32()),
                  ),
              ],
            ),
          ],
        ),
      ),
      action: AppPrimaryButton(
        label: _isEditing ? 'Lưu thay đổi' : 'Tạo danh mục',
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
        message: 'Vui lòng nhập tên danh mục',
        type: AppToastType.error,
      );
      return;
    }

    final category = Category(
      id: widget.category?.id ?? generateLocalEntityId(),
      name: name,
      iconData: _iconData,
      colorHex: _colorHex,
      type: _type,
    );

    if (_isEditing) {
      await ref.read(categoriesProvider.notifier).updateCategory(category);
    } else {
      await ref.read(categoriesProvider.notifier).addCategory(category);
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
    AppToast.show(
      context,
      message: _isEditing ? 'Đã cập nhật danh mục' : 'Đã tạo danh mục',
      type: AppToastType.success,
    );
  }
}

class _EditorSectionLabel extends StatelessWidget {
  const _EditorSectionLabel({required this.label});

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

class _EditorNameField extends StatelessWidget {
  const _EditorNameField({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.readOnly,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final bool readOnly;

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
        readOnly: readOnly,
        cursorColor: AppColors.primary,
        style: context.appText.bodyStrong.copyWith(
          color: AppColors.textPrimary,
        ),
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
          hintText: 'Nhập tên danh mục',
          hintStyle: context.appText.body.copyWith(
            color: const Color(0xFFB3BAC8),
          ),
        ),
      ),
    );
  }
}

class _EditorTypeToggleGroup extends StatelessWidget {
  const _EditorTypeToggleGroup({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final TransactionType value;
  final bool enabled;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _EditorTypeToggleButton(
            label: 'Chi tiêu',
            icon: Icons.north_east_rounded,
            color: AppColors.danger,
            selected: value == TransactionType.expense,
            enabled: enabled,
            onTap: () => onChanged(TransactionType.expense),
          ),
        ),
        SizedBox(width: context.scaled(10)),
        Expanded(
          child: _EditorTypeToggleButton(
            label: 'Thu nhập',
            icon: Icons.south_west_rounded,
            color: AppColors.success,
            selected: value == TransactionType.income,
            enabled: enabled,
            onTap: () => onChanged(TransactionType.income),
          ),
        ),
      ],
    );
  }
}

class _EditorTypeToggleButton extends StatelessWidget {
  const _EditorTypeToggleButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: context.scaled(14),
          vertical: context.scaled(14),
        ),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: enabled ? 0.08 : 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(context.scaled(18)),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: enabled ? 0.24 : 0.16)
                : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: enabled ? color : color.withValues(alpha: 0.55),
              size: context.scaled(18),
            ),
            SizedBox(width: context.scaled(8)),
            Text(
              label,
              style: context.appText.bodyStrong.copyWith(
                color: enabled ? color : color.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorIconOption extends StatelessWidget {
  const _EditorIconOption({
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

class _EditorColorOption extends StatelessWidget {
  const _EditorColorOption({
    required this.color,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: context.scaled(52),
        height: context.scaled(52),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.scaled(18)),
          border: Border.all(
            color: selected ? Colors.black : AppColors.border,
            width: context.scaled(selected ? 3 : 1),
          ),
        ),
        child: Center(
          child: Container(
            width: context.scaled(30),
            height: context.scaled(30),
            decoration: BoxDecoration(
              color: enabled ? color : color.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(context.scaled(10)),
            ),
          ),
        ),
      ),
    );
  }
}
