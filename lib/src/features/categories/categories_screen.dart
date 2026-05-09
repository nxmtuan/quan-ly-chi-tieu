import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/adaptive.dart';
import '../../core/utils/local_id.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_page_header.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/flat_card.dart';
import '../../core/widgets/app_bounce_builder.dart';
import '../../core/widgets/app_toast.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';

part 'widgets/category_row.dart';
part 'dialogs/category_dialog.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        context.scaled(24),
        context.scaled(22),
        context.scaled(24),
        context.scaled(120),
      ),
      children: [
        const AppPageHeader(
          subtitle: 'Danh mục',
          title: 'Quản lý danh mục',
        ),
        SizedBox(height: context.scaled(22)),
        _AddCategoryCard(
          onTap: () => showCategoryDialog(context, ref),
        ),
        SizedBox(height: context.scaled(22)),
        for (final type in TransactionType.values) ...[
          _CategorySection(
            type: type,
            categories: [
              for (final category in categories)
                if (category.type == type) category,
            ],
          ),
          SizedBox(height: context.scaled(14)),
        ],
      ],
    );
  }
}

class _AddCategoryCard extends StatelessWidget {
  const _AddCategoryCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onTap,
      child: FlatCard(
        padding: EdgeInsets.symmetric(
          horizontal: context.scaled(18),
          vertical: context.scaled(18),
        ),
        child: Row(
          children: [
            Container(
              width: context.scaled(50),
              height: context.scaled(50),
              decoration: BoxDecoration(
                color: context.appPalette.primarySoft,
                borderRadius: BorderRadius.circular(context.scaled(18)),
              ),
              child: Icon(
                Icons.add_box_rounded,
                color: AppColors.primary,
                size: context.scaled(24),
              ),
            ),
            SizedBox(width: context.scaled(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thêm danh mục mới',
                    style: context.appText.cardTitle,
                  ),
                  SizedBox(height: context.scaled(4)),
                  Text(
                    'Tạo nhóm thu hoặc chi với icon và màu riêng.',
                    style: context.appText.secondary.copyWith(
                      color: context.appPalette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: context.scaled(12)),
            Icon(
              Icons.chevron_right_rounded,
              color: context.appPalette.textSecondary,
              size: context.scaled(24),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.type,
    required this.categories,
  });

  final TransactionType type;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final isIncome = type == TransactionType.income;
    final title = isIncome ? 'Danh mục thu' : 'Danh mục chi';
    final subtitle = isIncome
        ? 'Các nguồn tiền và khoản thu nhập.'
        : 'Các nhóm chi tiêu và mua sắm.';
    final accentColor = isIncome ? AppColors.success : AppColors.danger;
    final accentBackground = accentColor.withValues(alpha: 0.12);
    final icon = isIncome
        ? Icons.south_west_rounded
        : Icons.north_east_rounded;

    return FlatCard(
      padding: EdgeInsets.fromLTRB(
        context.scaled(18),
        context.scaled(18),
        context.scaled(18),
        context.scaled(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: context.scaled(44),
                height: context.scaled(44),
                decoration: BoxDecoration(
                  color: accentBackground,
                  borderRadius: BorderRadius.circular(context.scaled(16)),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: context.scaled(21),
                ),
              ),
              SizedBox(width: context.scaled(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.appText.cardTitle,
                    ),
                    SizedBox(height: context.scaled(4)),
                    Text(
                      subtitle,
                      style: context.appText.secondary.copyWith(
                        color: context.appPalette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.scaled(14)),
          Divider(color: context.appPalette.border, height: 1),
          if (categories.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.scaled(18)),
              child: Text(
                'Chưa có danh mục nào',
                style: context.appText.body.copyWith(
                  color: context.appPalette.textSecondary,
                ),
              ),
            )
          else
            for (var index = 0; index < categories.length; index++) ...[
              _CategoryRow(category: categories[index]),
              if (index != categories.length - 1)
                Divider(color: context.appPalette.border, height: 1),
            ],
        ],
      ),
    );
  }
}
