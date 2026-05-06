import 'package:flutter/material.dart';

double adaptiveLayoutScaleForWidth(double width) {
  if (width >= 700) {
    return 1;
  }

  return (width / 460).clamp(0.82, 1.0);
}

extension AdaptiveLayoutContext on BuildContext {
  double get adaptiveScale =>
      adaptiveLayoutScaleForWidth(MediaQuery.sizeOf(this).width);

  double scaled(double value) => value * adaptiveScale;

  double scaledFont(double value, {double min = 11}) {
    return (value * adaptiveScale).clamp(min, double.infinity).toDouble();
  }
}
