import 'package:flutter/material.dart';

/// Centralized color palette for the FitOn Fitness App.
/// Supports both Light Theme and Dark Theme visual palettes while
/// keeping identical component structure, layout, and brand identity.
class AppColors {
  AppColors._();

  // Primary Brand Colors (Consistent across themes)
  static const Color primaryTeal = Color(0xFF006257);
  static const Color primaryTealHover = Color(0xFF004D44);
  static const Color primaryTealLight = Color(0xFF0D9488);
  static const Color logoOrange = Color(0xFFFF4820);
  static const Color logoOrangeDark = Color(0xFFE53912);

  // Light Backgrounds
  static const Color lightBackground = Color(0xFFF8FAFB);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFF1F5F9);

  // Dark Backgrounds
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkCardBackground = Color(0xFF1E293B); // Slate 800
  static const Color darkSurfaceMuted = Color(0xFF243248);
  static const Color darkSubCardBackground = Color(0xFF0B1120);

  // Legacy static aliases (Light default for backwards compatibility)
  static const Color background = Color(0xFFF8FAFB);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9);

  // Light Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Dark navy/slate
  static const Color textSecondary = Color(0xFF64748B); // Slate grey
  static const Color textMuted = Color(0xFF94A3B8); // Light muted grey
  static const Color textWhite = Color(0xFFFFFFFF);

  // Dark Text Colors
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Crisp slate white
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Light slate grey
  static const Color darkTextMuted = Color(0xFF64748B);

  // Badge & Stat Colors
  static const Color badgeBgBlue = Color(0xFFE3EDFE);
  static const Color darkBadgeBgBlue = Color(0xFF1E3A5F);
  static const Color badgeTextBlue = Color(0xFF234C7A);
  static const Color darkBadgeTextBlue = Color(0xFF93C5FD);
  static const Color onlineGreen = Color(0xFF10B981);

  // Feature Card Icon Backgrounds
  static const Color featureTealBg = Color(0xFFC8F3EA);
  static const Color darkFeatureTealBg = Color(0xFF0D3E39);
  static const Color featureTealIcon = Color(0xFF00695C);
  static const Color darkFeatureTealIcon = Color(0xFF2DD4BF);

  static const Color featureGreenBg = Color(0xFF86EFAC);
  static const Color darkFeatureGreenBg = Color(0xFF0E382A);
  static const Color featureGreenIcon = Color(0xFF065F46);
  static const Color darkFeatureGreenIcon = Color(0xFF34D399);

  static const Color featurePeachBg = Color(0xFFF5E4DA);
  static const Color darkFeaturePeachBg = Color(0xFF3D2721);
  static const Color featurePeachIcon = Color(0xFF4C3E3A);
  static const Color darkFeaturePeachIcon = Color(0xFFFDBA74);

  // Social / Community Avatars
  static const Color avatarRed = Color(0xFFDC2626);
  static const Color avatarTeal = Color(0xFF059669);
  static const Color avatarSand = Color(0xFFD8CCBF);
  static const Color darkAvatarSand = Color(0xFF334155);
  static const Color avatarSandText = Color(0xFF334155);
  static const Color darkAvatarSandText = Color(0xFFE2E8F0);

  // Accents & Borders
  static const Color cardBorder = Color(0xFFF1F5F9);
  static const Color darkCardBorder = Color(0xFF334155);
  static const Color shadowColor = Color(0x0C000000);
  static const Color darkShadowColor = Color(0x33000000);
  static const Color buttonGlowColor = Color(0x33006257);

  // Helpers based on dark mode state
  static Color getBackground(bool isDark) => isDark ? darkBackground : lightBackground;
  static Color getCardBackground(bool isDark) => isDark ? darkCardBackground : lightCardBackground;
  static Color getTextPrimary(bool isDark) => isDark ? darkTextPrimary : textPrimary;
  static Color getTextSecondary(bool isDark) => isDark ? darkTextSecondary : textSecondary;
  static Color getTextMuted(bool isDark) => isDark ? darkTextMuted : textMuted;
  static Color getCardBorder(bool isDark) => isDark ? darkCardBorder : cardBorder;
}

/// Helpful BuildContext extension to quickly retrieve theme-aware colors
extension ThemeContextExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  bool get isDark => isDarkMode;

  Color get scaffoldBg => isDarkMode ? AppColors.darkBackground : const Color(0xFFFAFBFD);
  Color get cardBg => isDarkMode ? AppColors.darkCardBackground : Colors.white;
  Color get textPrimary => isDarkMode ? AppColors.darkTextPrimary : const Color(0xFF0F172A);
  Color get textSecondary => isDarkMode ? AppColors.darkTextSecondary : const Color(0xFF64748B);
  Color get textMuted => isDarkMode ? AppColors.darkTextMuted : const Color(0xFF94A3B8);
  Color get cardBorder => isDarkMode ? AppColors.darkCardBorder : const Color(0xFFF1F5F9);
  Color get surfaceMuted => isDarkMode ? AppColors.darkSurfaceMuted : const Color(0xFFF1F5F9);
  Color get subCardBg => isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
  Color get iconColor => isDarkMode ? Colors.white : const Color(0xFF334155);
  Color get inputFillBg => isDarkMode ? const Color(0xFF0F172A) : Colors.white;
  Color get dividerColor => isDarkMode ? AppColors.darkCardBorder : const Color(0xFFEDF2F7);
}
