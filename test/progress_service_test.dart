import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/features/progress/data/models/progress_data.dart';
import 'package:fitness_app/features/progress/data/services/progress_service.dart';
import 'package:fitness_app/features/profile/data/models/profile_model.dart';
import 'package:fitness_app/features/workouts/data/models/workout_session.dart';

void main() {
  group('ProgressService Unit Tests (Fixed Clock)', () {
    // Thursday, Oct 8, 2026
    final fixedThursday = DateTime(2026, 10, 8, 10, 30);

    const defaultProfile = ProfileModel(
      fitnessLevel: 'Beginner',
      goals: ['Weight Loss'],
      workoutMinutes: 20,
      equipment: ['Bodyweight Only'],
      weeklyRoutineDays: ['M1', 'W', 'F'], // Mon, Wed, Fri
    );

    test('Brand new user has 0 stats and Getting Started status', () {
      final data = ProgressService.computeProgressData(
        timeframe: ProgressTimeframe.thisWeek,
        now: fixedThursday,
        sessions: [],
        profile: defaultProfile,
      );

      expect(data.completedWorkouts, 0);
      expect(data.activeMinutes, 0);
      expect(data.energyExpendedKcal, 0);
      expect(data.habitStatus, 'Getting Started');
      expect(data.avgHeartRate, 0.0);
      expect(data.milestonePercent, 0);
      expect(data.dailyActivities.length, 7);

      // Verify days are Mon..Sun
      expect(data.dailyActivities[0].day, 'Mon');
      expect(data.dailyActivities[3].day, 'Thu');
      expect(data.dailyActivities[3].isToday, true); // Thursday is today
    });

    test('Computes stats accurately when workouts are logged in current week', () {
      // Mon Oct 5 (20 mins, 150 kcal), Wed Oct 7 (30 mins, 220 kcal)
      final session1 = WorkoutSession(
        id: 's1',
        title: 'Full Body HIIT',
        category: 'Cardio',
        startTime: DateTime(2026, 10, 5, 8, 0),
        endTime: DateTime(2026, 10, 5, 8, 20),
        durationSeconds: 1200,
        calories: 150,
        exercisesCompleted: 6,
      );
      final session2 = WorkoutSession(
        id: 's2',
        title: 'Core Strength',
        category: 'Strength',
        startTime: DateTime(2026, 10, 7, 9, 0),
        endTime: DateTime(2026, 10, 7, 9, 30),
        durationSeconds: 1800,
        calories: 220,
        exercisesCompleted: 6,
      );

      final data = ProgressService.computeProgressData(
        timeframe: ProgressTimeframe.thisWeek,
        now: fixedThursday,
        sessions: [session2, session1],
        profile: defaultProfile,
      );

      expect(data.completedWorkouts, 2);
      expect(data.activeMinutes, 50); // 20 + 30
      expect(data.energyExpendedKcal, 370); // 150 + 220
      expect(data.targetWorkouts, 3); // Mon, Wed, Fri
      expect(data.targetMinutes, 60); // 3 * 20m

      // Monday activity item
      final monItem = data.dailyActivities.firstWhere((d) => d.day == 'Mon');
      expect(monItem.minutes, 20);
      expect(monItem.isTargetReached, true);
      expect(monItem.isRest, false);

      // Wednesday activity item
      final wedItem = data.dailyActivities.firstWhere((d) => d.day == 'Wed');
      expect(wedItem.minutes, 30);
      expect(wedItem.isTargetReached, true);

      // Thursday activity item (Today, no workout yet, rest day in routine)
      final thuItem = data.dailyActivities.firstWhere((d) => d.day == 'Thu');
      expect(thuItem.isToday, true);
      expect(thuItem.minutes, 0);

      // Friday activity item (Future, planned in routine)
      final friItem = data.dailyActivities.firstWhere((d) => d.day == 'Fri');
      expect(friItem.isPlanned, true);
      expect(friItem.isToday, false);
    });

    test('Computes monthly and all-time timeframes properly', () {
      final sessionMonth = WorkoutSession(
        id: 's3',
        title: 'Yoga Flow',
        category: 'Mobility',
        startTime: DateTime(2026, 10, 1, 7, 0),
        endTime: DateTime(2026, 10, 1, 7, 25),
        durationSeconds: 1500,
        calories: 120,
        exercisesCompleted: 5,
      );

      final monthData = ProgressService.computeProgressData(
        timeframe: ProgressTimeframe.thisMonth,
        now: fixedThursday,
        sessions: [sessionMonth],
        profile: defaultProfile,
      );

      expect(monthData.completedWorkouts, 1);
      expect(monthData.activeMinutes, 25);
      expect(monthData.dailyActivities.length, 4); // 4 weeks

      final allTimeData = ProgressService.computeProgressData(
        timeframe: ProgressTimeframe.allTime,
        now: fixedThursday,
        sessions: [sessionMonth],
        profile: defaultProfile,
      );

      expect(allTimeData.completedWorkouts, 1);
      expect(allTimeData.routineWeekLabel, 'All Time');
    });
  });
}
