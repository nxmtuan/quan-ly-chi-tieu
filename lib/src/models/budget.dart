import 'dart:math' as math;

import 'package:objectbox/objectbox.dart';

const defaultBudgetWarningPercent = 80.0;

@Entity()
class Budget {
  Budget({
    this.obxId = 0,
    required this.id,
    required this.categoryId,
    required this.limitAmount,
    required DateTime periodStart,
    double? warningPercent,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isDeleted = false,
  }) : periodStart = _monthOnly(periodStart),
       warningPercent = (warningPercent ?? defaultBudgetWarningPercent)
           .clamp(1, 100)
           .toDouble(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  @Id()
  int obxId;

  @Unique()
  String id;

  @Index()
  String categoryId;

  double limitAmount;

  @Index()
  @Property(type: PropertyType.date)
  DateTime periodStart;

  double warningPercent;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  @Index()
  @Property(type: PropertyType.date)
  DateTime updatedAt;

  bool isDeleted;

  @Transient()
  DateTime get periodEnd {
    return DateTime(
      periodStart.year,
      periodStart.month + 1,
    ).subtract(const Duration(milliseconds: 1));
  }

  @Transient()
  double get warningThresholdAmount => limitAmount * warningPercent / 100;

  double progressWith(double spentAmount) {
    if (limitAmount <= 0) {
      return 0;
    }

    return (spentAmount / limitAmount).clamp(0, 1).toDouble();
  }

  double usagePercentWith(double spentAmount) {
    if (limitAmount <= 0) {
      return 0;
    }

    return spentAmount / limitAmount * 100;
  }

  double remainingAmountWith(double spentAmount) {
    return math.max(limitAmount - spentAmount, 0);
  }

  bool isExceededWith(double spentAmount) {
    return spentAmount > limitAmount;
  }

  bool isNearLimitWith(double spentAmount) {
    return !isExceededWith(spentAmount) &&
        spentAmount >= warningThresholdAmount;
  }

  Budget compactedForStorage() {
    return Budget(
      obxId: obxId,
      id: id,
      categoryId: categoryId,
      limitAmount: limitAmount,
      periodStart: periodStart,
      warningPercent: warningPercent,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }

  Budget copyWith({
    int? obxId,
    String? id,
    String? categoryId,
    double? limitAmount,
    DateTime? periodStart,
    double? warningPercent,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Budget(
      obxId: obxId ?? this.obxId,
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limitAmount: limitAmount ?? this.limitAmount,
      periodStart: periodStart ?? this.periodStart,
      warningPercent: warningPercent ?? this.warningPercent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'limitAmount': limitAmount,
      'periodStart': periodStart.toIso8601String(),
      'warningPercent': warningPercent,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      limitAmount: (json['limitAmount'] as num).toDouble(),
      periodStart: DateTime.parse(json['periodStart'] as String),
      warningPercent: (json['warningPercent'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }
}

DateTime _monthOnly(DateTime date) {
  return DateTime(date.year, date.month);
}
