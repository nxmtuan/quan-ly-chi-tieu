import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    return _build(
      brightness: Brightness.light,
      primary: AppColors.primary,
      primaryLight: AppColors.primaryLight,
      background: AppColors.background,
      surface: AppColors.surface,
      inputBackground: AppColors.inputBackground,
      textPrimary: AppColors.textPrimary,
      textSecondary: AppColors.textSecondary,
      border: AppColors.border,
      shadow: AppColors.shadow,
    );
  }

  static ThemeData dark() {
    return _build(
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      primaryLight: AppColors.darkPrimaryLight,
      background: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      inputBackground: AppColors.darkInputBackground,
      textPrimary: AppColors.darkTextPrimary,
      textSecondary: AppColors.darkTextSecondary,
      border: AppColors.darkBorder,
      shadow: AppColors.darkShadow,
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required Color primary,
    required Color primaryLight,
    required Color background,
    required Color surface,
    required Color inputBackground,
    required Color textPrimary,
    required Color textSecondary,
    required Color border,
    required Color shadow,
  }) {
    final baseTextTheme = ThemeData(brightness: brightness).textTheme.apply(
      fontFamily: 'BeVietnamPro',
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );
    final textTheme = baseTextTheme;

    return ThemeData(
      useMaterial3: false,
      brightness: brightness,
      fontFamily: 'BeVietnamPro',
      visualDensity: const VisualDensity(horizontal: -0.6, vertical: -0.6),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: Colors.white,
        secondary: AppColors.success,
        onSecondary: Colors.white,
        error: AppColors.danger,
        onError: Colors.white,
        surface: surface,
        onSurface: textPrimary,
        tertiary: primaryLight,
        onTertiary: textPrimary,
        outline: border,
        shadow: shadow,
        inverseSurface: textPrimary,
        onInverseSurface: surface,
        inversePrimary: primary,
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: background,
        foregroundColor: textPrimary,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      splashColor: primary.withValues(alpha: 0.08),
      highlightColor: primary.withValues(alpha: 0.04),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
