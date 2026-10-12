import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Application Theme Configuration using Material 3
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryTeal,
        onPrimary: AppColors.textWhite,
        secondary: AppColors.logoOrange,
        surface: AppColors.lightCardBackground,
        onSurface: AppColors.lightTextPrimary,
        error: Colors.redAccent,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.lightCardBackground,
        elevation: 0,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: AppColors.lightTextSecondary,
          fontSize: 16,
          height: 1.45,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.lightTextSecondary,
          fontSize: 14,
          height: 1.4,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: AppColors.lightTextMuted,
          fontSize: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryTeal,
          foregroundColor: AppColors.textWhite,
          elevation: 0,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryTeal,
        onPrimary: AppColors.textWhite,
        secondary: AppColors.logoOrange,
        surface: AppColors.darkCardBackground,
        onSurface: AppColors.darkTextPrimary,
        error: Colors.redAccent,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.darkCardBackground,
        elevation: 0,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: AppColors.darkTextSecondary,
          fontSize: 16,
          height: 1.45,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.darkTextSecondary,
          fontSize: 14,
          height: 1.4,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: AppColors.darkTextMuted,
          fontSize: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryTeal,
          foregroundColor: AppColors.textWhite,
          elevation: 0,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
