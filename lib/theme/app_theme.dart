import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static const double radius = 8;

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    fontFamily: 'Manrope',
    scaffoldBackgroundColor: AppColors.surface,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
      headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
    ),
  );
}
