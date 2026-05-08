import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/adaptive.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/app_page_header.dart';
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
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: () => showCategoryDialog(context, ref),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Thêm danh mục'),
          ),
        ),
        SizedBox(height: context.scaled(22)),
        for (final type in TransactionType.values) ...[
          Text(
            type == TransactionType.income ? 'Thu nhập' : 'Chi tiêu',
            style: context.appText.sectionTitle,
          ),
          SizedBox(height: context.scaled(12)),
          for (final category in categories.where(
            (item) => item.type == type,
          ))
            Padding(
              padding: EdgeInsets.only(bottom: context.scaled(12)),
              child: _CategoryRow(category: category),
            ),
          SizedBox(height: context.scaled(12)),
        ],
      ],
    );
  }
}
