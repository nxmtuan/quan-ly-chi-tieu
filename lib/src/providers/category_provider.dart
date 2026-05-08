import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import 'storage_provider.dart';

class CategoriesNotifier extends Notifier<List<Category>> {
  @override
  List<Category> build() {
    final storedCategories = ref
        .read(categoryStorageProvider)
        .readCategories(includeDeleted: true);

    if (storedCategories.isNotEmpty) {
      return _visibleCategories(storedCategories);
    }

    final seededCategories = [
      for (final category in defaultCategories) category.copyWith(),
    ];
    unawaited(
      ref.read(categoryStorageProvider).replaceAllCategories([
        for (final category in seededCategories) category.copyWith(),
      ]),
    );
    return seededCategories;
  }

  Future<void> addCategory(Category category) async {
    state = [...state, category];
    await ref.read(categoryStorageProvider).putCategory(category);
  }

  Future<void> updateCategory(Category category) async {
    state = [
      for (final item in state)
        if (item.id == category.id) category else item,
    ];
    await ref.read(categoryStorageProvider).putCategory(category);
  }

  Future<void> deleteCategory(String id) async {
    state = state.where((category) => category.id != id).toList();
    await ref.read(categoryStorageProvider).markCategoryDeleted(id);
  }

  static List<Category> _visibleCategories(List<Category> categories) {
    return [
      for (final category in categories)
        if (!category.isDeleted) category,
    ];
  }
}

final categoriesProvider = NotifierProvider<CategoriesNotifier, List<Category>>(
  CategoriesNotifier.new,
);

final defaultCategories = [
  Category(
    id: 'salary',
    name: 'Salary',
    iconData: Icons.payments_rounded,
    colorHex: 0xFF10B981,
    type: TransactionType.income,
  ),
  Category(
    id: 'freelance',
    name: 'Freelance',
    iconData: Icons.laptop_mac_rounded,
    colorHex: 0xFF7C3AED,
    type: TransactionType.income,
  ),
  Category(
    id: 'food',
    name: 'Food',
    iconData: Icons.restaurant_rounded,
    colorHex: 0xFFEF4444,
    type: TransactionType.expense,
  ),
  Category(
    id: 'shopping',
    name: 'Shopping',
    iconData: Icons.shopping_bag_rounded,
    colorHex: 0xFF7C3AED,
    type: TransactionType.expense,
  ),
  Category(
    id: 'home',
    name: 'Home',
    iconData: Icons.home_rounded,
    colorHex: 0xFFF59E0B,
    type: TransactionType.expense,
  ),
  Category(
    id: 'transport',
    name: 'Transport',
    iconData: Icons.directions_car_rounded,
    colorHex: 0xFF7C3AED,
    type: TransactionType.expense,
  ),
  Category(
    id: 'health',
    name: 'Health',
    iconData: Icons.favorite_rounded,
    colorHex: 0xFFEF4444,
    type: TransactionType.expense,
  ),
  Category(
    id: 'travel',
    name: 'Travel',
    iconData: Icons.flight_takeoff_rounded,
    colorHex: 0xFF10B981,
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
