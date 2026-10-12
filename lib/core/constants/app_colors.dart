import 'package:flutter/material.dart';
import '../theme/theme_controller.dart';

/// Centralized color palette for the FitOn Fitness App
/// Supports both Light and Dark themes dynamically while maintaining brand fidelity.
class AppColors {
  AppColors._();

  // Primary Brand Colors (Constant across both themes)
  static const Color primaryTeal = Color(0xFF006257);
  static const Color primaryTealHover = Color(0xFF004D44);
  static const Color primaryLight = Color(0xFF14B8A6);
  static const Color logoOrange = Color(0xFFFF4820);
  static const Color logoOrangeDark = Color(0xFFE53912);

  // Static Light Theme Palette
  static const Color lightBackground = Color(0xFFFAFBFD);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFF1F5F9);
  static const Color lightTextPrimary = Color(0xFF0F172A); // Dark navy/slate
  static const Color lightTextSecondary = Color(0xFF64748B); // Slate grey
  static const Color lightTextMuted = Color(0xFF94A3B8); // Light muted grey
  static const Color lightCardBorder = Color(0xFFF1F5F9);
  static const Color lightDivider = Color(0xFFEDF2F7);

  // Static Dark Theme Palette
  static const Color darkBackground = Color(0xFF0F172A); // Deep slate midnight
  static const Color darkCardBackground = Color(0xFF1E293B); // Elevated slate card
  static const Color darkSurfaceMuted = Color(0xFF243046); // Muted surface / container
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Crisp off-white
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Secondary slate grey
  static const Color darkTextMuted = Color(0xFF64748B); // Subtle muted grey
  static const Color darkCardBorder = Color(0xFF334155); // Slate border
  static const Color darkDivider = Color(0xFF334155);

  // Dynamic Getters responding to current Theme
  static bool get isDark => ThemeController.instance.isDarkMode;

  static Color get background => isDark ? darkBackground : lightBackground;
  static Color get cardBackground => isDark ? darkCardBackground : lightCardBackground;
  static Color get surfaceMuted => isDark ? darkSurfaceMuted : lightSurfaceMuted;

  static Color get textPrimary => isDark ? darkTextPrimary : lightTextPrimary;
  static Color get textSecondary => isDark ? darkTextSecondary : lightTextSecondary;
  static Color get textMuted => isDark ? darkTextMuted : lightTextMuted;
  static const Color textWhite = Color(0xFFFFFFFF);

  static Color get cardBorder => isDark ? darkCardBorder : lightCardBorder;
  static Color get border => cardBorder;
  static Color get divider => isDark ? darkDivider : lightDivider;

  static Color get navBarBackground => isDark ? const Color(0xFF111827) : Colors.white;
  static Color get navBarBorder => isDark ? const Color(0xFF1F2937) : const Color(0xFFEDF2F7);

  static Color get inputFill => isDark ? const Color(0xFF243046) : const Color(0xFFF8FAFC);
  static Color get inputBorder => isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

  static Color get iconCircleBg => isDark ? const Color(0xFF243046) : const Color(0xFFEEF2F7);
  static Color get iconCircleColor => isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155);

  // Badge & Stat Colors
  static Color get badgeBgBlue => isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE3EDFE);
  static Color get badgeTextBlue => isDark ? const Color(0xFF93C5FD) : const Color(0xFF234C7A);
  static const Color onlineGreen = Color(0xFF10B981);

  // Feature Card Icon Backgrounds
  static Color get featureTealBg => isDark ? const Color(0xFF0F3934) : const Color(0xFFC8F3EA);
  static Color get featureTealIcon => isDark ? const Color(0xFF5EEAD4) : const Color(0xFF00695C);

  static Color get featureGreenBg => isDark ? const Color(0xFF0E3827) : const Color(0xFF86EFAC);
  static Color get featureGreenIcon => isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46);

  static Color get featurePeachBg => isDark ? const Color(0xFF382A24) : const Color(0xFFF5E4DA);
  static Color get featurePeachIcon => isDark ? const Color(0xFFFDBA74) : const Color(0xFF4C3E3A);

  // Social / Community Avatars
  static const Color avatarRed = Color(0xFFDC2626);
  static const Color avatarTeal = Color(0xFF059669);
  static const Color avatarSand = Color(0xFFD8CCBF);
  static const Color avatarSandText = Color(0xFF334155);

  // Accents & Shadows
  static Color get shadowColor => isDark ? const Color(0x33000000) : const Color(0x0C000000);
  static const Color buttonGlowColor = Color(0x33006257);
}
