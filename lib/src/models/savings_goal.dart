import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';

import 'category.dart';

const defaultSavingsGoalColorHex = 0xFF0D9488;

@Entity()
class SavingsGoal {
  SavingsGoal({
    this.obxId = 0,
    required this.id,
    required this.title,
    required this.targetAmount,
    this.savedAmount = 0,
    IconData? iconData,
    int? dbIconCodePoint,
    int? colorHex,
    DateTime? startDate,
    DateTime? deadline,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isDeleted = false,
  }) : colorHex = colorHex ?? defaultSavingsGoalColorHex,
       startDate = _dateOnly(startDate) ?? _dateOnly(DateTime.now())!,
       deadline = _dateOnly(deadline),
       note = _normalizeNote(note),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now() {
    if (iconData != null) {
      this.dbIconCodePoint = iconData.codePoint;
    } else if (dbIconCodePoint != null) {
      this.dbIconCodePoint = dbIconCodePoint;
    } else {
      this.dbIconCodePoint = Icons.flag_rounded.codePoint;
    }
  }

  @Id()
  int obxId;

  @Unique()
  String id;

  String title;

  double targetAmount;

  double savedAmount;

  int dbIconCodePoint = 0;

  int colorHex;

  @Transient()
  IconData get iconData => _iconFromCodePoint(dbIconCodePoint);

  @Transient()
  Color get color => Color(colorHex);

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
      dbIconCodePoint: dbIconCodePoint,
      colorHex: colorHex,
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
    IconData? iconData,
    int? colorHex,
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
      iconData: iconData ?? this.iconData,
      colorHex: colorHex ?? this.colorHex,
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
      'iconCodePoint': dbIconCodePoint,
      'colorHex': colorHex,
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
      dbIconCodePoint:
          json['iconCodePoint'] as int? ?? Icons.flag_rounded.codePoint,
      colorHex: json['colorHex'] as int? ?? defaultSavingsGoalColorHex,
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

IconData _iconFromCodePoint(int codePoint) {
  for (final iconData in categoryIconOptions) {
    if (iconData.codePoint == codePoint) {
      return iconData;
    }
  }

  return Icons.flag_rounded;
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
