import 'package:objectbox/objectbox.dart';

import 'money_source.dart';

enum TransactionType { income, expense }

@Entity()
class Transaction {
  Transaction({
    this.obxId = 0,
    required this.id,
    required this.amount,
    TransactionType? type,
    int? typeCode,
    String? dbType,
    required this.categoryId,
    String? sourceId,
    String? savingsGoalId,
    required this.date,
    String? note,
    DateTime? updatedAt,
    this.isDeleted = false,
  }) : typeCode = type?.index ?? typeCode ?? _legacyTypeCode(dbType),
       dbType = type == null && typeCode == null ? dbType : null,
       sourceId = sourceId ?? defaultMoneySourceId,
       savingsGoalId = _normalizeSavingsGoalId(savingsGoalId),
       note = _normalizeNote(note),
       updatedAt = updatedAt ?? DateTime.now();

  @Id()
  int obxId;

  @Unique()
  String id;

  double amount;

  @Property(type: PropertyType.byte)
  int typeCode;

  String? dbType;

  @Index()
  String categoryId;

  @Index()
  String sourceId;

  @Index()
  String? savingsGoalId;

  @Index()
  @Property(type: PropertyType.date)
  DateTime date;

  String? note;

  @Index()
  @Property(type: PropertyType.date)
  DateTime updatedAt;

  bool isDeleted;

  @Transient()
  TransactionType get type => dbType != null
      ? TransactionType.values.byName(dbType!)
      : TransactionType.values[_normalizedTypeCode(typeCode)];

  bool get isExpense => type == TransactionType.expense;
  bool get hasNote => note != null && note!.isNotEmpty;
  bool get hasSavingsGoal => savingsGoalId != null && savingsGoalId!.isNotEmpty;
  bool get needsStorageCompaction =>
      dbType != null || (note != null && note!.isEmpty);

  Transaction compactedForStorage() {
    return Transaction(
      obxId: obxId,
      id: id,
      amount: amount,
      typeCode: type.index,
      categoryId: categoryId,
      sourceId: sourceId,
      savingsGoalId: savingsGoalId,
      date: date,
      note: note,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }

  Transaction copyWith({
    int? obxId,
    String? id,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? sourceId,
    String? savingsGoalId,
    DateTime? date,
    String? note,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Transaction(
      obxId: obxId ?? this.obxId,
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      sourceId: sourceId ?? this.sourceId,
      savingsGoalId: savingsGoalId ?? this.savingsGoalId,
      date: date ?? this.date,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.name,
      'categoryId': categoryId,
      'sourceId': sourceId,
      'savingsGoalId': savingsGoalId,
      'date': date.toIso8601String(),
      'note': note,
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.byName(json['type'] as String),
      categoryId: json['categoryId'] as String,
      sourceId: json['sourceId'] as String? ?? defaultMoneySourceId,
      savingsGoalId: json['savingsGoalId'] as String?,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }
}

int _legacyTypeCode(String? dbType) {
  if (dbType == TransactionType.income.name) {
    return TransactionType.income.index;
  }

  return TransactionType.expense.index;
}

int _normalizedTypeCode(int typeCode) {
  if (typeCode >= 0 && typeCode < TransactionType.values.length) {
    return typeCode;
  }

  return TransactionType.expense.index;
}

String? _normalizeNote(String? note) {
  if (note == null || note.isEmpty) {
    return null;
  }

  return note;
}

String? _normalizeSavingsGoalId(String? savingsGoalId) {
  if (savingsGoalId == null || savingsGoalId.isEmpty) {
    return null;
  }

  return savingsGoalId;
}
