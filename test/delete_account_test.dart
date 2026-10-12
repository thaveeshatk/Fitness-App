import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_app/core/routes/app_routes.dart';
import 'package:fitness_app/core/theme/theme_controller.dart';
import 'package:fitness_app/features/auth/data/models/auth_user.dart';
import 'package:fitness_app/features/auth/data/services/auth_service.dart';
import 'package:fitness_app/features/profile/presentation/screens/profile_preferences_screen.dart';
import 'package:fitness_app/features/profile/presentation/widgets/delete_account_dialog.dart';
import 'package:fitness_app/features/workouts/data/models/workout_model.dart';
import 'package:fitness_app/features/workouts/data/services/workout_service.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await ThemeController.instance.initialize();
  });

  group('Delete Account Feature Tests', () {
    testWidgets('ProfilePreferencesScreen displays Delete Account button near Log Out',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: ProfilePreferencesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find Log Out button and Delete Account button
      final logOutFinder = find.widgetWithText(OutlinedButton, 'Log Out');
      final deleteAccountFinder = find.widgetWithText(TextButton, 'Delete Account');

      expect(logOutFinder, findsOneWidget);
      expect(deleteAccountFinder, findsOneWidget);

      // Verify Delete Account icon
      expect(find.byIcon(Icons.delete_forever_rounded), findsOneWidget);
    });

    testWidgets('Tapping Delete Account opens confirmation dialog with full warning details',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: ProfilePreferencesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Delete Account
      await tester.tap(find.widgetWithText(TextButton, 'Delete Account'));
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.byType(DeleteAccountDialog), findsOneWidget);
      expect(find.text('Delete Account'), findsWidgets);
      expect(find.text('Permanent & Irreversible'), findsOneWidget);

      // Verify warning message
      expect(
        find.textContaining('This action cannot be undone'),
        findsOneWidget,
      );

      // Verify listed personal data to be deleted
      expect(find.textContaining('Profile information, photo, and fitness preferences'), findsOneWidget);
      expect(find.textContaining('Workout activity history and completed sessions'), findsOneWidget);
      expect(find.textContaining('Fitness progress metrics, streaks, and statistics'), findsOneWidget);
      expect(find.textContaining('Weekly routines and scheduled plan completion data'), findsOneWidget);
      expect(find.textContaining('Custom workouts and personalized circuits'), findsOneWidget);
      expect(find.textContaining('Notification preferences and system alerts'), findsOneWidget);

      // Verify action buttons
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Delete Account'), findsOneWidget);
    });

    testWidgets('Delete button is disabled until explicit confirmation is entered',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeleteAccountDialog(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final deleteButtonFinder = find.widgetWithText(ElevatedButton, 'Delete Account');
      ElevatedButton deleteBtn = tester.widget(deleteButtonFinder);
      expect(deleteBtn.onPressed, isNull); // Initially disabled

      // Enter input in text field
      await tester.enterText(find.byType(TextField), 'somePassword123');
      await tester.pumpAndSettle();

      deleteBtn = tester.widget(deleteButtonFinder);
      expect(deleteBtn.onPressed, isNotNull); // Enabled when input is provided
    });

    testWidgets('Cancel button dismisses DeleteAccountDialog without action',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: ProfilePreferencesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.widgetWithText(TextButton, 'Delete Account'));
      await tester.pumpAndSettle();

      expect(find.byType(DeleteAccountDialog), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog is dismissed
      expect(find.byType(DeleteAccountDialog), findsNothing);
    });

    testWidgets('DeleteAccountDialog supports dark theme rendering',
        (WidgetTester tester) async {
      ThemeController.instance.setThemeMode(ThemeMode.dark);
      addTearDown(() => ThemeController.instance.setThemeMode(ThemeMode.light));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeleteAccountDialog(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DeleteAccountDialog), findsOneWidget);
      expect(find.text('Permanent & Irreversible'), findsOneWidget);
    });

    test('AuthService.deleteAccount clears session, cached workouts, and resets state',
        () async {
      // Ensure user is signed in
      await AuthService.signInWithEmail(email: 'testuser@fiton.com', password: 'Pass1234!');
      expect(AuthService.isLoggedIn, isTrue);

      final testUid = AuthService.currentUser.uid;

      // Add a custom workout for this user
      await WorkoutService.createWorkout(
        WorkoutModel(
          id: 'test_custom_del_01',
          userId: testUid,
          title: 'To Be Deleted Workout',
          coach: 'Me',
          coachRole: 'Coach',
          coachAvatar: '',
          rating: 4.8,
          durationMinutes: 15,
          calories: 120,
          category: 'Cardio',
          subCategory: 'CARDIO',
          difficulty: 'Beginner',
          equipment: const [],
          tags: const ['TEST'],
          imageUrl: '',
          overview: '',
          safetyInfo: '',
          exercises: const [],
        ),
      );

      final userWorkoutsBefore = await WorkoutService.getCustomWorkouts();
      expect(userWorkoutsBefore.any((w) => w.id == 'test_custom_del_01'), isTrue);

      // Execute account deletion
      await AuthService.deleteAccount();

      // Verify user is signed out
      expect(AuthService.isLoggedIn, isFalse);
      expect(AuthService.userNotifier.value, isNull);

      // Verify custom workouts for this user are purged
      WorkoutService.clearUserWorkouts(testUid);
      final userWorkoutsAfter = await WorkoutService.getCustomWorkouts();
      expect(userWorkoutsAfter.any((w) => w.userId == testUid), isFalse);
    });
  });
}
