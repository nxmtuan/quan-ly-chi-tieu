import '../../../objectbox.g.dart';
import '../../models/category.dart';

class CategoryStorage {
  const CategoryStorage(this._box);

  final Box<Category> _box;

  List<Category> readCategories({bool includeDeleted = false}) {
    final query = _box
        .query(includeDeleted ? null : Category_.isDeleted.equals(false))
        .build();
    try {
      return query.find();
    } finally {
      query.close();
    }
  }

  Future<void> replaceAllCategories(List<Category> categories) async {
    _box.removeAll();
    for (final cat in categories) {
      cat.obxId = 0;
    }
    _box.putMany(categories);
  }

  Future<void> clearAll() async {
    _box.removeAll();
  }

  Future<void> putCategory(Category category) async {
    final existing = _findById(category.id);
    final categoryToSave = category
        .copyWith(obxId: existing?.obxId ?? category.obxId)
        .compactedForStorage();
    _box.put(categoryToSave);
  }

  Future<void> markCategoryDeleted(String id, {DateTime? deletedAt}) async {
    final existing = _findById(id);
    if (existing == null) {
      return;
    }

    _box.put(
      existing.copyWith(
        isDeleted: true,
        updatedAt: deletedAt ?? DateTime.now(),
      ),
    );
  }

  Category? _findById(String id) {
    final query = _box.query(Category_.id.equals(id)).build();
    try {
      return query.findFirst();
    } finally {
      query.close();
    }
  }
}
