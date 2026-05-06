part of '../add_transaction_sheet.dart';

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
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
    final shouldShowMoreButton = orderedCategories.length > 3;

    return _FormCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RequiredLabel(label: 'Danh mục', color: actionColor),
          const SizedBox(height: 10),
          if (categories.isEmpty)
            const Text(
              'Chưa có danh mục',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = (constraints.maxWidth - 24) / 4;

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final category in visibleCategories)
                      SizedBox(
                        width: itemWidth,
                        child: _CategoryTile(
                          category: category,
                          selected: category.id == selectedCategoryId,
                          actionColor: actionColor,
                          onTap: () => onSelected(category),
                        ),
                      ),
                    if (shouldShowMoreButton)
                      SizedBox(
                        width: itemWidth,
                        child: _MoreCategoriesTile(onTap: onShowAll),
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

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 122,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
          decoration: BoxDecoration(
            color: selected
                ? actionColor.withValues(alpha: 0.045)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? actionColor : AppColors.border,
              width: selected ? 1.2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(category.iconData, color: category.color, size: 21),
              ),
              const SizedBox(height: 10),
              Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? actionColor : AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreCategoriesTile extends StatelessWidget {
  const _MoreCategoriesTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 122,
        padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MoreCategoriesIcon(),
            SizedBox(height: 10),
            Text(
              'Khác',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreCategoriesIcon extends StatelessWidget {
  const _MoreCategoriesIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Icon(
        Icons.more_horiz_rounded,
        color: AppColors.primary,
        size: 22,
      ),
    );
  }
}
