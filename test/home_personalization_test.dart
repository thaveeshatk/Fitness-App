import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/features/profile/data/models/profile_model.dart';
import 'package:fitness_app/features/profile/data/services/profile_service.dart';
import 'package:fitness_app/features/progress/data/services/user_activity_service.dart';
import 'package:fitness_app/features/home/data/services/recommendation_service.dart';
import 'package:fitness_app/features/workouts/data/repositories/workout_repository.dart';
import 'package:fitness_app/features/workouts/data/models/workout_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Home Page Personalization & Multi-User Verification', () {
    late List<WorkoutModel> allWorkouts;

    setUp(() {
      allWorkouts = WorkoutRepository.getMockWorkouts();
      ProfileService.clearCache();
      UserActivityService.clearCache();
    });

    test('User A (Beginner, Weight Loss, 3-day target) sees their own target and recommendations', () async {
      const userAId = 'user_account_a_beginner';
      final profileA = const ProfileModel(
        fitnessLevel: 'Beginner',
        goals: ['Weight Loss'],
        workoutMinutes: 20,
        equipment: ['Bodyweight Only'],
        weeklyRoutineDays: ['Mon', 'Wed', 'Fri'],
        preferredStyles: ['Cardio', 'HIIT'],
      );

      await ProfileService.saveProfile(profileA, docId: userAId);

      // Verify User A profile loaded
      final loadedProfile = await ProfileService.getProfile(docId: userAId);
      expect(loadedProfile.fitnessLevel, equals('Beginner'));
      expect(loadedProfile.goals, contains('Weight Loss'));
      expect(loadedProfile.weeklyRoutineDays.length, equals(3));

      // Verify initial weekly progress is 0, not fake hardcoded 3/5
      final progressA = await UserActivityService.getWeeklyProgress(uid: userAId);
      expect(progressA['completed'], equals(0));
      expect(progressA['total'], equals(3));
      expect(progressA['activeMinutes'], equals(0));
      expect(progressA['streak'], equals(0));
      expect(progressA['percent'], equals(0));
      expect(progressA['hasActivity'], isFalse);

      // Verify personalized recommendations
      final todaysRecA = RecommendationService.getTodaysRecommendedWorkout(
        profile: loadedProfile,
        allWorkouts: allWorkouts,
      );
      expect(todaysRecA.difficulty, anyOf(equals('Beginner'), equals('Intermediate')));
      expect(todaysRecA.category, equals('Cardio'));

      final recForYouA = RecommendationService.getRecommendedForYou(
        profile: loadedProfile,
        allWorkouts: allWorkouts,
        todaysWorkout: todaysRecA,
      );
      expect(recForYouA.workout.id, isNot(equals(todaysRecA.id)));
      expect(recForYouA.reason, contains('Weight Loss'));

      // Verify quick workouts are populated
      final quickWorkoutsA = RecommendationService.getQuickWorkouts(
        profile: loadedProfile,
        allWorkouts: allWorkouts,
      );
      expect(quickWorkoutsA.length, equals(3));
      for (final q in quickWorkoutsA) {
        expect(q.workout.durationMinutes, lessThanOrEqualTo(25));
      }
    });

    test('User B (Advanced, Build Muscle, 5-day target) has independent target and recommendations', () async {
      const userBId = 'user_account_b_advanced';
      final profileB = const ProfileModel(
        fitnessLevel: 'Advanced',
        goals: ['Build Muscle'],
        workoutMinutes: 45,
        equipment: ['Dumbbells', 'Exercise Mat'],
        weeklyRoutineDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
        preferredStyles: ['Strength'],
      );

      await ProfileService.saveProfile(profileB, docId: userBId);

      final loadedProfileB = await ProfileService.getProfile(docId: userBId);
      expect(loadedProfileB.fitnessLevel, equals('Advanced'));
      expect(loadedProfileB.goals, contains('Build Muscle'));
      expect(loadedProfileB.weeklyRoutineDays.length, equals(5));

      // Weekly target is 5 days
      final progressB = await UserActivityService.getWeeklyProgress(uid: userBId);
      expect(progressB['completed'], equals(0));
      expect(progressB['total'], equals(5));
      expect(progressB['percent'], equals(0));

      // Today recommendation for Advanced Strength
      final todaysRecB = RecommendationService.getTodaysRecommendedWorkout(
        profile: loadedProfileB,
        allWorkouts: allWorkouts,
      );
      expect(todaysRecB.category, equals('Strength'));
      expect(todaysRecB.difficulty, equals('Advanced'));
    });

    test('User A logging a workout does NOT affect User B progress (multi-user isolation)', () async {
      const userAId = 'user_isolation_a';
      const userBId = 'user_isolation_b';

      final profileA = const ProfileModel(
        fitnessLevel: 'Beginner',
        goals: ['Weight Loss'],
        workoutMinutes: 20,
        equipment: ['Bodyweight Only'],
        weeklyRoutineDays: ['Mon', 'Wed', 'Fri'],
      );

      final profileB = const ProfileModel(
        fitnessLevel: 'Advanced',
        goals: ['Build Muscle'],
        workoutMinutes: 45,
        equipment: ['Dumbbells'],
        weeklyRoutineDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
      );

      await ProfileService.saveProfile(profileA, docId: userAId);
      await ProfileService.saveProfile(profileB, docId: userBId);

      // User A logs a completed workout
      await UserActivityService.logCompletedWorkout(
        workoutId: 'w_test_cardio',
        workoutTitle: 'Low Impact Cardio Blast',
        category: 'Cardio',
        durationMinutes: 25,
        calories: 190,
        uid: userAId,
      );

      // Check User A progress: now 1/3, 25m, 1-day streak, 33%
      final progressA = await UserActivityService.getWeeklyProgress(uid: userAId);
      expect(progressA['completed'], equals(1));
      expect(progressA['total'], equals(3));
      expect(progressA['activeMinutes'], equals(25));
      expect(progressA['streak'], equals(1));
      expect(progressA['percent'], equals(33));
      expect(progressA['hasActivity'], isTrue);

      // Check User B progress: MUST STILL BE 0/5, 0m, 0 streak!
      final progressB = await UserActivityService.getWeeklyProgress(uid: userBId);
      expect(progressB['completed'], equals(0));
      expect(progressB['total'], equals(5));
      expect(progressB['activeMinutes'], equals(0));
      expect(progressB['streak'], equals(0));
      expect(progressB['percent'], equals(0));
      expect(progressB['hasActivity'], isFalse);
    });
  });
}
