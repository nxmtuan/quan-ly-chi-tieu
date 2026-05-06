import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction.dart';
import 'storage_provider.dart';

class TransactionSummary {
  const TransactionSummary({required this.income, required this.expense});

  final double income;
  final double expense;

  double get balance => income - expense;
}

class TransactionsNotifier extends Notifier<List<Transaction>> {
  @override
  List<Transaction> build() {
    final storedTransactions = ref
        .read(transactionStorageProvider)
        .readTransactions();
    final filteredTransactions = _removeSeedTransactions(storedTransactions);

    if (filteredTransactions.length != storedTransactions.length) {
      unawaited(
        ref
            .read(transactionStorageProvider)
            .saveTransactions(filteredTransactions),
      );
    }

    return filteredTransactions;
  }

  Future<void> addTransaction(Transaction transaction) async {
    final updatedTransactions = [transaction, ...state]
      ..sort((a, b) => b.date.compareTo(a.date));

    state = updatedTransactions;
    await _save();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final updatedTransactions = [
      for (final item in state)
        if (item.id == transaction.id) transaction else item,
    ]..sort((a, b) => b.date.compareTo(a.date));

    state = updatedTransactions;
    await _save();
  }

  Future<void> deleteTransaction(String id) async {
    state = state.where((transaction) => transaction.id != id).toList();
    await _save();
  }

  Future<void> deleteTransactionsByCategory(String categoryId) async {
    state = state
        .where((transaction) => transaction.categoryId != categoryId)
        .toList();
    await _save();
  }

  Future<void> _save() {
    return ref.read(transactionStorageProvider).saveTransactions(state);
  }

  static List<Transaction> _removeSeedTransactions(
    List<Transaction> transactions,
  ) {
    return [
      for (final transaction in transactions)
        if (!_seedTransactionIds.contains(transaction.id)) transaction,
    ];
  }
}

const _seedTransactionIds = {'tx-1', 'tx-2', 'tx-3', 'tx-4'};

final transactionsProvider =
    NotifierProvider<TransactionsNotifier, List<Transaction>>(
      TransactionsNotifier.new,
    );

final transactionSummaryProvider = Provider<TransactionSummary>((ref) {
  final transactions = ref.watch(transactionsProvider);

  final income = transactions
      .where((transaction) => transaction.type == TransactionType.income)
      .fold<double>(0, (total, transaction) => total + transaction.amount);
  final expense = transactions
      .where((transaction) => transaction.type == TransactionType.expense)
      .fold<double>(0, (total, transaction) => total + transaction.amount);

  return TransactionSummary(income: income, expense: expense);
});

final recentTransactionsProvider = Provider<List<Transaction>>((ref) {
  return ref.watch(transactionsProvider).take(8).toList();
});
