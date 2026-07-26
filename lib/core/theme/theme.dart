import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color ivory = Color(0xFFFFF8F0);
  static const Color champagne = Color(0xFFF4D6B8);
  static const Color blush = Color(0xFFE8A5A5);
  static const Color merlot = Color(0xFF5B1F2E);
  static const Color ink = Color(0xFF211A1D);
  static const Color moss = Color(0xFF667761);
  static const Color gold = Color(0xFFC2954C);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = ink;
  static const Color textSecondary = Color(0xFF7B6F72);

  static const Color mocha = champagne;
  static const Color sand = ivory;
  static const Color sage = moss;
  static const Color emerald = merlot;
  static const Color background = ivory;
}

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.ivory,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.merlot,
        primary: AppColors.merlot,
        secondary: AppColors.gold,
        surface: AppColors.ivory,
      ),
      textTheme: GoogleFonts.cormorantGaramondTextTheme(base.textTheme)
          .copyWith(
            displayLarge: GoogleFonts.cormorantGaramond(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              height: 0.95,
            ),
            displayMedium: GoogleFonts.cormorantGaramond(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
            titleLarge: GoogleFonts.dmSerifDisplay(
              fontSize: 24,
              color: AppColors.ink,
            ),
            titleMedium: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
            bodyLarge: GoogleFonts.manrope(
              fontSize: 16,
              color: AppColors.ink,
              height: 1.45,
            ),
            bodyMedium: GoogleFonts.manrope(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            labelLarge: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.ink,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface.withValues(alpha: 0.92),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: AppColors.champagne.withValues(alpha: 0.7)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.82),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.merlot,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.champagne.withValues(alpha: 0.34),
        selectedColor: AppColors.merlot,
        labelStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide.none,
        ),
      ),
    );
  }
}
