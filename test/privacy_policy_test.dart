import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_app/core/theme/theme_controller.dart';
import 'package:fitness_app/features/profile/presentation/screens/settings_screen.dart';
import 'package:fitness_app/features/profile/presentation/screens/privacy_policy_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Privacy Policy Screen Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await ThemeController.instance.initialize();
      await ThemeController.instance.setThemeMode(ThemeMode.light);
    });

    testWidgets('Renders all required privacy sections in Light Mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyPolicyScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header & Hero
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Your Fitness Data is Yours'), findsOneWidget);
      expect(find.text('🛡️ No Ad Selling'), findsOneWidget);

      // Verify Required Content Sections
      expect(find.text('1. User Data Collection'), findsOneWidget);
      expect(find.text('2. Firebase Authentication'), findsOneWidget);
      expect(find.text('3. Personal Profile Information'), findsOneWidget);
      expect(find.text('4. Workout & Fitness Progress Data'), findsOneWidget);
      expect(find.text('5. How Data is Stored and Used'), findsOneWidget);
      expect(find.text('6. Data Security & Architecture'), findsOneWidget);
      expect(find.text('7. Data Sharing & Third-Party Disclosure'), findsOneWidget);
      expect(find.text('8. Users\' Privacy Rights & Controls'), findsOneWidget);
    });

    testWidgets('Renders correctly in Dark Mode', (tester) async {
      await ThemeController.instance.setThemeMode(ThemeMode.dark);

      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyPolicyScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Your Fitness Data is Yours'), findsOneWidget);
      expect(find.text('1. User Data Collection'), findsOneWidget);
    });

    testWidgets('SettingsScreen has Privacy Policy card under Support and navigates properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check Support section contains Privacy Policy
      expect(find.text('SUPPORT'), findsOneWidget);
      final privacyOption = find.text('Privacy Policy');
      expect(privacyOption, findsOneWidget);
      expect(find.text('Data collection & your rights'), findsOneWidget);

      // Tap on Privacy Policy
      await tester.tap(privacyOption);
      await tester.pumpAndSettle();

      // Verify Privacy Policy Screen opened
      expect(find.text('Your Fitness Data is Yours'), findsOneWidget);
      expect(find.text('2. Firebase Authentication'), findsOneWidget);

      // Test Back Button navigation
      final backButton = find.byIcon(Icons.chevron_left_rounded);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verify returned to SettingsScreen
      expect(find.text('SUPPORT'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
    });

    testWidgets('Search bar filters topics dynamically', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyPolicyScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search term
      await tester.enterText(find.byType(TextField), 'Firebase');
      await tester.pumpAndSettle();

      // Firebase Authentication section should be visible
      expect(find.text('2. Firebase Authentication'), findsOneWidget);

      // Other non-matching sections should be hidden
      expect(find.text('4. Workout & Fitness Progress Data'), findsNothing);
    });

    testWidgets('Category chips filter topics dynamically', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PrivacyPolicyScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'Firebase & Auth' category chip
      final chip = find.text('Firebase & Auth');
      expect(chip, findsOneWidget);
      await tester.tap(chip);
      await tester.pumpAndSettle();

      expect(find.text('2. Firebase Authentication'), findsOneWidget);
      expect(find.text('4. Workout & Fitness Progress Data'), findsNothing);
    });
  });
}
