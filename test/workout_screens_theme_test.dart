import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/core/theme/theme_controller.dart';
import 'package:fitness_app/features/workouts/data/models/workout_model.dart';
import 'package:fitness_app/features/workouts/presentation/screens/workout_detail_screen.dart';
import 'package:fitness_app/features/workouts/presentation/screens/activity_screen.dart';
import 'package:fitness_app/features/workouts/presentation/screens/workout_complete_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleWorkout = WorkoutModel(
    id: 'test_workout_1',
    title: 'HIIT Power Shred',
    specificationSubtitle: 'High intensity testing routine',
    coach: 'Coach Alex',
    coachRole: 'Master Trainer',
    coachAvatar: 'https://example.com/avatar.jpg',
    rating: 4.9,
    durationMinutes: 25,
    calories: 320,
    category: 'HIIT',
    subCategory: 'CARDIO & POWER',
    difficulty: 'Intermediate',
    equipment: const ['Bodyweight', 'Dumbbells'],
    tags: const ['HIIT', 'Full Body'],
    imageUrl: 'https://example.com/workout.jpg',
    overview: 'High intensity interval session.',
    exercises: const [
      ExerciseItem(
        id: 'ex_1',
        name: 'Jump Squats',
        phase: 'PHASE: LOWER',
        subtitle: 'Explosive plyometrics',
        badge: '3 sets × 12 reps',
        imageUrl: 'https://example.com/squats.jpg',
      ),
      ExerciseItem(
        id: 'ex_2',
        name: 'Push-ups',
        phase: 'PHASE: UPPER PUSH',
        subtitle: 'Upper body control',
        badge: '3 sets × 10 reps',
        imageUrl: 'https://example.com/pushup.jpg',
      ),
    ],
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ThemeController.instance.initialize();
  });

  group('Workout Screens Dark Theme Tests', () {
    testWidgets('WorkoutDetailScreen renders with dark background in Dark Mode', (tester) async {
      await ThemeController.instance.setThemeMode(ThemeMode.dark);

      await tester.pumpWidget(
        MaterialApp(
          home: WorkoutDetailScreen(workout: sampleWorkout),
        ),
      );
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColors.darkBackground);

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, AppColors.darkBackground);

      expect(find.text('ITEM DETAIL'), findsOneWidget);
      expect(find.text('HIIT Power Shred'), findsOneWidget);
      expect(find.text('SAFETY INFORMATION'), findsOneWidget);
      expect(find.text('Start Workout'), findsOneWidget);
    });

    testWidgets('ActivityScreen renders with dark background and controls in Dark Mode', (tester) async {
      await ThemeController.instance.setThemeMode(ThemeMode.dark);

      await tester.pumpWidget(
        MaterialApp(
          home: ActivityScreen(workout: sampleWorkout),
        ),
      );
      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColors.darkBackground);

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, AppColors.darkBackground);

      expect(find.text('ACTIVITY'), findsOneWidget);
      expect(find.text('[ END ]'), findsOneWidget);
      expect(find.text('EXERCISE PROGRESS'), findsOneWidget);
      expect(find.text('CURRENT EXERCISE'), findsOneWidget);
      expect(find.text('[ NEXT EXERCISE → ]'), findsOneWidget);
      expect(find.text('[ || Pause ]'), findsOneWidget);
      expect(find.text('[ Start / Resume ]'), findsOneWidget);
    });

    testWidgets('WorkoutCompleteScreen renders with dark background and components in Dark Mode', (tester) async {
      await ThemeController.instance.setThemeMode(ThemeMode.dark);

      await tester.pumpWidget(
        const MaterialApp(
          home: WorkoutCompleteScreen(
            workoutTitle: 'HIIT Power Shred',
            durationMinutes: 45,
            caloriesBurned: 420,
            averageHeartRate: 148,
            activeMinutes: 38,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColors.darkBackground);

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, AppColors.darkBackground);

      expect(find.text('Workout Complete!'), findsOneWidget);
      expect(find.text('SESSION FINISHED'), findsOneWidget);
      expect(find.text('DURATION'), findsOneWidget);
      expect(find.text('ACTIVE TIME'), findsOneWidget);
      expect(find.text('ENERGY'), findsOneWidget);
      expect(find.text('HEART RATE'), findsOneWidget);
      expect(find.text('COACH MAYA'), findsOneWidget);
      expect(find.text('View Details'), findsOneWidget);
      expect(find.text('Share Workout'), findsOneWidget);
    });

    testWidgets('WorkoutCompleteScreen dynamically updates when theme toggles', (tester) async {
      await ThemeController.instance.setThemeMode(ThemeMode.light);

      await tester.pumpWidget(
        const MaterialApp(
          home: WorkoutCompleteScreen(
            workoutTitle: 'HIIT Power Shred',
          ),
        ),
      );
      await tester.pumpAndSettle();

      var scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColors.lightBackground);

      // Toggle to dark mode
      await ThemeController.instance.setThemeMode(ThemeMode.dark);
      await tester.pumpAndSettle();

      scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColors.darkBackground);
    });
  });
}
