import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';

import 'transaction.dart';

const categoryIconOptions = [
  Icons.restaurant_rounded,
  Icons.shopping_bag_rounded,
  Icons.home_rounded,
  Icons.directions_car_rounded,
  Icons.favorite_rounded,
  Icons.flight_takeoff_rounded,
  Icons.payments_rounded,
  Icons.laptop_mac_rounded,
  Icons.category_rounded,
];

@Entity()
class Category {
  Category({
    this.obxId = 0,
    required this.id,
    required this.name,
    IconData? iconData,
    int? dbIconCodePoint,
    required this.colorHex,
    TransactionType? type,
    String? dbType,
    DateTime? updatedAt,
    this.isDeleted = false,
  }) : updatedAt = updatedAt ?? DateTime.now() {
    if (iconData != null) {
      _iconCodePoint = iconData.codePoint;
    } else if (dbIconCodePoint != null) {
      _iconCodePoint = dbIconCodePoint;
    } else {
      _iconCodePoint = Icons.category_rounded.codePoint;
    }
    
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

  String name;

  int _iconCodePoint = 0;
  String _type = 'expense';

  @Transient()
  IconData get iconData => _iconFromCodePoint(_iconCodePoint);

  int get dbIconCodePoint => _iconCodePoint;
  set dbIconCodePoint(int value) => _iconCodePoint = value;

  int colorHex;

  @Transient()
  TransactionType get type => TransactionType.values.byName(_type);

  String get dbType => _type;
  set dbType(String value) => _type = value;

  Color get color => Color(colorHex);

  @Property(type: PropertyType.date)
  DateTime updatedAt;

  bool isDeleted;

  Category copyWith({
    int? obxId,
    String? id,
    String? name,
    IconData? iconData,
    int? colorHex,
    TransactionType? type,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Category(
      obxId: obxId ?? this.obxId,
      id: id ?? this.id,
      name: name ?? this.name,
      iconData: iconData ?? this.iconData,
      colorHex: colorHex ?? this.colorHex,
      type: type ?? this.type,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': iconData.codePoint,
      'iconFontFamily': iconData.fontFamily,
      'iconFontPackage': iconData.fontPackage,
      'colorHex': colorHex,
      'type': type.name,
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      iconData: _iconFromCodePoint(json['iconCodePoint'] as int),
      colorHex: json['colorHex'] as int,
      type: TransactionType.values.byName(json['type'] as String),
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

  return Icons.category_rounded;
}
