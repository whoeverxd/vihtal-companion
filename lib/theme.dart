import 'package:flutter/material.dart';

// Tokens visuales base para la nueva identidad VIHTAL.
class AppColors {
  static const Color background = Color(0xFFF6ECEE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF3E2E6);

  static const Color primary = Color(0xFFD5001A);
  static const Color primaryDark = Color(0xFFB00017);
  static const Color accent = Color(0xFF4D2A2E);

  static const Color textPrimary = Color(0xFF171417);
  static const Color textSecondary = Color(0xFF5E4B4F);

  // Alias para mantener compatibilidad con pantallas ya implementadas.
  static const Color darkCircle = surfaceSoft;
  static const Color subtle = Color(0xFFEACFD6);
  static const Color whiteText = Colors.white;
  static const Color mutedText = textSecondary;
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.primary,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.primaryDark,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    onPrimary: AppColors.whiteText,
    onSecondary: AppColors.whiteText,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 50,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      height: 1.02,
      letterSpacing: -0.4,
    ),
    headlineMedium: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      letterSpacing: -0.3,
    ),
    titleLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -0.2,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 20,
      color: AppColors.accent,
      fontFamily: 'Georgia',
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      color: AppColors.textPrimary,
      height: 1.35,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w600,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.whiteText,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
  ),
);
