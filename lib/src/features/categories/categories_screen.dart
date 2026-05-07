import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/adaptive.dart';
import '../../core/widgets/flat_card.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            onPressed: () => showCategoryDialog(context, ref),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          context.scaled(24),
          context.scaled(16),
          context.scaled(24),
          context.scaled(32),
        ),
        children: [
          for (final type in TransactionType.values) ...[
            Text(
              type == TransactionType.income ? 'Income' : 'Expense',
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
      ),
    );
  }
}
