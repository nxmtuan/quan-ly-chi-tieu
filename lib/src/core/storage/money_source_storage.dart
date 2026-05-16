import '../../../objectbox.g.dart';
import '../../models/money_source.dart';

class MoneySourceStorage {
  const MoneySourceStorage(this._box);

  final Box<MoneySource> _box;

  List<MoneySource> readMoneySources({bool includeDeleted = false}) {
    final query = _box
        .query(includeDeleted ? null : MoneySource_.isDeleted.equals(false))
        .build();
    try {
      return query.find();
    } finally {
      query.close();
    }
  }

  Future<void> replaceAllMoneySources(List<MoneySource> sources) async {
    _box.removeAll();
    for (final source in sources) {
      source.obxId = 0;
    }
    _box.putMany(sources);
  }

  Future<void> clearAll() async {
    _box.removeAll();
  }

  Future<void> putMoneySource(MoneySource source) async {
    final existing = _findById(source.id);
    final sourceToSave = source
        .copyWith(obxId: existing?.obxId ?? source.obxId)
        .compactedForStorage();
    _box.put(sourceToSave);
  }

  Future<void> markMoneySourceDeleted(String id, {DateTime? deletedAt}) async {
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

  MoneySource? _findById(String id) {
    final query = _box.query(MoneySource_.id.equals(id)).build();
    try {
      return query.findFirst();
    } finally {
      query.close();
    }
  }
}
