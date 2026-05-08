import 'package:objectbox/objectbox.dart';

enum TransactionType { income, expense }

@Entity()
class Transaction {
  Transaction({
    this.obxId = 0,
    required this.id,
    required this.amount,
    TransactionType? type,
    String? dbType,
    required this.categoryId,
    required this.date,
    required this.note,
  }) {
    if (type != null) {
      _type = type.name;
    } else if (dbType != null) {
      _type = dbType;
    } else {
      _type = TransactionType.expense.name;
    }
  }

  @Id()
  int obxId;

  @Unique()
  String id;

  double amount;

  String _type = 'expense';

  @Transient()
  TransactionType get type => TransactionType.values.byName(_type);

  String get dbType => _type;
  set dbType(String value) => _type = value;

  String categoryId;

  @Property(type: PropertyType.date)
  DateTime date;

  String note;

  bool get isExpense => type == TransactionType.expense;

  Transaction copyWith({
    int? obxId,
    String? id,
    double? amount,
    TransactionType? type,
    String? categoryId,
    DateTime? date,
    String? note,
  }) {
    return Transaction(
      obxId: obxId ?? this.obxId,
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
