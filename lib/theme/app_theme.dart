import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    fontFamily: 'Manrope',
    scaffoldBackgroundColor: AppColors.warmWhite,
    //앱 전체 색상 적용
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),
    //공통 글자 스타일 적용
    textTheme: const TextTheme(
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
    ),
    //앱바 공통 모양 적용
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.warmWhite,
      foregroundColor: AppColors.black,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.warmWhite,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),
  );
}
