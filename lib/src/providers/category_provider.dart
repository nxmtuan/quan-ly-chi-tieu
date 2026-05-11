import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import 'storage_provider.dart';

class CategoriesNotifier extends Notifier<List<Category>> {
  @override
  List<Category> build() {
    return _loadVisibleCategories();
  }

  List<Category> _loadVisibleCategories() {
    final storedCategories = ref
        .read(categoryStorageProvider)
        .readCategories(includeDeleted: true);

    final mergedCategories = _mergeWithDefaultCategories(storedCategories);
    final compactedCategories = [
      for (final category in mergedCategories) category.compactedForStorage(),
    ];
    final needsRewrite =
        !_listEqualsByContent(storedCategories, mergedCategories) ||
        mergedCategories.any((category) => category.needsStorageCompaction);

    if (needsRewrite) {
      unawaited(
        ref.read(categoryStorageProvider).replaceAllCategories([
          for (final category in compactedCategories) category.copyWith(),
        ]),
      );
    }

    return _visibleCategories(
      needsRewrite ? compactedCategories : mergedCategories,
    );
  }

  void reload() {
    state = _loadVisibleCategories();
  }

  Future<void> addCategory(Category category) async {
    state = [...state, category];
    await ref.read(categoryStorageProvider).putCategory(category);
  }

  Future<void> updateCategory(Category category) async {
    if (isDefaultCategoryId(category.id)) {
      final existingCategory = state.where((item) => item.id == category.id).firstOrNull;
      if (existingCategory == null) {
        return;
      }

      final updatedDefaultCategory = existingCategory.copyWith(
        iconData: category.iconData,
        updatedAt: DateTime.now(),
      );
      state = [
        for (final item in state)
          if (item.id == category.id) updatedDefaultCategory else item,
      ];
      await ref.read(categoryStorageProvider).putCategory(updatedDefaultCategory);
      return;
    }

    state = [
      for (final item in state)
        if (item.id == category.id) category else item,
    ];
    await ref.read(categoryStorageProvider).putCategory(category);
  }

  Future<void> deleteCategory(String id) async {
    if (isDefaultCategoryId(id)) {
      return;
    }
    state = state.where((category) => category.id != id).toList();
    await ref.read(categoryStorageProvider).markCategoryDeleted(id);
  }

  static List<Category> _visibleCategories(List<Category> categories) {
    return [
      for (final category in categories)
        if (!category.isDeleted) category,
    ];
  }

  static List<Category> _mergeWithDefaultCategories(List<Category> storedCategories) {
    final storedById = {
      for (final category in storedCategories) category.id: category,
    };
    final merged = <Category>[];

    for (final defaultCategory in defaultCategories) {
      final storedCategory = storedById.remove(defaultCategory.id);
      if (storedCategory == null) {
        merged.add(defaultCategory.copyWith());
        continue;
      }

      final needsUpdate =
          storedCategory.name != defaultCategory.name ||
          storedCategory.colorHex != defaultCategory.colorHex ||
          storedCategory.type != defaultCategory.type ||
          storedCategory.isDeleted;

      merged.add(
        needsUpdate
            ? storedCategory.copyWith(
                name: defaultCategory.name,
                colorHex: defaultCategory.colorHex,
                type: defaultCategory.type,
                updatedAt: DateTime.now(),
                isDeleted: false,
              )
            : storedCategory,
      );
    }

    merged.addAll(storedById.values);
    return merged;
  }

  static bool _listEqualsByContent(List<Category> a, List<Category> b) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }

    for (var index = 0; index < a.length; index++) {
      final left = a[index];
      final right = b[index];
      if (left.id != right.id ||
          left.name != right.name ||
          left.iconData.codePoint != right.iconData.codePoint ||
          left.colorHex != right.colorHex ||
          left.type != right.type ||
          left.isDeleted != right.isDeleted) {
        return false;
      }
    }

    return true;
  }
}

final categoriesProvider = NotifierProvider<CategoriesNotifier, List<Category>>(
  CategoriesNotifier.new,
);

final defaultCategories = [
  Category(
    id: 'salary',
    name: 'Lương',
    iconData: Icons.payments_rounded,
    colorHex: 0xFF10B981,
    type: TransactionType.income,
  ),
  Category(
    id: 'allowance',
    name: 'Trợ cấp',
    iconData: Icons.volunteer_activism_rounded,
    colorHex: 0xFF14B8A6,
    type: TransactionType.income,
  ),
  Category(
    id: 'profit',
    name: 'Lợi nhuận',
    iconData: Icons.trending_up_rounded,
    colorHex: 0xFF9333EA,
    type: TransactionType.income,
  ),
  Category(
    id: 'food',
    name: 'Ăn uống',
    iconData: Icons.restaurant_rounded,
    colorHex: 0xFFEF4444,
    type: TransactionType.expense,
  ),
  Category(
    id: 'transport',
    name: 'Di chuyển',
    iconData: Icons.directions_car_rounded,
    colorHex: 0xFF2563EB,
    type: TransactionType.expense,
  ),
  Category(
    id: 'bills',
    name: 'Hóa đơn',
    iconData: Icons.receipt_long_rounded,
    colorHex: 0xFFF59E0B,
    type: TransactionType.expense,
  ),
  Category(
    id: 'study',
    name: 'Học tập',
    iconData: Icons.school_rounded,
    colorHex: 0xFF0D9488,
    type: TransactionType.expense,
  ),
];

final categoriesByTypeProvider =
    Provider.family<List<Category>, TransactionType>((ref, type) {
      return ref
          .watch(categoriesProvider)
          .where((category) => category.type == type)
          .toList();
    });

final categoryByIdProvider = Provider.family<Category?, String>((ref, id) {
  for (final category in ref.watch(categoriesProvider)) {
    if (category.id == id) {
      return category;
    }
  }

  return null;
});
