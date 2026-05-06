import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../models/transaction.dart';

final categoriesProvider = Provider<List<Category>>((ref) {
  return const [
    Category(
      id: 'salary',
      name: 'Salary',
      iconData: Icons.payments_rounded,
      colorHex: 0xFF2DD4BF,
      type: TransactionType.income,
    ),
    Category(
      id: 'freelance',
      name: 'Freelance',
      iconData: Icons.laptop_mac_rounded,
      colorHex: 0xFF60A5FA,
      type: TransactionType.income,
    ),
    Category(
      id: 'food',
      name: 'Food',
      iconData: Icons.restaurant_rounded,
      colorHex: 0xFFFF6B8A,
      type: TransactionType.expense,
    ),
    Category(
      id: 'shopping',
      name: 'Shopping',
      iconData: Icons.shopping_bag_rounded,
      colorHex: 0xFF8B5CF6,
      type: TransactionType.expense,
    ),
    Category(
      id: 'home',
      name: 'Home',
      iconData: Icons.home_rounded,
      colorHex: 0xFFFBBF24,
      type: TransactionType.expense,
    ),
    Category(
      id: 'transport',
      name: 'Transport',
      iconData: Icons.directions_car_rounded,
      colorHex: 0xFF38BDF8,
      type: TransactionType.expense,
    ),
    Category(
      id: 'health',
      name: 'Health',
      iconData: Icons.favorite_rounded,
      colorHex: 0xFFFB7185,
      type: TransactionType.expense,
    ),
    Category(
      id: 'travel',
      name: 'Travel',
      iconData: Icons.flight_takeoff_rounded,
      colorHex: 0xFF34D399,
      type: TransactionType.expense,
    ),
  ];
});

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
