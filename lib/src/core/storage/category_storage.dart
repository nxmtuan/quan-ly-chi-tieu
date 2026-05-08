import '../../../objectbox.g.dart';
import '../../models/category.dart';

class CategoryStorage {
  const CategoryStorage(this._box);

  final Box<Category> _box;

  List<Category> readCategories() {
    return _box.getAll();
  }

  Future<void> saveCategories(List<Category> categories) async {
    _box.removeAll();
    for (final cat in categories) {
      cat.obxId = 0; // reset for new insertion since we removed all
    }
    _box.putMany(categories);
  }
}
