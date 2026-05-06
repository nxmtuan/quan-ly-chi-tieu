import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/category.dart';

class CategoryStorage {
  const CategoryStorage(this._preferences);

  static const _categoriesKey = 'categories';

  final SharedPreferences _preferences;

  List<Category> readCategories() {
    final rawCategories = _preferences.getStringList(_categoriesKey);

    if (rawCategories == null) {
      return const [];
    }

    return rawCategories
        .map((rawCategory) => Category.fromJson(jsonDecode(rawCategory)))
        .toList();
  }

  Future<void> saveCategories(List<Category> categories) {
    final rawCategories = categories
        .map((category) => jsonEncode(category.toJson()))
        .toList();

    return _preferences.setStringList(_categoriesKey, rawCategories);
  }
}
