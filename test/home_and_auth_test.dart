import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/core/widgets/user_avatar.dart';
import 'package:fitness_app/features/auth/data/services/auth_service.dart';
import 'package:fitness_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:fitness_app/features/home/presentation/screens/home_screen.dart';
import 'package:fitness_app/features/profile/presentation/screens/profile_preferences_screen.dart';

void main() {
  testWidgets('AuthScreen renders login and create account options properly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AuthScreen(initialIsSignUp: false),
      ),
    );

    // Initial Login View
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Log In'), findsWidgets);
    expect(find.text('Create Account'), findsWidgets);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Remember me'), findsOneWidget);

    // Switch to Create Account
    await tester.tap(find.text('Create Account').first);
    await tester.pumpAndSettle();

    expect(find.text('Create Your Account'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
  });

  testWidgets('HomeScreen renders all wireframe elements accurately',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Wireframe Top Header & Greeting
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Good morning, Alex!'), findsOneWidget);
    expect(find.text('Ready to build your daily momentum?'), findsOneWidget);

    // Wireframe "YOUR WORKOUT TODAY"
    expect(find.text('YOUR WORKOUT TODAY'), findsOneWidget);
    expect(find.text('Recommended'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('145 kcal'), findsOneWidget);
    expect(find.text('Day 3 of 5'), findsOneWidget);
    expect(find.text('Full Body Beginner'), findsOneWidget);
    expect(find.text('Start Workout'), findsOneWidget);

    // Wireframe "THIS WEEK'S PROGRESS"
    expect(find.text("THIS WEEK'S PROGRESS"), findsOneWidget);
    expect(find.text('Goal: 5 days'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Active Time'), findsOneWidget);
    expect(find.text('Day Streak'), findsOneWidget);
    expect(find.text('Weekly target'), findsOneWidget);

    // Wireframe "QUICK WORKOUTS"
    expect(find.text('QUICK WORKOUTS'), findsOneWidget);
    expect(find.text('Bite-sized'), findsOneWidget);
    expect(find.text('10 Min Full\nBody'), findsOneWidget);
    expect(find.text('15 Min\nCardio'), findsOneWidget);
    expect(find.text('10 Min\nStretch'), findsOneWidget);

    // Wireframe "RECOMMENDED FOR YOU"
    expect(find.text('RECOMMENDED FOR YOU'), findsOneWidget);
    expect(find.text('Based on activity'), findsOneWidget);
    expect(find.text('Core Starter Routine'), findsOneWidget);
    expect(find.text('Gentle Core • No Equipment'), findsOneWidget);
  });

  testWidgets('ProfilePreferencesScreen renders profile photo card, back button, and logout option',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    bool backPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: ProfilePreferencesScreen(
          onBack: () => backPressed = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Check Profile Photo Card & Change Picture button
    expect(find.text('Change Profile Picture'), findsOneWidget);
    expect(find.text('Alex'), findsOneWidget);

    // Check Back button triggers onBack (which routes to Home)
    final backButton = find.byIcon(Icons.chevron_left_rounded).first;
    await tester.tap(backButton);
    expect(backPressed, isTrue);

    // Scroll down to check Log Out button
    await tester.scrollUntilVisible(
      find.text('Log Out'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Log Out'), findsOneWidget);

    // Tap Log Out and verify confirmation dialog opens
    await tester.tap(find.text('Log Out'));
    await tester.pumpAndSettle();

    expect(find.text('Are you sure you want to log out from FitOn?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('UserAvatar reactively updates when AuthService photo is changed',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: UserAvatar(radius: 20),
        ),
      ),
    );
    await tester.pumpAndSettle();

    const newPhoto = 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=250&auto=format&fit=crop';
    await AuthService.updateProfilePhoto(newPhoto);
    await tester.pumpAndSettle();

    expect(AuthService.currentUser.photoUrl, equals(newPhoto));
  });
}
