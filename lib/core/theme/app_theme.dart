import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _rose = Color(0xFF9D4E62);
  static const _ink = Color(0xFF302A2C);
  static const _paper = Color(0xFFFFF9F6);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _rose,
      brightness: Brightness.light,
      surface: _paper,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _paper,
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: _ink,
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.2,
        ),
        headlineSmall: TextStyle(
          color: _ink,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(color: _ink, fontSize: 16, height: 1.5),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEADDE0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _rose, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
