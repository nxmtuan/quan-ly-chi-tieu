import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/transaction.dart';

class TransactionStorage {
  const TransactionStorage(this._preferences);

  static const _transactionsKey = 'transactions';

  final SharedPreferences _preferences;

  List<Transaction> readTransactions() {
    final rawTransactions = _preferences.getStringList(_transactionsKey);

    if (rawTransactions == null) {
      return const [];
    }

    return rawTransactions
        .map(
          (rawTransaction) => Transaction.fromJson(jsonDecode(rawTransaction)),
        )
        .toList();
  }

  Future<void> saveTransactions(List<Transaction> transactions) {
    final rawTransactions = transactions
        .map((transaction) => jsonEncode(transaction.toJson()))
        .toList();

    return _preferences.setStringList(_transactionsKey, rawTransactions);
  }
}
