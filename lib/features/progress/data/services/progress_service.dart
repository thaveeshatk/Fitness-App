import '../models/progress_data.dart';

class ProgressService {
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();

  static ProgressService get instance => _instance;

  static ProgressData getProgressData(ProgressTimeframe timeframe) {
    switch (timeframe) {
      case ProgressTimeframe.thisWeek:
        return const ProgressData(
          habitStatus: 'On Track • Consistent',
          habitConsistencyPercent: 80,
          habitCompletedDays: 4,
          habitScheduledDays: 5,
          totalWorkouts: 4,
          totalMinutes: 145,
          totalCalories: 1120,
          avgHeartRate: 126.0,
        );
      case ProgressTimeframe.lastWeek:
        return const ProgressData(
          habitStatus: 'Optimal • 100%',
          habitConsistencyPercent: 100,
          habitCompletedDays: 5,
          habitScheduledDays: 5,
          totalWorkouts: 5,
          totalMinutes: 180,
          totalCalories: 1450,
          avgHeartRate: 130.0,
        );
      case ProgressTimeframe.thisMonth:
      case ProgressTimeframe.allTime:
        return const ProgressData(
          habitStatus: 'High Performer',
          habitConsistencyPercent: 88,
          habitCompletedDays: 18,
          habitScheduledDays: 20,
          totalWorkouts: 18,
          totalMinutes: 620,
          totalCalories: 4800,
          avgHeartRate: 125.0,
        );
    }
  }
}
