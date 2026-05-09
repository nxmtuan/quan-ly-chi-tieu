import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';

const moneySourceIconOptions = [
  Icons.payments_rounded,
  Icons.account_balance_wallet_rounded,
  Icons.account_balance_rounded,
  Icons.credit_card_rounded,
  Icons.savings_rounded,
  Icons.currency_exchange_rounded,
  Icons.store_rounded,
  Icons.work_rounded,
  Icons.business_center_rounded,
  Icons.sell_rounded,
  Icons.phone_android_rounded,
  Icons.shopping_bag_rounded,
];

const defaultMoneySourceId = 'cash';

bool isDefaultMoneySourceId(String id) => id == defaultMoneySourceId;

@Entity()
class MoneySource {
  MoneySource({
    this.obxId = 0,
    required this.id,
    required this.name,
    IconData? iconData,
    int? dbIconCodePoint,
    DateTime? updatedAt,
    this.isDeleted = false,
  }) : updatedAt = updatedAt ?? DateTime.now() {
    if (iconData != null) {
      this.dbIconCodePoint = iconData.codePoint;
    } else if (dbIconCodePoint != null) {
      this.dbIconCodePoint = dbIconCodePoint;
    } else {
      this.dbIconCodePoint = Icons.account_balance_wallet_rounded.codePoint;
    }
  }

  @Id()
  int obxId;

  @Unique()
  String id;

  String name;

  int dbIconCodePoint = 0;

  @Transient()
  IconData get iconData => _iconFromCodePoint(dbIconCodePoint);

  @Property(type: PropertyType.date)
  DateTime updatedAt;

  bool isDeleted;

  MoneySource compactedForStorage() {
    return MoneySource(
      obxId: obxId,
      id: id,
      name: name,
      dbIconCodePoint: dbIconCodePoint,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }

  MoneySource copyWith({
    int? obxId,
    String? id,
    String? name,
    IconData? iconData,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return MoneySource(
      obxId: obxId ?? this.obxId,
      id: id ?? this.id,
      name: name ?? this.name,
      iconData: iconData ?? this.iconData,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': iconData.codePoint,
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  factory MoneySource.fromJson(Map<String, dynamic> json) {
    return MoneySource(
      id: json['id'] as String,
      name: json['name'] as String,
      dbIconCodePoint: json['iconCodePoint'] as int? ??
          Icons.account_balance_wallet_rounded.codePoint,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }
}

final defaultMoneySources = [
  MoneySource(
    id: defaultMoneySourceId,
    name: 'Tiền mặt',
    iconData: Icons.payments_rounded,
  ),
];

IconData _iconFromCodePoint(int codePoint) {
  for (final iconData in moneySourceIconOptions) {
    if (iconData.codePoint == codePoint) {
      return iconData;
    }
  }

  return Icons.account_balance_wallet_rounded;
}
