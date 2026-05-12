import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction.dart';
import 'storage_provider.dart';

typedef TransactionQueryArgs = ({
  String? categoryId,
  DateTime? fromDate,
  int? limit,
  DateTime? toDate,
  TransactionType? type,
});

class TransactionSummary {
  const TransactionSummary({required this.income, required this.expense});

  final double income;
  final double expense;

  double get balance => income - expense;
}

class TransactionsNotifier extends Notifier<int> {
  @override
  int build() {
    unawaited(_purgeLegacySeedTransactions());
    return 0;
  }

  Future<void> addTransaction(Transaction transaction) async {
    await ref.read(transactionStorageProvider).putTransaction(transaction);
    state++;
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await ref.read(transactionStorageProvider).putTransaction(transaction);
    state++;
  }

  Future<void> deleteTransaction(String id) async {
    await ref.read(transactionStorageProvider).markTransactionDeleted(id);
    state++;
  }

  Future<void> deleteTransactionsByCategory(String categoryId) async {
    await ref
        .read(transactionStorageProvider)
        .markTransactionsDeletedByCategory(categoryId);
    state++;
  }

  Future<void> reassignTransactionsByCategory(
    String categoryId,
    String replacementCategoryId,
  ) async {
    await ref
        .read(transactionStorageProvider)
        .reassignTransactionsByCategory(categoryId, replacementCategoryId);
    state++;
  }

  Future<void> clearSavingsGoalFromTransactions(String savingsGoalId) async {
    await ref
        .read(transactionStorageProvider)
        .clearSavingsGoalFromTransactions(savingsGoalId);
    state++;
  }

  void reload() {
    state++;
  }

  Future<void> _purgeLegacySeedTransactions() async {
    final removedCount = await ref
        .read(transactionStorageProvider)
        .removeTransactionsByIds(_seedTransactionIds);
    if (removedCount > 0) {
      state++;
    }
  }
}

final transactionsProvider = NotifierProvider<TransactionsNotifier, int>(
  TransactionsNotifier.new,
);

final transactionsQueryProvider =
    Provider.family<List<Transaction>, TransactionQueryArgs>((ref, args) {
      ref.watch(transactionsProvider);

      return ref
          .read(transactionStorageProvider)
          .readTransactions(
            categoryId: args.categoryId,
            fromDate: args.fromDate,
            limit: args.limit,
            toDate: args.toDate,
            type: args.type,
          );
    });

final transactionDatesQueryProvider =
    Provider.family<List<DateTime>, ({DateTime? fromDate, DateTime? toDate})>((
      ref,
      args,
    ) {
      ref.watch(transactionsProvider);

      return ref
          .read(transactionStorageProvider)
          .readTransactionDates(fromDate: args.fromDate, toDate: args.toDate);
    });

final allTransactionDatesProvider = Provider<List<DateTime>>((ref) {
  return ref.watch(
    transactionDatesQueryProvider((fromDate: null, toDate: null)),
  );
});

final transactionSummaryProvider =
    Provider.family<TransactionSummary, TransactionQueryArgs>((ref, args) {
      final transactions = ref.watch(transactionsQueryProvider(args));

      final income = transactions
          .where((transaction) => transaction.type == TransactionType.income)
          .fold<double>(0, (total, transaction) => total + transaction.amount);
      final expense = transactions
          .where((transaction) => transaction.type == TransactionType.expense)
          .fold<double>(0, (total, transaction) => total + transaction.amount);

      return TransactionSummary(income: income, expense: expense);
    });

final recentTransactionsProvider = Provider<List<Transaction>>((ref) {
  return ref.watch(
    transactionsQueryProvider((
      categoryId: null,
      fromDate: null,
      limit: 8,
      toDate: null,
      type: null,
    )),
  );
});

final transactionEventsByDayProvider =
    Provider.family<
      Map<DateTime, List<DateTime>>,
      ({DateTime? fromDate, DateTime? toDate})
    >((ref, args) {
      final dates = ref.watch(transactionDatesQueryProvider(args));
      return _buildDateEventIndex(dates);
    });

const _seedTransactionIds = {'tx-1', 'tx-2', 'tx-3', 'tx-4'};

Map<DateTime, List<DateTime>> _buildDateEventIndex(Iterable<DateTime> dates) {
  final eventsByDay = <DateTime, List<DateTime>>{};

  for (final date in dates) {
    final day = DateTime(date.year, date.month, date.day);
    (eventsByDay[day] ??= <DateTime>[]).add(day);
  }

  return eventsByDay;
}
