import 'package:flutter/material.dart';

/// 品牌强调色。这里故意不随明暗主题变化，保证太阳能、电池、用电等语义在
/// 浅色和深色模式下都保持一致。
abstract final class AppColors {
  static const solar = Color(0xFFF4A629);
  static const battery = Color(0xFF1F9D63);
  static const ocean = Color(0xFF1877A8);
  static const danger = Color(0xFFE04F3A);
  static const warning = Color(0xFFE18B16);

  // 浅色主题中使用的中性色。组件应优先从 Theme.of(context) 读取中性色，
  // 这样深色模式才能正确生效。
  static const ink = Color(0xFF17212B);
  static const muted = Color(0xFF667085);
  static const canvas = Color(0xFFF6F8F5);
  static const surface = Color(0xFFFFFFFF);
  static const line = Color(0xFFE3E8E1);
}

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    final canvas = isLight ? const Color(0xFFF6F8F5) : const Color(0xFF0E1419);
    final surface = isLight ? const Color(0xFFFFFFFF) : const Color(0xFF18222B);
    final ink = isLight ? const Color(0xFF17212B) : const Color(0xFFE6EBF0);
    final muted = isLight ? const Color(0xFF667085) : const Color(0xFF9AA7B2);
    final line = isLight ? const Color(0xFFE3E8E1) : const Color(0xFF2A3742);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.battery,
      brightness: brightness,
      primary: AppColors.battery,
      secondary: AppColors.solar,
      surface: surface,
      error: AppColors.danger,
      onSurface: ink,
      outlineVariant: line,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: canvas,
      fontFamily: 'Noto Sans',
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: canvas,
        foregroundColor: ink,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: line),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: isLight
            ? const Color(0xFFE8F4EC)
            : AppColors.battery.withAlpha(46),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            color: ink,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      dividerColor: line,
      textTheme: TextTheme(
        headlineSmall: TextStyle(fontWeight: FontWeight.w800, color: ink),
        titleLarge: TextStyle(fontWeight: FontWeight.w800, color: ink),
        titleMedium: TextStyle(fontWeight: FontWeight.w700, color: ink),
        bodyLarge: TextStyle(color: ink, height: 1.35),
        bodyMedium: TextStyle(color: muted, height: 1.35),
        labelLarge: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
