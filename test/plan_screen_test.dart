import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  test('PlanService calculates wireframe metrics correctly', () async {
    final items = await PlanService.getWeeklyPlan(forceRefresh: true);
    expect(items.length, greaterThanOrEqualTo(5));

    final metrics = PlanService.calculateMetrics(items);
    expect(metrics['total'], 5);
    expect(metrics['completed'], 2); // MON 13 & TUE 14
    expect(metrics['remaining'], 3);
  });

  testWidgets('MyPlanScreen renders wireframe elements accurately', (WidgetTester tester) async {
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
    expect(find.text('Nov 13 – 19'), findsOneWidget);

    // Bottom action buttons
    expect(find.text('Continue Plan'), findsOneWidget);
    expect(find.text('View Weekly Schedule'), findsOneWidget);
  });
}
