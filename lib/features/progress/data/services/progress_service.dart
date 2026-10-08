import '../models/progress_data.dart';
import 'dart:math';

class ProgressService {
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();

  static ProgressService get instance => _instance;

  static ProgressData getProgressData(ProgressTimeframe timeframe) {
    switch (timeframe) {
      case ProgressTimeframe.thisWeek:
        return ProgressData(
          habitStatus: 'On Track • Consistent',
          habitConsistencyPercent: 80,
          habitCompletedDays: 4,
          habitScheduledDays: 5,
          totalWorkouts: 4,
          totalMinutes: 145,
          totalCalories: 1120,
          avgHeartRate: 126.0,
          energyExpendedKcal: 1120,
          energyVsLastWeekPercent: 12,
          activeMinutes: 145,
          completedWorkouts: 4,
          targetWorkouts: 5,
          targetMinutes: 180,
          restDayMessage: 'Tomorrow is your gentle stretch day. Take it easy and recharge!',
          routineTitle: 'Gentle Rhythm • Step By Step',
          routineWeekLabel: 'Week 3',
          dailyActivities: _getDynamicThisWeekActivities(),
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
          energyExpendedKcal: 1450,
          energyVsLastWeekPercent: 8,
          activeMinutes: 180,
          completedWorkouts: 5,
          targetWorkouts: 5,
          targetMinutes: 180,
          restDayMessage: 'Perfect week! You hit every scheduled session.',
          routineTitle: 'Gentle Rhythm • Step By Step',
          routineWeekLabel: 'Week 2',
          dailyActivities: [
            DailyActivityItem(day: 'Mon', dayName: 'Mon', minutes: 30, isTargetReached: true),
            DailyActivityItem(day: 'Tue', dayName: 'Tue', minutes: 35, isTargetReached: true),
            DailyActivityItem(day: 'Wed', dayName: 'Wed', minutes: 28, isTargetReached: true),
            DailyActivityItem(day: 'Thu', dayName: 'Thu', minutes: 0, isRest: true),
            DailyActivityItem(day: 'Fri', dayName: 'Fri', minutes: 40, isTargetReached: true),
            DailyActivityItem(day: 'Sat', dayName: 'Sat', minutes: 25, isTargetReached: true),
            DailyActivityItem(day: 'Sun', dayName: 'Sun', minutes: 0, isRest: true),
          ],
        );
      case ProgressTimeframe.thisMonth:
        return const ProgressData(
          habitStatus: 'High Performer',
          habitConsistencyPercent: 88,
          habitCompletedDays: 18,
          habitScheduledDays: 20,
          totalWorkouts: 18,
          totalMinutes: 620,
          totalCalories: 4800,
          avgHeartRate: 125.0,
          energyExpendedKcal: 4800,
          energyVsLastWeekPercent: 22,
          activeMinutes: 620,
          completedWorkouts: 18,
          targetWorkouts: 20,
          targetMinutes: 720,
          restDayMessage: 'Great month so far — keep the momentum going!',
          routineTitle: 'Gentle Rhythm • Step By Step',
          routineWeekLabel: 'Month 1',
          dailyActivities: [
            DailyActivityItem(day: 'W1', dayName: 'Wk 1', minutes: 120, isTargetReached: true),
            DailyActivityItem(day: 'W2', dayName: 'Wk 2', minutes: 150, isTargetReached: true),
            DailyActivityItem(day: 'W3', dayName: 'Wk 3', minutes: 145, isTargetReached: true, isToday: true),
            DailyActivityItem(day: 'W4', dayName: 'Wk 4', minutes: 0, isRest: true, isPlanned: true),
          ],
        );
      case ProgressTimeframe.allTime:
        return ProgressData(
          habitStatus: 'High Performer',
          habitConsistencyPercent: 88,
          habitCompletedDays: 18,
          habitScheduledDays: 20,
          totalWorkouts: 18,
          totalMinutes: 620,
          totalCalories: 4800,
          avgHeartRate: 125.0,
          energyExpendedKcal: 4800,
          energyVsLastWeekPercent: 22,
          activeMinutes: 620,
          completedWorkouts: 18,
          targetWorkouts: 20,
          targetMinutes: 720,
          restDayMessage: 'Remarkable consistency — you are building a lifestyle!',
          routineTitle: 'Gentle Rhythm • Step By Step',
          routineWeekLabel: 'All Time',
          dailyActivities: _getDynamicThisWeekActivities(),
        );
    }
  }

  static List<DailyActivityItem> _getDynamicThisWeekActivities() {
    final int todayWeekday = DateTime.now().weekday; // 1 = Mon, 7 = Sun
    
    // Base data that looks like the mockup, but we'll adjust it dynamically
    final List<Map<String, dynamic>> baseData = [
      {'day': 'Mon', 'minutes': 20},
      {'day': 'Tue', 'minutes': 30},
      {'day': 'Wed', 'minutes': 20},
      {'day': 'Thu', 'minutes': 0, 'isRest': true},
      {'day': 'Fri', 'minutes': 25},
      {'day': 'Sat', 'minutes': 0, 'isRest': true},
      {'day': 'Sun', 'minutes': 0, 'isRest': true},
    ];

    List<DailyActivityItem> activities = [];
    for (int i = 0; i < 7; i++) {
      int weekday = i + 1;
      bool isToday = weekday == todayWeekday;
      bool isFuture = weekday > todayWeekday;
      
      var data = baseData[i];
      
      int mins = isFuture ? 0 : (data['minutes'] as int);
      bool isRest = (data['isRest'] as bool?) ?? false;
      bool isPlanned = isFuture && !isRest;
      
      activities.add(DailyActivityItem(
        day: data['day'] as String,
        dayName: data['day'] as String,
        minutes: mins,
        isTargetReached: !isFuture && mins > 0,
        isRest: isRest,
        isToday: isToday,
        isPlanned: isPlanned,
      ));
    }
    
    return activities;
  }
}
