import 'package:flutter/material.dart';

import '../utils/adaptive.dart';

class AppTextTokens {
  const AppTextTokens(this.context);

  final BuildContext context;

  ThemeData get _theme => Theme.of(context);
  ColorScheme get _colors => _theme.colorScheme;

  TextStyle get pageEyebrow => TextStyle(
    color: _colors.primary.withValues(alpha: 0.78),
    fontSize: context.scaledFont(14, min: 13),
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  TextStyle get pageTitle => TextStyle(
    color: _colors.onSurface,
    fontSize: context.scaledFont(28, min: 24),
    fontWeight: FontWeight.w700,
    letterSpacing: -0.9,
  );

  TextStyle get pageSubtitle => TextStyle(
    color: _colors.onSurface.withValues(alpha: 0.64),
    fontSize: context.scaledFont(14, min: 13),
    fontWeight: FontWeight.w600,
    height: 1.45,
  );

  TextStyle get sectionTitle => TextStyle(
    color: _colors.onSurface,
    fontSize: context.scaledFont(17, min: 16),
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
  );

  TextStyle get cardTitle => TextStyle(
    color: _colors.onSurface,
    fontSize: context.scaledFont(16, min: 15),
    fontWeight: FontWeight.w700,
  );

  TextStyle get body => TextStyle(
    color: _colors.onSurface,
    fontSize: context.scaledFont(14, min: 14),
    fontWeight: FontWeight.w600,
  );

  TextStyle get bodyStrong => TextStyle(
    color: _colors.onSurface,
    fontSize: context.scaledFont(14, min: 14),
    fontWeight: FontWeight.w700,
  );

  TextStyle get secondary => TextStyle(
    color: _colors.onSurface.withValues(alpha: 0.62),
    fontSize: context.scaledFont(13, min: 12),
    fontWeight: FontWeight.w600,
  );

  TextStyle get secondaryStrong => TextStyle(
    color: _colors.onSurface.withValues(alpha: 0.68),
    fontSize: context.scaledFont(13, min: 12),
    fontWeight: FontWeight.w700,
  );

  TextStyle get caption => TextStyle(
    color: _colors.onSurface.withValues(alpha: 0.58),
    fontSize: context.scaledFont(12, min: 12),
    fontWeight: FontWeight.w600,
  );

  TextStyle get captionStrong => TextStyle(
    color: _colors.onSurface.withValues(alpha: 0.62),
    fontSize: context.scaledFont(12, min: 12),
    fontWeight: FontWeight.w700,
  );

  TextStyle get fieldLabel => TextStyle(
    color: _colors.onSurface.withValues(alpha: 0.68),
    fontSize: context.scaledFont(12, min: 12),
    fontWeight: FontWeight.w700,
  );

  TextStyle get fieldValue => TextStyle(
    color: _colors.onSurface,
    fontSize: context.scaledFont(15, min: 14),
    fontWeight: FontWeight.w800,
  );

  TextStyle get amountXL => TextStyle(
    color: _colors.onSurface,
    fontSize: context.scaledFont(28, min: 24),
    fontWeight: FontWeight.w700,
    letterSpacing: -0.7,
  );

  TextStyle get amountLG => TextStyle(
    color: _colors.onSurface,
    fontSize: context.scaledFont(22, min: 20),
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
  );

  TextStyle get amountMD => TextStyle(
    color: _colors.onSurface,
    fontSize: context.scaledFont(16, min: 15),
    fontWeight: FontWeight.w700,
  );

  TextStyle get buttonLabel => TextStyle(
    color: Colors.white,
    fontSize: context.scaledFont(16, min: 14),
    fontWeight: FontWeight.w700,
    letterSpacing: -0.35,
  );

  TextStyle get navLabel => TextStyle(
    color: _colors.onSurface.withValues(alpha: 0.62),
    fontSize: context.scaledFont(11, min: 11),
    fontWeight: FontWeight.w700,
  );

  TextStyle get sheetTitle => TextStyle(
    color: _colors.onSurface,
    fontSize: context.scaledFont(20, min: 18),
    fontWeight: FontWeight.w700,
    letterSpacing: -0.45,
  );

  TextStyle get sheetSubtitle => TextStyle(
    color: _colors.onSurface.withValues(alpha: 0.6),
    fontSize: context.scaledFont(13, min: 12),
    fontWeight: FontWeight.w700,
  );

  TextStyle get tabLabel => TextStyle(
    color: _colors.onSurface,
    fontSize: context.scaledFont(13, min: 12),
    fontWeight: FontWeight.w700,
  );
}

extension AppTypographyContext on BuildContext {
  AppTextTokens get appText => AppTextTokens(this);
}
