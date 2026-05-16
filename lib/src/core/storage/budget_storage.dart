import '../../../objectbox.g.dart';
import '../../models/budget.dart';

class BudgetStorage {
  const BudgetStorage(this._box);

  final Box<Budget> _box;

  List<Budget> readBudgets({bool includeDeleted = false}) {
    final query = _box
        .query(includeDeleted ? null : Budget_.isDeleted.equals(false))
        .build();
    try {
      final budgets = query.find();
      budgets.sort(_compareBudgets);
      return budgets;
    } finally {
      query.close();
    }
  }

  Future<void> replaceAllBudgets(List<Budget> budgets) async {
    _box.removeAll();
    for (final budget in budgets) {
      budget.obxId = 0;
    }
    _box.putMany(budgets);
  }

  Future<void> clearAll() async {
    _box.removeAll();
  }

  Future<void> putBudget(Budget budget) async {
    final existing = _findById(budget.id);
    final budgetToSave = budget
        .copyWith(
          obxId: existing?.obxId ?? budget.obxId,
          updatedAt: DateTime.now(),
        )
        .compactedForStorage();
    _box.put(budgetToSave);
  }

  Future<void> markBudgetDeleted(String id, {DateTime? deletedAt}) async {
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

  Budget? _findById(String id) {
    final query = _box.query(Budget_.id.equals(id)).build();
    try {
      return query.findFirst();
    } finally {
      query.close();
    }
  }
}

int _compareBudgets(Budget left, Budget right) {
  final periodResult = right.periodStart.compareTo(left.periodStart);
  if (periodResult != 0) {
    return periodResult;
  }

  return right.updatedAt.compareTo(left.updatedAt);
}
