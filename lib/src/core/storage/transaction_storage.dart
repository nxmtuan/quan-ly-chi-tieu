import '../../../objectbox.g.dart';
import '../../models/transaction.dart';

class TransactionStorage {
  const TransactionStorage(this._box);

  final Box<Transaction> _box;

  List<Transaction> readTransactions({
    bool includeDeleted = false,
    int? limit,
    DateTime? fromDate,
    DateTime? toDate,
    String? categoryId,
    String? sourceId,
    TransactionType? type,
  }) {
    Condition<Transaction>? condition;

    if (!includeDeleted) {
      condition = Transaction_.isDeleted.equals(false);
    }

    if (fromDate != null && toDate != null) {
      condition = _appendCondition(
        condition,
        Transaction_.date.betweenDate(fromDate, toDate),
      );
    } else if (fromDate != null) {
      condition = _appendCondition(
        condition,
        Transaction_.date.greaterOrEqualDate(fromDate),
      );
    } else if (toDate != null) {
      condition = _appendCondition(
        condition,
        Transaction_.date.lessOrEqualDate(toDate),
      );
    }

    if (categoryId != null) {
      condition = _appendCondition(
        condition,
        Transaction_.categoryId.equals(categoryId),
      );
    }

    if (sourceId != null) {
      condition = _appendCondition(
        condition,
        Transaction_.sourceId.equals(sourceId),
      );
    }

    if (type != null) {
      condition = _appendCondition(
        condition,
        Transaction_.typeCode.equals(type.index) |
            Transaction_.dbType.equals(type.name),
      );
    }

    final query = _box
        .query(condition)
        .order(Transaction_.date, flags: Order.descending)
        .build();
    if (limit != null) {
      query.limit = limit;
    }

    try {
      return query.find();
    } finally {
      query.close();
    }
  }

  Future<void> replaceAllTransactions(List<Transaction> transactions) async {
    _box.removeAll();
    for (final tx in transactions) {
      tx.obxId = 0;
    }
    _box.putMany(transactions);
  }

  Future<void> clearAll() async {
    _box.removeAll();
  }

  Future<void> putTransaction(Transaction transaction) async {
    final existing = _findById(transaction.id);
    final transactionToSave = transaction
        .copyWith(obxId: existing?.obxId ?? transaction.obxId)
        .compactedForStorage();
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

  Future<void> reassignTransactionsByCategory(
    String categoryId,
    String replacementCategoryId, {
    DateTime? updatedAt,
  }) async {
    final timestamp = updatedAt ?? DateTime.now();
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
        transaction.copyWith(
          categoryId: replacementCategoryId,
          updatedAt: timestamp,
        ),
    ]);
  }

  Future<void> clearSavingsGoalFromTransactions(
    String savingsGoalId, {
    DateTime? updatedAt,
  }) async {
    final timestamp = updatedAt ?? DateTime.now();
    final query = _box
        .query(
          Transaction_.savingsGoalId.equals(savingsGoalId) &
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
        transaction.copyWith(clearSavingsGoalId: true, updatedAt: timestamp),
    ]);
  }

  Transaction? _findById(String id) {
    final query = _box.query(Transaction_.id.equals(id)).build();
    try {
      return query.findFirst();
    } finally {
      query.close();
    }
  }

  List<DateTime> readTransactionDates({DateTime? fromDate, DateTime? toDate}) {
    Condition<Transaction>? condition = Transaction_.isDeleted.equals(false);

    if (fromDate != null && toDate != null) {
      condition = _appendCondition(
        condition,
        Transaction_.date.betweenDate(fromDate, toDate),
      );
    } else if (fromDate != null) {
      condition = _appendCondition(
        condition,
        Transaction_.date.greaterOrEqualDate(fromDate),
      );
    } else if (toDate != null) {
      condition = _appendCondition(
        condition,
        Transaction_.date.lessOrEqualDate(toDate),
      );
    }

    final query = _box.query(condition).build();
    try {
      final transactions = query.find();
      return [for (final transaction in transactions) transaction.date];
    } finally {
      query.close();
    }
  }

  Future<int> removeTransactionsByIds(Iterable<String> ids) async {
    final idList = ids.toList();
    if (idList.isEmpty) {
      return 0;
    }

    final query = _box.query(Transaction_.id.oneOf(idList)).build();
    try {
      final obxIds = query.findIds();
      if (obxIds.isNotEmpty) {
        return _box.removeMany(obxIds);
      }

      return 0;
    } finally {
      query.close();
    }
  }

  bool hasActiveTransactionsForSource(String sourceId) {
    final query = _box
        .query(
          Transaction_.sourceId.equals(sourceId) &
              Transaction_.isDeleted.equals(false),
        )
        .build();
    try {
      return query.count() > 0;
    } finally {
      query.close();
    }
  }

  Condition<Transaction> _appendCondition(
    Condition<Transaction>? current,
    Condition<Transaction> next,
  ) {
    if (current == null) {
      return next;
    }

    return current & next;
  }
}
