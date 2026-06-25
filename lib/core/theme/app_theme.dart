import 'package:flutter/material.dart';

abstract final class AppColors {
  static const ink = Color(0xFF17212B);
  static const muted = Color(0xFF667085);
  static const canvas = Color(0xFFF6F8F5);
  static const surface = Color(0xFFFFFFFF);
  static const solar = Color(0xFFF4A629);
  static const battery = Color(0xFF1F9D63);
  static const ocean = Color(0xFF1877A8);
  static const danger = Color(0xFFE04F3A);
  static const warning = Color(0xFFE18B16);
  static const line = Color(0xFFE3E8E1);
}

abstract final class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.battery,
      brightness: Brightness.light,
      primary: AppColors.battery,
      secondary: AppColors.solar,
      surface: AppColors.surface,
      error: AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.canvas,
      fontFamily: 'Noto Sans',
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.ink,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: const Color(0xFFE8F4EC),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
        titleLarge: TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink),
        titleMedium: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
        bodyLarge: TextStyle(color: AppColors.ink, height: 1.35),
        bodyMedium: TextStyle(color: AppColors.muted, height: 1.35),
        labelLarge: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}