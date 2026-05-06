enum TransactionType { income, expense }

class ExpenseTransaction {
  const ExpenseTransaction({
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
  });

  final String title;
  final String category;
  final int amount;
  final DateTime date;
  final TransactionType type;

  bool get isExpense => type == TransactionType.expense;
}
