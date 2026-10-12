import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';

/// Centralized Theme Service responsible for managing Light and Dark themes,
/// persisting theme preference, and notifying listeners throughout the application.
class ThemeService {
  ThemeService._();

  static const String _themePrefKey = 'fiton_app_theme_mode';

  /// ValueNotifier holding current ThemeMode (light or dark)
  static final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  /// Convenient getter for current ThemeMode
  static ThemeMode get currentThemeMode => themeModeNotifier.value;

  /// Returns true if Dark Mode is currently active
  static bool get isDarkMode => themeModeNotifier.value == ThemeMode.dark;

  /// Initializes the theme service by loading saved theme from SharedPreferences
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themePrefKey);
      if (savedTheme == 'dark') {
        themeModeNotifier.value = ThemeMode.dark;
      } else {
        themeModeNotifier.value = ThemeMode.light;
      }
      developer.log(
        'ThemeService initialized with mode: ${themeModeNotifier.value}',
        name: 'ThemeService',
      );
    } catch (e) {
      developer.log(
        'Failed to load theme preference, using default light theme: $e',
        name: 'ThemeService',
      );
      themeModeNotifier.value = ThemeMode.light;
    }

    _applySystemOverlay(isDarkMode);
  }

  /// Sets the theme mode and persists it to SharedPreferences
  static Future<void> setThemeMode(ThemeMode mode) async {
    if (themeModeNotifier.value == mode) return;

    themeModeNotifier.value = mode;
    final isDark = mode == ThemeMode.dark;
    _applySystemOverlay(isDark);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themePrefKey, isDark ? 'dark' : 'light');
      developer.log('Persisted theme mode: ${isDark ? "dark" : "light"}', name: 'ThemeService');
    } catch (e) {
      developer.log('Failed to persist theme preference: $e', name: 'ThemeService');
    }
  }

  /// Toggles between Light and Dark mode
  static Future<void> toggleTheme() async {
    final next = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }

  /// Updates system navigation and status bar styles according to theme
  static void _applySystemOverlay(bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }
}
