import '../../../objectbox.g.dart';
import '../../models/savings_goal.dart';

class SavingsGoalStorage {
  const SavingsGoalStorage(this._box);

  final Box<SavingsGoal> _box;

  List<SavingsGoal> readSavingsGoals({bool includeDeleted = false}) {
    final query = _box
        .query(includeDeleted ? null : SavingsGoal_.isDeleted.equals(false))
        .build();
    try {
      final goals = query.find();
      goals.sort(_compareGoals);
      return goals;
    } finally {
      query.close();
    }
  }

  Future<void> replaceAllSavingsGoals(List<SavingsGoal> goals) async {
    _box.removeAll();
    for (final goal in goals) {
      goal.obxId = 0;
    }
    _box.putMany(goals);
  }

  Future<void> clearAll() async {
    _box.removeAll();
  }

  Future<void> putSavingsGoal(SavingsGoal goal) async {
    final existing = _findById(goal.id);
    final goalToSave = goal
        .copyWith(
          obxId: existing?.obxId ?? goal.obxId,
          updatedAt: DateTime.now(),
        )
        .compactedForStorage();
    _box.put(goalToSave);
  }

  Future<void> markSavingsGoalDeleted(String id, {DateTime? deletedAt}) async {
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

  SavingsGoal? _findById(String id) {
    final query = _box.query(SavingsGoal_.id.equals(id)).build();
    try {
      return query.findFirst();
    } finally {
      query.close();
    }
  }
}

int _compareGoals(SavingsGoal left, SavingsGoal right) {
  if (left.isCompleted != right.isCompleted) {
    return left.isCompleted ? 1 : -1;
  }

  final leftDeadline = left.deadline;
  final rightDeadline = right.deadline;
  if (leftDeadline != null && rightDeadline != null) {
    final result = leftDeadline.compareTo(rightDeadline);
    if (result != 0) {
      return result;
    }
  } else if (leftDeadline != null) {
    return -1;
  } else if (rightDeadline != null) {
    return 1;
  }

  return right.updatedAt.compareTo(left.updatedAt);
}
