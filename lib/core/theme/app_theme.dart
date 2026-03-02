import 'package:flutter/material.dart';

/// Material 3 themes for FocusFlow. Calm, focused, professional.
abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
          surface: const Color(0xFFFAFAFA),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        textTheme: _textTheme(Brightness.light),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF818CF8),
          brightness: Brightness.dark,
          surface: const Color(0xFF0F0F0F),
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        textTheme: _textTheme(Brightness.dark),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  static TextTheme _textTheme(Brightness brightness) {
    final base = Typography.material2021().black;
    return base.apply(
      bodyColor: brightness == Brightness.dark ? const Color(0xFFE4E4E7) : const Color(0xFF18181B),
      displayColor: brightness == Brightness.dark ? Colors.white : const Color(0xFF09090B),
    );
  }
}
