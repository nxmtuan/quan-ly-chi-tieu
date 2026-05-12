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
  Icons.local_grocery_store_rounded,
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
  Icons.fitness_center_rounded,
  Icons.park_rounded,
  Icons.security_rounded,
  Icons.ramen_dining_rounded,
  Icons.icecream_rounded,
  Icons.bakery_dining_rounded,
  Icons.local_bar_rounded,
  Icons.nightlife_rounded,
  Icons.local_mall_rounded,
  Icons.sell_rounded,
  Icons.inventory_2_rounded,
  Icons.handyman_rounded,
  Icons.cleaning_services_rounded,
  Icons.bathtub_rounded,
  Icons.local_laundry_service_rounded,
  Icons.ev_station_rounded,
  Icons.local_parking_rounded,
  Icons.directions_boat_rounded,
  Icons.health_and_safety_rounded,
  Icons.psychology_rounded,
  Icons.self_improvement_rounded,
  Icons.sports_soccer_rounded,
  Icons.sports_basketball_rounded,
  Icons.hiking_rounded,
  Icons.photo_camera_rounded,
  Icons.palette_rounded,
  Icons.theater_comedy_rounded,
  Icons.newspaper_rounded,
  Icons.menu_book_rounded,
  Icons.account_balance_rounded,
  Icons.trending_up_rounded,
  Icons.currency_exchange_rounded,
  Icons.subscriptions_rounded,
  Icons.public_rounded,
  Icons.beach_access_rounded,
  Icons.roofing_rounded,
  Icons.forest_rounded,
  Icons.church_rounded,
  Icons.mosque_rounded,
  Icons.temple_buddhist_rounded,
  Icons.local_florist_rounded,
  Icons.brunch_dining_rounded,
  Icons.cottage_rounded,
  Icons.videogame_asset_rounded,
  Icons.auto_awesome_rounded,
];

const categoryColorOptions = [
  Color(0xFF0D9488),
  Color(0xFF2DD4BF),
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
  Color(0xFFEC4899),
  Color(0xFF22C55E),
  Color(0xFF06B6D4),
  Color(0xFF84CC16),
  Color(0xFFF97316),
  Color(0xFFD946EF),
  Color(0xFF3B82F6),
];

const defaultCategoryIds = {
  'food',
  'transport',
  'bills',
  'study',
  'salary',
  'allowance',
  'profit',
};

bool isDefaultCategoryId(String id) => defaultCategoryIds.contains(id);

const uncategorizedExpenseCategoryId = '__uncategorized_expense__';
const uncategorizedIncomeCategoryId = '__uncategorized_income__';

bool isHiddenSystemCategoryId(String id) =>
    id == uncategorizedExpenseCategoryId || id == uncategorizedIncomeCategoryId;

String uncategorizedCategoryIdFor(TransactionType type) {
  return type == TransactionType.expense
      ? uncategorizedExpenseCategoryId
      : uncategorizedIncomeCategoryId;
}

Category? uncategorizedCategoryFromId(String id) {
  return switch (id) {
    uncategorizedExpenseCategoryId => uncategorizedCategoryFor(
      TransactionType.expense,
    ),
    uncategorizedIncomeCategoryId => uncategorizedCategoryFor(
      TransactionType.income,
    ),
    _ => null,
  };
}

Category uncategorizedCategoryFor(TransactionType type) {
  return Category(
    id: uncategorizedCategoryIdFor(type),
    name: 'Chưa phân loại',
    iconData: Icons.category_rounded,
    colorHex: 0xFF6B7280,
    type: type,
  );
}

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
    int? typeCode,
    String? dbType,
    DateTime? updatedAt,
    this.isDeleted = false,
  }) : updatedAt = updatedAt ?? DateTime.now() {
    if (iconData != null) {
      this.dbIconCodePoint = iconData.codePoint;
    } else if (dbIconCodePoint != null) {
      this.dbIconCodePoint = dbIconCodePoint;
    } else {
      this.dbIconCodePoint = Icons.category_rounded.codePoint;
    }

    this.typeCode = type?.index ?? typeCode ?? _legacyCategoryTypeCode(dbType);
    this.dbType = type == null && typeCode == null ? dbType : null;
  }

  @Id()
  int obxId;

  @Unique()
  String id;

  String name;

  int dbIconCodePoint = 0;
  @Property(type: PropertyType.byte)
  late int typeCode;

  String? dbType;

  @Transient()
  IconData get iconData => _iconFromCodePoint(dbIconCodePoint);

  int colorHex;

  @Transient()
  TransactionType get type => dbType != null
      ? TransactionType.values.byName(dbType!)
      : TransactionType.values[_normalizedCategoryTypeCode(typeCode)];

  Color get color => Color(colorHex);

  @Property(type: PropertyType.date)
  DateTime updatedAt;

  bool isDeleted;
  bool get needsStorageCompaction => dbType != null;

  Category compactedForStorage() {
    return Category(
      obxId: obxId,
      id: id,
      name: name,
      dbIconCodePoint: dbIconCodePoint,
      colorHex: colorHex,
      typeCode: type.index,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }

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

int _legacyCategoryTypeCode(String? dbType) {
  if (dbType == TransactionType.income.name) {
    return TransactionType.income.index;
  }

  return TransactionType.expense.index;
}

int _normalizedCategoryTypeCode(int typeCode) {
  if (typeCode >= 0 && typeCode < TransactionType.values.length) {
    return typeCode;
  }

  return TransactionType.expense.index;
}
