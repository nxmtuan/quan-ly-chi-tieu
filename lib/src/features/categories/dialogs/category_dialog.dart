part of '../categories_screen.dart';

Future<void> showCategoryDialog(
  BuildContext context,
  WidgetRef ref, {
  Category? category,
}) {
  return showAppBottomSheet<void>(
    context: context,
    builder: (_) => _CategoryFormSheet(category: category),
  );
}

class _CategoryFormSheet extends ConsumerStatefulWidget {
  const _CategoryFormSheet({this.category});

  final Category? category;

  @override
  ConsumerState<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends ConsumerState<_CategoryFormSheet> {
  late final TextEditingController _nameController;
  late TransactionType _type;
  late IconData _iconData;
  late int _colorHex;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _type = widget.category?.type ?? TransactionType.expense;
    _iconData = widget.category?.iconData ?? Icons.category_rounded;
    _colorHex = widget.category?.colorHex ?? AppColors.primary.toARGB32();
  }

  @override
  void dispose() {
    _nameController.dispose();
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
            _SheetSectionLabel(label: 'Tên danh mục'),
            SizedBox(height: context.scaled(10)),
            _CategoryNameField(controller: _nameController),
            SizedBox(height: context.scaled(18)),
            _SheetSectionLabel(label: 'Loại danh mục'),
            SizedBox(height: context.scaled(10)),
            _TypeToggleGroup(
              value: _type,
              onChanged: (value) => setState(() => _type = value),
            ),
            SizedBox(height: context.scaled(18)),
            _SheetSectionLabel(label: 'Biểu tượng'),
            SizedBox(height: context.scaled(10)),
            _IconPickerGrid(
              selectedIcon: _iconData,
              onSelected: (value) => setState(() => _iconData = value),
            ),
            SizedBox(height: context.scaled(18)),
            _SheetSectionLabel(label: 'Màu sắc'),
            SizedBox(height: context.scaled(10)),
            _ColorPickerGrid(
              selectedColorHex: _colorHex,
              onSelected: (value) => setState(() => _colorHex = value),
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
      id: widget.category?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
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

class _SheetSectionLabel extends StatelessWidget {
  const _SheetSectionLabel({required this.label});

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

class _CategoryNameField extends StatelessWidget {
  const _CategoryNameField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.scaled(18)),
        border: Border.all(color: AppColors.border),
      ),
      padding: EdgeInsets.symmetric(horizontal: context.scaled(16)),
      child: TextField(
        controller: controller,
        style: context.appText.bodyStrong.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Nhập tên danh mục',
          hintStyle: context.appText.body.copyWith(
            color: const Color(0xFFB3BAC8),
          ),
        ),
      ),
    );
  }
}

class _TypeToggleGroup extends StatelessWidget {
  const _TypeToggleGroup({
    required this.value,
    required this.onChanged,
  });

  final TransactionType value;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TypeToggleButton(
            label: 'Chi tiêu',
            icon: Icons.north_east_rounded,
            color: AppColors.danger,
            selected: value == TransactionType.expense,
            onTap: () => onChanged(TransactionType.expense),
          ),
        ),
        SizedBox(width: context.scaled(10)),
        Expanded(
          child: _TypeToggleButton(
            label: 'Thu nhập',
            icon: Icons.south_west_rounded,
            color: AppColors.success,
            selected: value == TransactionType.income,
            onTap: () => onChanged(TransactionType.income),
          ),
        ),
      ],
    );
  }
}

class _TypeToggleButton extends StatelessWidget {
  const _TypeToggleButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: context.scaled(14),
          vertical: context.scaled(14),
        ),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(context.scaled(18)),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.28) : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: context.scaled(18)),
            SizedBox(width: context.scaled(8)),
            Text(
              label,
              style: context.appText.bodyStrong.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconPickerGrid extends StatelessWidget {
  const _IconPickerGrid({
    required this.selectedIcon,
    required this.onSelected,
  });

  final IconData selectedIcon;
  final ValueChanged<IconData> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.scaled(10),
      runSpacing: context.scaled(10),
      children: [
        for (final icon in categoryIconOptions)
          _IconOption(
            icon: icon,
            selected: icon == selectedIcon,
            onTap: () => onSelected(icon),
          ),
      ],
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

class _ColorPickerGrid extends StatelessWidget {
  const _ColorPickerGrid({
    required this.selectedColorHex,
    required this.onSelected,
  });

  final int selectedColorHex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.scaled(12),
      runSpacing: context.scaled(12),
      children: [
        for (final color in categoryColorOptions)
          _ColorOption(
            color: color,
            selected: selectedColorHex == color.toARGB32(),
            onTap: () => onSelected(color.toARGB32()),
          ),
      ],
    );
  }
}

class _ColorOption extends StatelessWidget {
  const _ColorOption({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: context.scaled(34),
        height: context.scaled(34),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.textPrimary : Colors.transparent,
            width: context.scaled(selected ? 2 : 1),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.28),
                    blurRadius: context.scaled(10),
                    offset: Offset(0, context.scaled(4)),
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
