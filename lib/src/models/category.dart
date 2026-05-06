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
}
