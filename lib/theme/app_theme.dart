import 'package:flutter/material.dart';

/// Centralized design tokens: colors, gradients, typography, and shared
/// animated widgets used across the Story Reader app.
class AppColors {
  AppColors._();

  // Primary brand palette – a vibrant purple→blue gradient feel.
  static const Color primary = Color(0xFF6A5AE0);
  static const Color primaryDark = Color(0xFF4B3CC0);
  static const Color primaryLight = Color(0xFF9B8DFF);

  // Accent for CTAs and highlights.
  static const Color accent = Color(0xFFFF7AB6);
  static const Color accentAlt = Color(0xFFFFB36B);

  // Neutrals.
  static const Color background = Color(0xFFF6F5FB);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1F1B3A);
  static const Color textSecondary = Color(0xFF6E6A87);
  static const Color divider = Color(0xFFE8E5F2);

  // Semantic.
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Gradient stops.
  static const List<Color> primaryGradient = [
    Color(0xFF6A5AE0),
    Color(0xFF8E7BFF),
  ];
  static const List<Color> sunsetGradient = [
    Color(0xFFFF7AB6),
    Color(0xFFFFB36B),
  ];
  static const List<Color> oceanGradient = [
    Color(0xFF4FACFE),
    Color(0xFF00F2FE),
  ];
  static const List<Color> heroGradient = [
    Color(0xFF6A5AE0),
    Color(0xFF9B8DFF),
    Color(0xFFFF7AB6),
  ];
  static const List<Color> softBackground = [
    Color(0xFFF0EEFF),
    Color(0xFFFFF6F9),
  ];
}

class AppGradients {
  AppGradients._();

  static const LinearGradient primary = LinearGradient(
    colors: AppColors.primaryGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunset = LinearGradient(
    colors: AppColors.sunsetGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient ocean = LinearGradient(
    colors: AppColors.oceanGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient hero = LinearGradient(
    colors: AppColors.heroGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softBackground = LinearGradient(
    colors: AppColors.softBackground,
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppShadows {
  AppShadows._();

  static const BoxShadow soft = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 20,
    offset: Offset(0, 8),
  );

  static const BoxShadow medium = BoxShadow(
    color: Color(0x1F000000),
    blurRadius: 28,
    offset: Offset(0, 12),
  );

  static const BoxShadow glow = BoxShadow(
    color: Color(0x556A5AE0),
    blurRadius: 32,
    offset: Offset(0, 12),
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
          error: AppColors.error,
        );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.6),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        space: 1,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
