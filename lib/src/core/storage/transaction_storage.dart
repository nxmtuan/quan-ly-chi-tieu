import '../../../objectbox.g.dart';
import '../../models/transaction.dart';

class TransactionStorage {
  const TransactionStorage(this._box);

  final Box<Transaction> _box;

  List<Transaction> readTransactions({bool includeDeleted = false}) {
    final transactions = _box.getAll();
    final visibleTransactions = includeDeleted
        ? transactions
        : [
            for (final transaction in transactions)
              if (!transaction.isDeleted) transaction,
          ];

    visibleTransactions.sort((a, b) => b.date.compareTo(a.date));
    return visibleTransactions;
  }

  Future<void> replaceAllTransactions(List<Transaction> transactions) async {
    _box.removeAll();
    for (final tx in transactions) {
      tx.obxId = 0;
    }
    _box.putMany(transactions);
  }

  Future<void> putTransaction(Transaction transaction) async {
    final existing = _findById(transaction.id);
    final transactionToSave = transaction.copyWith(
      obxId: existing?.obxId ?? transaction.obxId,
    );
    _box.put(transactionToSave);
  }

  Future<void> markTransactionDeleted(String id, {DateTime? deletedAt}) async {
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

  Future<void> markTransactionsDeletedByCategory(
    String categoryId, {
    DateTime? deletedAt,
  }) async {
    final timestamp = deletedAt ?? DateTime.now();
    final query = _box
        .query(
          Transaction_.categoryId.equals(categoryId) &
              Transaction_.isDeleted.equals(false),
        )
        .build();
    final transactions = query.find();
    query.close();

    if (transactions.isEmpty) {
      return;
    }

    _box.putMany([
      for (final transaction in transactions)
        transaction.copyWith(isDeleted: true, updatedAt: timestamp),
    ]);
  }

  Transaction? _findById(String id) {
    final query = _box.query(Transaction_.id.equals(id)).build();
    final transaction = query.findFirst();
    query.close();
    return transaction;
  }
}
