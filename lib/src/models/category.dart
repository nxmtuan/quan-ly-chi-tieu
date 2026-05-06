import 'package:flutter/material.dart';

import 'transaction.dart';

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.iconData,
    required this.colorHex,
    required this.type,
  });

  final String id;
  final String name;
  final IconData iconData;
  final int colorHex;
  final TransactionType type;

  Color get color => Color(colorHex);

  Category copyWith({
    String? id,
    String? name,
    IconData? iconData,
    int? colorHex,
    TransactionType? type,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconData: iconData ?? this.iconData,
      colorHex: colorHex ?? this.colorHex,
      type: type ?? this.type,
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
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      iconData: IconData(
        json['iconCodePoint'] as int,
        fontFamily: json['iconFontFamily'] as String?,
        fontPackage: json['iconFontPackage'] as String?,
      ),
      colorHex: json['colorHex'] as int,
      type: TransactionType.values.byName(json['type'] as String),
    );
  }
}
