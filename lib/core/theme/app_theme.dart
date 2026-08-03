import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.plum,
          brightness: Brightness.light,
          surface: AppColors.ivory,
        ).copyWith(
          primary: AppColors.plum,
          onPrimary: Colors.white,
          primaryContainer: AppColors.blush,
          onPrimaryContainer: AppColors.deepPlum,
          secondary: AppColors.sage,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.sageSoft,
          onSecondaryContainer: AppColors.deepPlum,
          tertiary: AppColors.warning,
          tertiaryContainer: AppColors.champagneSoft,
          onTertiaryContainer: AppColors.deepPlum,
          error: AppColors.danger,
          errorContainer: AppColors.dangerSoft,
          outline: AppColors.outline,
          onSurface: AppColors.ink,
          onSurfaceVariant: AppColors.softInk,
          surfaceContainerLowest: Colors.white,
          surfaceContainerLow: AppColors.petal,
        );

    const displayFontFallback = <String>['Georgia', 'Times New Roman', 'serif'];
    const uiFontFallback = <String>[
      'Avenir Next',
      'Helvetica Neue',
      'Arial',
      'sans-serif',
    ];

    const displayStyle = TextStyle(
      fontFamily: 'Georgia',
      fontFamilyFallback: displayFontFallback,
      color: AppColors.deepPlum,
      fontWeight: FontWeight.w600,
      height: 1.12,
    );
    const uiStyle = TextStyle(
      fontFamilyFallback: uiFontFallback,
      color: AppColors.ink,
      height: 1.45,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.ivory,
      fontFamilyFallback: uiFontFallback,
      textTheme: TextTheme(
        displayLarge: displayStyle.copyWith(fontSize: 56, letterSpacing: -1.6),
        displayMedium: displayStyle.copyWith(fontSize: 45, letterSpacing: -1.2),
        displaySmall: displayStyle.copyWith(fontSize: 36, letterSpacing: -0.8),
        headlineLarge: displayStyle.copyWith(fontSize: 32, letterSpacing: -0.5),
        headlineMedium: displayStyle.copyWith(
          fontSize: 28,
          letterSpacing: -0.3,
        ),
        headlineSmall: displayStyle.copyWith(fontSize: 24),
        titleLarge: uiStyle.copyWith(
          color: AppColors.deepPlum,
          fontSize: 21,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleMedium: uiStyle.copyWith(
          color: AppColors.plum,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        titleSmall: uiStyle.copyWith(
          color: AppColors.roseDeep,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        bodyLarge: uiStyle.copyWith(fontSize: 16),
        bodyMedium: uiStyle.copyWith(fontSize: 14),
        bodySmall: uiStyle.copyWith(color: AppColors.muted, fontSize: 12.5),
        labelLarge: uiStyle.copyWith(
          color: AppColors.deepPlum,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        labelMedium: uiStyle.copyWith(
          color: AppColors.softInk,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.35,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.ivory,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Georgia',
          fontFamilyFallback: displayFontFallback,
          color: AppColors.deepPlum,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppColors.plum),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.outline),
        ),
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
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.rose, width: 1.5),
        ),
        labelStyle: const TextStyle(
          color: AppColors.softInk,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.roseDeep,
          fontWeight: FontWeight.w700,
        ),
        prefixIconColor: AppColors.roseDeep,
        hintStyle: const TextStyle(color: AppColors.muted),
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
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.plum,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.rose, width: 1.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.roseDeep,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.plum,
        foregroundColor: Colors.white,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.petal,
        selectedColor: AppColors.blush,
        labelStyle: const TextStyle(
          color: AppColors.deepPlum,
          fontWeight: FontWeight.w700,
        ),
        side: const BorderSide(color: AppColors.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.outline),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.roseDeep,
        textColor: AppColors.ink,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.blush,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? AppColors.deepPlum
                : AppColors.muted,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w600,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.deepPlum,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
      iconTheme: const IconThemeData(color: AppColors.plum),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.roseDeep,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
