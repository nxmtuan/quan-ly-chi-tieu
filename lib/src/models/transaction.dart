enum TransactionType { income, expense }

class Transaction {
  const Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    required this.note,
  });

  final String id;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final DateTime date;
  final String note;

  bool get isExpense => type == TransactionType.expense;

  Transaction copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? categoryId,
    DateTime? date,
    String? note,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.name,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.byName(json['type'] as String),
      categoryId: json['categoryId'] as String,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String,
    );
  }
}
