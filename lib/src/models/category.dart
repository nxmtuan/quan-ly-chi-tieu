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
  Icons.local_cafe_rounded,
  Icons.fastfood_rounded,
  Icons.local_grocery_store_rounded,
  Icons.shopping_cart_rounded,
  Icons.checkroom_rounded,
  Icons.apartment_rounded,
  Icons.chair_rounded,
  Icons.lightbulb_rounded,
  Icons.electrical_services_rounded,
  Icons.directions_bus_rounded,
  Icons.train_rounded,
  Icons.local_taxi_rounded,
  Icons.two_wheeler_rounded,
  Icons.medication_rounded,
  Icons.local_hospital_rounded,
  Icons.spa_rounded,
  Icons.sports_esports_rounded,
  Icons.movie_rounded,
  Icons.music_note_rounded,
  Icons.school_rounded,
  Icons.book_rounded,
  Icons.work_rounded,
  Icons.attach_money_rounded,
  Icons.savings_rounded,
  Icons.account_balance_wallet_rounded,
  Icons.card_giftcard_rounded,
  Icons.pets_rounded,
  Icons.child_care_rounded,
  Icons.phone_android_rounded,
  Icons.wifi_rounded,
  Icons.water_drop_rounded,
  Icons.celebration_rounded,
  Icons.volunteer_activism_rounded,
  Icons.receipt_long_rounded,
  Icons.storefront_rounded,
  Icons.fitness_center_rounded,
  Icons.campaign_rounded,
  Icons.park_rounded,
  Icons.security_rounded,
  Icons.emoji_food_beverage_rounded,
];

const categoryColorOptions = [
  Color(0xFF7C3AED),
  Color(0xFF8B5CF6),
  Color(0xFF6366F1),
  Color(0xFF2563EB),
  Color(0xFF0284C7),
  Color(0xFF0891B2),
  Color(0xFF059669),
  Color(0xFF10B981),
  Color(0xFF65A30D),
  Color(0xFFF59E0B),
  Color(0xFFEA580C),
  Color(0xFFEF4444),
  Color(0xFFE11D48),
  Color(0xFFDB2777),
  Color(0xFF6B7280),
  Color(0xFF14B8A6),
  Color(0xFFA16207),
  Color(0xFF9333EA),
  Color(0xFF0F766E),
  Color(0xFFB91C1C),
  Color(0xFF1D4ED8),
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
