import 'package:flutter/material.dart';

// Palette basada en la imagen proporcionada (tonos granate/rojo oscuro)
class AppColors {
  static const Color background = Color(0xFF1B0709); // fondo muy oscuro
  static const Color darkCircle = Color(0xFF2E0E12); // círculo oscuro central
  static const Color primary = Color(0xFFD5173F); // rojo/rosa principal (Companion)
  static const Color primaryDark = Color(0xFFB30F30);
  static const Color accent = Color(0xFF7A2A2E); // tono más apagado
  static const Color subtle = Color(0xFF3A1A1D);
  static const Color whiteText = Colors.white;
  static const Color mutedText = Color(0xFF8A2B35);
}

final ThemeData appTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.primary,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.primaryDark,
    surface: AppColors.darkCircle,
    onSurface: AppColors.whiteText,
    onPrimary: AppColors.whiteText,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: AppColors.whiteText),
    headlineMedium: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primary),
    bodyMedium: TextStyle(fontSize: 16, color: AppColors.whiteText),
    labelLarge: TextStyle(fontSize: 14, color: AppColors.mutedText),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.whiteText,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
    ),
  ),
);
