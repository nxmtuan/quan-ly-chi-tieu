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

    if (storedTransactions.isNotEmpty) {
      return storedTransactions;
    }

    return _initialTransactions();
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

  static List<Transaction> _initialTransactions() {
    return [
      Transaction(
        id: 'tx-1',
        amount: 18000000,
        type: TransactionType.income,
        categoryId: 'salary',
        date: DateTime(2026, 5, 5),
        note: 'Monthly salary',
      ),
      Transaction(
        id: 'tx-2',
        amount: 650000,
        type: TransactionType.expense,
        categoryId: 'food',
        date: DateTime(2026, 5, 4),
        note: 'Groceries',
      ),
      Transaction(
        id: 'tx-3',
        amount: 4500000,
        type: TransactionType.expense,
        categoryId: 'home',
        date: DateTime(2026, 5, 3),
        note: 'Rent',
      ),
      Transaction(
        id: 'tx-4',
        amount: 3200000,
        type: TransactionType.income,
        categoryId: 'freelance',
        date: DateTime(2026, 5, 1),
        note: 'Design project',
      ),
    ];
  }
}

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
