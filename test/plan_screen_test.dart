import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/features/profile/data/models/profile_model.dart';
import 'package:fitness_app/features/profile/data/services/profile_service.dart';
import 'package:fitness_app/features/plan/data/services/plan_service.dart';
import 'package:fitness_app/features/plan/presentation/screens/my_plan_screen.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  setUp(() {
    PlanService.clearCache();
    ProfileService.clearCache();
  });

  test('PlanService calculates personalized metrics correctly based on user profile', () async {
    const testUid = 'user_plan_metrics_test';
    const profile = ProfileModel(
      fitnessLevel: 'Beginner',
      goals: ['Weight Loss'],
      workoutMinutes: 20,
      equipment: ['Bodyweight Only'],
      weeklyRoutineDays: ['Mon', 'Wed', 'Fri'],
    );
    await ProfileService.saveProfile(profile, docId: testUid);

    final items = await PlanService.getWeeklyPlan(uid: testUid, forceRefresh: true);
    expect(items.length, equals(3));

    final metrics = PlanService.calculateMetrics(items);
    expect(metrics['total'], equals(3));
    expect(metrics['completed'], equals(0));
    expect(metrics['remaining'], equals(3));

    // When a workout is completed
    await PlanService.markWorkoutCompleted(items.first.id, uid: testUid);
    final updatedItems = await PlanService.getWeeklyPlan(uid: testUid, forceRefresh: false);
    final updatedMetrics = PlanService.calculateMetrics(updatedItems);
    expect(updatedMetrics['total'], equals(3));
    expect(updatedMetrics['completed'], equals(1));
    expect(updatedMetrics['remaining'], equals(2));
  });

  test('PlanService generates schedule for M, W, F, Saturday, Sunday (5 days)', () async {
    const testUid = 'user_plan_5_days_test';
    const profile = ProfileModel(
      fitnessLevel: 'Intermediate',
      goals: ['Weight Loss'],
      workoutMinutes: 30,
      equipment: ['Bodyweight Only'],
      weeklyRoutineDays: ['M1', 'W', 'F', 'S1', 'S2'],
    );
    await ProfileService.saveProfile(profile, docId: testUid);

    final items = await PlanService.getWeeklyPlan(uid: testUid, forceRefresh: true);
    expect(items.length, equals(5));

    final dayLabels = items.map((it) => it.dayLabel).toList();
    expect(dayLabels, equals(['MON', 'WED', 'FRI', 'SAT', 'SUN']));

    final assignedWeekdays = items.map((it) => it.assignedWeekday).toList();
    expect(assignedWeekdays, equals([1, 3, 5, 6, 7]));
  });

  testWidgets('MyPlanScreen renders profile plan elements accurately', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception is NetworkImageLoadException) {
        // Ignore network image exceptions in widget test environment
        return;
      }
      FlutterError.presentError(details);
    };

    await tester.pumpWidget(
      const MaterialApp(
        home: MyPlanScreen(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Header checks
    expect(find.text('My Plan'), findsOneWidget);

    // Hero progress card checks
    expect(find.text('YOUR WEEKLY PLAN'), findsOneWidget);
    expect(find.text("You're on track! Keep up the great work."), findsOneWidget);

    // Section title & chips checks
    expect(find.text('Weekly Schedule'), findsOneWidget);

    // Bottom action buttons
    expect(find.text('Continue Plan'), findsOneWidget);
    expect(find.text('View Weekly Schedule'), findsOneWidget);
  });
}
