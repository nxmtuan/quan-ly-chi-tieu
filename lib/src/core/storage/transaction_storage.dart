import '../../../objectbox.g.dart';
import '../../models/transaction.dart';

class TransactionStorage {
  const TransactionStorage(this._box);

  final Box<Transaction> _box;

  List<Transaction> readTransactions() {
    return _box.getAll()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> saveTransactions(List<Transaction> transactions) async {
    _box.removeAll();
    for (final tx in transactions) {
      tx.obxId = 0; // reset for new insertion since we removed all
    }
    _box.putMany(transactions);
  }
}
