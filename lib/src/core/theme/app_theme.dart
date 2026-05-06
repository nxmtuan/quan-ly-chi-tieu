import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final textTheme = GoogleFonts.plusJakartaSansTextTheme().apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.light,
      primaryColor: AppColors.lavender,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lavender,
        secondary: AppColors.mint,
        surface: AppColors.surface,
        error: AppColors.coral,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      splashColor: AppColors.lavender.withValues(alpha: 0.08),
      highlightColor: AppColors.lavender.withValues(alpha: 0.04),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
