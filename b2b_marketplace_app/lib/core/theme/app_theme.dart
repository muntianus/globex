
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1F5BFF);
  static const Color secondary = Color(0xFFFFD500);
  static const Color neutralDark = Color(0xFF0A0A0A);
  static const Color neutralLight = Color(0xFFF7F7F7);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.neutralLight,
      onSurface: AppColors.neutralDark,
    ),
    scaffoldBackgroundColor: AppColors.neutralLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.neutralLight,
      foregroundColor: AppColors.neutralDark,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400, color: AppColors.neutralDark),
      displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400, color: AppColors.neutralDark),
      displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400, color: AppColors.neutralDark),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400, color: AppColors.neutralDark),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, color: AppColors.neutralDark),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: AppColors.neutralDark),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w400, color: AppColors.neutralDark),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.neutralDark),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.neutralDark),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.neutralDark),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.neutralDark),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.neutralDark),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.neutralDark),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.neutralDark),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.neutralDark),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.neutralDark,
      onSurface: AppColors.neutralLight,
    ),
    scaffoldBackgroundColor: AppColors.neutralDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.neutralDark,
      foregroundColor: AppColors.neutralLight,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400, color: AppColors.neutralLight),
      displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400, color: AppColors.neutralLight),
      displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400, color: AppColors.neutralLight),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400, color: AppColors.neutralLight),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, color: AppColors.neutralLight),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: AppColors.neutralLight),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w400, color: AppColors.neutralLight),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.neutralLight),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.neutralLight),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.neutralLight),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.neutralLight),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.neutralLight),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.neutralLight),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.neutralLight),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.neutralLight),
    ),
  );
}
