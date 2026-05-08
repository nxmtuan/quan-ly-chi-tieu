import 'package:flutter/material.dart';

import '../utils/adaptive.dart';

List<BoxShadow> appSurfaceShadow(BuildContext context) {
  final colors = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return [
    BoxShadow(
      color: colors.shadow.withValues(alpha: isDark ? 0.3 : 0.06),
      blurRadius: context.scaled(isDark ? 12 : 18),
      offset: Offset(0, context.scaled(isDark ? 6 : 8)),
    ),
  ];
}
