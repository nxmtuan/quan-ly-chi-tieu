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
      padding: EdgeInsets.fromLTRB(
        context.scaled(14),
        context.scaled(12),
        context.scaled(14),
        context.scaled(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RequiredLabel(label: 'Danh mục', color: actionColor),
          SizedBox(height: context.scaled(10)),
          if (categories.isEmpty)
            Text(
              'Chưa có danh mục',
              style: context.appText.bodyStrong.copyWith(
                color: AppColors.textSecondary,
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
      borderRadius: BorderRadius.circular(context.scaled(14)),
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
                : Colors.white,
            borderRadius: BorderRadius.circular(context.scaled(14)),
            border: Border.all(
              color: selected ? actionColor : AppColors.border,
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
                style: TextStyle(
                  color: selected ? actionColor : AppColors.textPrimary,
                  fontSize: context.scaledFont(12, min: 12),
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
      borderRadius: BorderRadius.circular(context.scaled(14)),
      child: Container(
        height: context.scaled(110),
        padding: EdgeInsets.fromLTRB(
          context.scaled(6),
          context.scaled(10),
          context.scaled(6),
          context.scaled(8),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(context.scaled(14)),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _MoreCategoriesIcon(),
            SizedBox(height: context.scaled(10)),
            Text(
              'Khác',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: context.scaledFont(12, min: 12),
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
