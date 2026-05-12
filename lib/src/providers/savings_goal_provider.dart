import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/savings_goal.dart';
import '../models/transaction.dart';
import 'storage_provider.dart';
import 'transaction_provider.dart';

class SavingsGoalsNotifier extends Notifier<List<SavingsGoal>> {
  @override
  List<SavingsGoal> build() {
    return _loadVisibleSavingsGoals();
  }

  List<SavingsGoal> _loadVisibleSavingsGoals() {
    final storedGoals = ref
        .read(savingsGoalStorageProvider)
        .readSavingsGoals(includeDeleted: true);
    final normalizedGoals = [
      for (final goal in storedGoals) _normalizeMigratedGoal(goal),
    ];

    if (_needsRewrite(storedGoals, normalizedGoals)) {
      unawaited(
        ref.read(savingsGoalStorageProvider).replaceAllSavingsGoals([
          for (final goal in normalizedGoals) goal.copyWith(),
        ]),
      );
    }

    return [
      for (final goal in normalizedGoals)
        if (!goal.isDeleted) goal,
    ];
  }

  void reload() {
    state = _loadVisibleSavingsGoals();
  }

  Future<void> addGoal(SavingsGoal goal) async {
    final goalToSave = goal.copyWith(updatedAt: DateTime.now());
    state = _sorted([...state, goalToSave]);
    await ref.read(savingsGoalStorageProvider).putSavingsGoal(goalToSave);
  }

  Future<void> updateGoal(SavingsGoal goal) async {
    final goalToSave = goal.copyWith(updatedAt: DateTime.now());
    state = _sorted([
      for (final item in state)
        if (item.id == goal.id) goalToSave else item,
    ]);
    await ref.read(savingsGoalStorageProvider).putSavingsGoal(goalToSave);
  }

  Future<void> deleteGoal(String id) async {
    await ref
        .read(transactionsProvider.notifier)
        .clearSavingsGoalFromTransactions(id);
    state = state.where((goal) => goal.id != id).toList();
    await ref.read(savingsGoalStorageProvider).markSavingsGoalDeleted(id);
  }

  static List<SavingsGoal> _sorted(List<SavingsGoal> goals) {
    return [...goals]..sort((left, right) {
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
    });
  }

  static SavingsGoal _normalizeMigratedGoal(SavingsGoal goal) {
    if (goal.startDate.year >= 2020) {
      return goal;
    }

    final createdAt = goal.createdAt;
    return goal.copyWith(
      startDate: DateTime(createdAt.year, createdAt.month, createdAt.day),
    );
  }

  static bool _needsRewrite(List<SavingsGoal> left, List<SavingsGoal> right) {
    if (left.length != right.length) {
      return true;
    }

    for (var index = 0; index < left.length; index++) {
      if (left[index].startDate != right[index].startDate) {
        return true;
      }
    }

    return false;
  }
}

final savingsGoalsProvider =
    NotifierProvider<SavingsGoalsNotifier, List<SavingsGoal>>(
      SavingsGoalsNotifier.new,
    );

final savingsGoalSavedAmountsProvider = Provider<Map<String, double>>((ref) {
  final transactions = ref.watch(
    transactionsQueryProvider((
      categoryId: null,
      fromDate: null,
      limit: null,
      toDate: null,
      type: TransactionType.expense,
    )),
  );
  final amounts = <String, double>{};

  for (final transaction in transactions) {
    final goalId = transaction.savingsGoalId;
    if (goalId == null || goalId.isEmpty) {
      continue;
    }

    amounts[goalId] = (amounts[goalId] ?? 0) + transaction.amount;
  }

  return amounts;
});
