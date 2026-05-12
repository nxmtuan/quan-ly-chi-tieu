import 'dart:math' as math;

import 'package:objectbox/objectbox.dart';

@Entity()
class SavingsGoal {
  SavingsGoal({
    this.obxId = 0,
    required this.id,
    required this.title,
    required this.targetAmount,
    this.savedAmount = 0,
    DateTime? startDate,
    DateTime? deadline,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isDeleted = false,
  }) : startDate = _dateOnly(startDate) ?? _dateOnly(DateTime.now())!,
       deadline = _dateOnly(deadline),
       note = _normalizeNote(note),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  @Id()
  int obxId;

  @Unique()
  String id;

  String title;

  double targetAmount;

  double savedAmount;

  @Index()
  @Property(type: PropertyType.date)
  DateTime startDate;

  @Property(type: PropertyType.date)
  DateTime? deadline;

  String? note;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  @Index()
  @Property(type: PropertyType.date)
  DateTime updatedAt;

  bool isDeleted;

  @Transient()
  double get progress {
    if (targetAmount <= 0) {
      return 0;
    }

    return (savedAmount / targetAmount).clamp(0, 1).toDouble();
  }

  @Transient()
  double get progressPercent => progress * 100;

  @Transient()
  double get remainingAmount => math.max(targetAmount - savedAmount, 0);

  @Transient()
  bool get isCompleted => targetAmount > 0 && savedAmount >= targetAmount;

  bool isCompletedWith(double savedAmount) {
    return targetAmount > 0 && savedAmount >= targetAmount;
  }

  bool isWaitingAt(DateTime now) {
    return startDate.isAfter(_dateOnly(now)!);
  }

  double progressWith(double savedAmount) {
    if (targetAmount <= 0) {
      return 0;
    }

    return (savedAmount / targetAmount).clamp(0, 1).toDouble();
  }

  double remainingAmountWith(double savedAmount) {
    return math.max(targetAmount - savedAmount, 0);
  }

  bool isOverdueAt(DateTime now) {
    final dueDate = deadline;
    if (dueDate == null || isCompleted) {
      return false;
    }

    return dueDate.isBefore(_dateOnly(now)!);
  }

  bool get hasNote => note != null && note!.isNotEmpty;

  SavingsGoal compactedForStorage() {
    return SavingsGoal(
      obxId: obxId,
      id: id,
      title: title,
      targetAmount: targetAmount,
      savedAmount: savedAmount,
      startDate: startDate,
      deadline: deadline,
      note: note,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }

  SavingsGoal copyWith({
    int? obxId,
    String? id,
    String? title,
    double? targetAmount,
    double? savedAmount,
    DateTime? startDate,
    DateTime? deadline,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return SavingsGoal(
      obxId: obxId ?? this.obxId,
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      startDate: startDate ?? this.startDate,
      deadline: deadline ?? this.deadline,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'startDate': startDate.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'] as String,
      title: json['title'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      note: json['note'] as String?,
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

DateTime? _dateOnly(DateTime? date) {
  if (date == null) {
    return null;
  }

  return DateTime(date.year, date.month, date.day);
}

String? _normalizeNote(String? note) {
  final trimmed = note?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }

  return trimmed;
}
