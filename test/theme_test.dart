import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/core/theme/theme_controller.dart';
import 'package:fitness_app/features/profile/presentation/screens/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Theme System Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await ThemeController.instance.initialize();
    });

    test('ThemeController defaults to Light Mode and persists change to Dark Mode', () async {
      final controller = ThemeController.instance;
      expect(controller.themeMode, ThemeMode.light);
      expect(controller.isDarkMode, isFalse);
      expect(AppColors.background, AppColors.lightBackground);
      expect(AppColors.cardBackground, AppColors.lightCardBackground);

      await controller.setThemeMode(ThemeMode.dark);

      expect(controller.themeMode, ThemeMode.dark);
      expect(controller.isDarkMode, isTrue);
      expect(AppColors.background, AppColors.darkBackground);
      expect(AppColors.cardBackground, AppColors.darkCardBackground);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('fiton_theme_mode'), 'dark');

      // Re-initialize controller to verify persistence
      await controller.initialize();
      expect(controller.themeMode, ThemeMode.dark);
      expect(controller.isDarkMode, isTrue);
    });

    test('ThemeController switches back to Light Mode', () async {
      final controller = ThemeController.instance;
      await controller.setThemeMode(ThemeMode.dark);
      expect(controller.isDarkMode, isTrue);

      await controller.setThemeMode(ThemeMode.light);
      expect(controller.themeMode, ThemeMode.light);
      expect(controller.isDarkMode, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('fiton_theme_mode'), 'light');
    });

    testWidgets('SettingsScreen appearance button opens theme modal and updates theme', (tester) async {
      await ThemeController.instance.setThemeMode(ThemeMode.light);

      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find "Appearance" item in Settings
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Theme · Light'), findsOneWidget);

      // Tap on Appearance
      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();

      // Modal bottom sheet should show Theme options
      expect(find.text('Choose how FitOn looks to you'), findsOneWidget);
      expect(find.text('Light Theme'), findsOneWidget);
      expect(find.text('Dark Theme'), findsOneWidget);

      // Tap Dark Theme
      await tester.tap(find.text('Dark Theme'));
      await tester.pumpAndSettle();

      // Modal closes and theme updates
      expect(ThemeController.instance.isDarkMode, isTrue);
      expect(find.text('Theme · Dark'), findsOneWidget);
    });
  });
}
