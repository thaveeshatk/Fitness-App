import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/core/services/theme_service.dart';
import 'package:fitness_app/features/profile/presentation/screens/settings_screen.dart';
import 'package:fitness_app/features/plan/presentation/screens/weekly_schedule_screen.dart';
import 'package:fitness_app/features/plan/presentation/screens/adaptive_dashboard_screen.dart';
import 'package:fitness_app/features/plan/presentation/screens/updated_my_plan_screen.dart';
import 'package:fitness_app/features/plan/presentation/screens/my_plan_screen.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  setUp(() async {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception is NetworkImageLoadException) {
        return;
      }
      FlutterError.presentError(details);
    };
    SharedPreferences.setMockInitialValues({});
    await ThemeService.initialize();
  });

  group('ThemeService & Persistence Tests', () {
    test('Default theme mode is light', () {
      expect(ThemeService.currentThemeMode, ThemeMode.light);
      expect(ThemeService.isDarkMode, isFalse);
    });

    test('Switching to Dark Mode updates notifier and state', () async {
      await ThemeService.setThemeMode(ThemeMode.dark);
      expect(ThemeService.currentThemeMode, ThemeMode.dark);
      expect(ThemeService.isDarkMode, isTrue);
      expect(ThemeService.themeModeNotifier.value, ThemeMode.dark);
    });

    test('Switching to Light Mode updates notifier and state', () async {
      await ThemeService.setThemeMode(ThemeMode.dark);
      await ThemeService.setThemeMode(ThemeMode.light);
      expect(ThemeService.currentThemeMode, ThemeMode.light);
      expect(ThemeService.isDarkMode, isFalse);
      expect(ThemeService.themeModeNotifier.value, ThemeMode.light);
    });

    test('ThemeMode preference persists across app restart/initialize', () async {
      await ThemeService.setThemeMode(ThemeMode.dark);

      // Verify stored in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('fiton_app_theme_mode'), 'dark');

      // Re-initialize ThemeService as if app is reopened
      await ThemeService.initialize();
      expect(ThemeService.currentThemeMode, ThemeMode.dark);
      expect(ThemeService.isDarkMode, isTrue);
    });
  });

  group('ThemeContextExtension Color Verification', () {
    testWidgets('Light theme context extensions return light tokens', (WidgetTester tester) async {
      await ThemeService.setThemeMode(ThemeMode.light);

      late BuildContext testContext;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.light,
          home: Builder(
            builder: (context) {
              testContext = context;
              return const Scaffold(body: Text('Light Mode'));
            },
          ),
        ),
      );

      expect(testContext.isDark, isFalse);
      expect(testContext.scaffoldBg, const Color(0xFFFAFBFD));
      expect(testContext.cardBg, Colors.white);
      expect(testContext.textPrimary, const Color(0xFF0F172A));
      expect(testContext.textSecondary, const Color(0xFF64748B));
      expect(testContext.cardBorder, const Color(0xFFF1F5F9));
    });

    testWidgets('Dark theme context extensions return dark tokens', (WidgetTester tester) async {
      await ThemeService.setThemeMode(ThemeMode.dark);

      late BuildContext testContext;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (context) {
              testContext = context;
              return const Scaffold(body: Text('Dark Mode'));
            },
          ),
        ),
      );

      expect(testContext.isDark, isTrue);
      expect(testContext.scaffoldBg, AppColors.darkBackground);
      expect(testContext.cardBg, AppColors.darkCardBackground);
      expect(testContext.textPrimary, AppColors.darkTextPrimary);
      expect(testContext.textSecondary, AppColors.darkTextSecondary);
      expect(testContext.cardBorder, AppColors.darkCardBorder);
    });
  });

  group('Settings Screen Appearance Integration', () {
    testWidgets('Appearance option exists and allows switching themes in modal', (WidgetTester tester) async {
      await ThemeService.setThemeMode(ThemeMode.light);

      await tester.pumpWidget(
        ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeService.themeModeNotifier,
          builder: (context, mode, _) {
            return MaterialApp(
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              themeMode: mode,
              home: const SettingsScreen(),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      // Find "Appearance" item under PREFERENCES
      final appearanceFinder = find.text('Appearance');
      expect(appearanceFinder, findsOneWidget);

      // Tap on Appearance to open modal
      await tester.tap(appearanceFinder);
      await tester.pumpAndSettle();

      // Verify modal opened with Light and Dark options
      expect(find.text('Choose your preferred app theme'), findsOneWidget);
      expect(find.text('Light Theme'), findsOneWidget);
      expect(find.text('Dark Theme'), findsOneWidget);

      // Tap "Dark Theme"
      await tester.tap(find.text('Dark Theme'));
      await tester.pumpAndSettle();

      // Verify ThemeService has switched to Dark Mode
      expect(ThemeService.currentThemeMode, ThemeMode.dark);
      expect(ThemeService.isDarkMode, isTrue);

      // Verify preference saved in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('fiton_app_theme_mode'), 'dark');
    });
  });

  group('Plan Screens Dark Mode Verification', () {
    testWidgets('WeeklyScheduleScreen renders in Dark Mode with dark theme scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          home: const WeeklyScheduleScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Schedule'), findsOneWidget);
      expect(find.text('Choose your workout days'), findsOneWidget);
      expect(find.text('Save Schedule'), findsOneWidget);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF0F172A));
    });

    testWidgets('AdaptiveDashboardScreen renders in Dark Mode with dark theme scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          home: const AdaptiveDashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Adaptive\nPlan'), findsOneWidget);
      expect(find.text('Continue Updated Plan'), findsOneWidget);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF0F172A));
    });

    testWidgets('UpdatedMyPlanScreen renders in Dark Mode with dark theme scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          home: const UpdatedMyPlanScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Plan'), findsOneWidget);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF0F172A));
    });

    testWidgets('MyPlanScreen renders in Dark Mode with dark theme scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          home: const MyPlanScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Plan'), findsOneWidget);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColors.darkBackground);
    });
  });
}

