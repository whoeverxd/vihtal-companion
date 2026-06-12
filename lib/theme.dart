import 'package:flutter/material.dart';

// Tokens visuales de VIHTAL — dirección "clínico y confiable":
// fondos neutros claros, superficies blancas, el rojo del lazo solo como acento.
class AppColors {
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  // Tinte rojo muy suave para círculos de íconos, chips y banners informativos.
  static const Color surfaceSoft = Color(0xFFFBE7EA);

  static const Color primary = Color(0xFFD5001A);
  static const Color primaryDark = Color(0xFFB00017);
  // Tono oscuro neutro para texto sobre superficies suaves (buen contraste).
  static const Color accent = Color(0xFF41484F);

  static const Color textPrimary = Color(0xFF14181F);
  static const Color textSecondary = Color(0xFF5B6573);

  // Borde sutil gris frío para separar tarjetas sobre el fondo claro.
  static const Color border = Color(0xFFE3E7ED);

  // Aliases para mantener compatibilidad con pantallas ya implementadas.
  static const Color darkCircle = surfaceSoft;
  static const Color subtle = border;
  static const Color whiteText = Colors.white;
  static const Color mutedText = textSecondary;
}

/// Sombra suave y consistente para tarjetas elevadas.
const List<BoxShadow> kCardShadow = [
  BoxShadow(
    color: Color(0x0F101828), // ~6% negro azulado
    blurRadius: 16,
    offset: Offset(0, 6),
  ),
];

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
      fontSize: 44,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      height: 1.05,
      letterSpacing: -0.6,
    ),
    headlineMedium: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      letterSpacing: -0.4,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -0.2,
    ),
    titleMedium: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: AppColors.textSecondary,
      height: 1.45,
    ),
    bodyMedium: TextStyle(
      fontSize: 15,
      color: AppColors.textPrimary,
      height: 1.4,
    ),
    labelLarge: TextStyle(
      fontSize: 13,
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    foregroundColor: AppColors.textPrimary,
  ),
  dividerTheme: const DividerThemeData(
    color: AppColors.border,
    thickness: 1,
    space: 1,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.whiteText,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: AppColors.textPrimary,
    contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
