enum ProgressTimeframe {
  thisWeek,
  lastWeek,
  thisMonth,
  allTime,
}

class DailyActivityItem {
  final String day;
  final String dayName;
  final int minutes;
  final bool isTargetReached;
  final bool isRest;
  final bool isToday;
  final bool isPlanned;

  const DailyActivityItem({
    required this.day,
    String? dayName,
    required this.minutes,
    this.isTargetReached = false,
    this.isRest = false,
    this.isToday = false,
    this.isPlanned = false,
  }) : dayName = dayName ?? day;
}

class ProgressData {
  final String habitStatus;
  final int habitConsistencyPercent;
  final int habitCompletedDays;
  final int habitScheduledDays;
  final List<DailyActivityItem> dailyActivities;
  final int totalWorkouts;
  final int totalMinutes;
  final int totalCalories;
  final double avgHeartRate;
  final int energyVsLastWeekPercent;
  final String restDayMessage;
  final String milestoneTitle;
  final String milestoneLevelText;
  final int milestonePercent;
  final String currentBadgeName;
  final String nextBadgeName;
  final String dailyReflectionQuote;

  final String routineTitle;
  final String routineWeekLabel;
  final int targetWorkouts;
  final int completedWorkouts;
  final int targetMinutes;
  final int activeMinutes;
  final int energyExpendedKcal;

  const ProgressData({
    this.habitStatus = 'On Track • Consistent',
    this.habitConsistencyPercent = 80,
    this.habitCompletedDays = 4,
    this.habitScheduledDays = 5,
    this.dailyActivities = const [
      DailyActivityItem(day: 'Mon', minutes: 45, isTargetReached: true, isToday: false),
      DailyActivityItem(day: 'Tue', minutes: 30, isTargetReached: true, isToday: false),
      DailyActivityItem(day: 'Wed', minutes: 50, isTargetReached: true, isToday: true),
      DailyActivityItem(day: 'Thu', minutes: 20, isTargetReached: false, isToday: false, isPlanned: true),
      DailyActivityItem(day: 'Fri', minutes: 40, isTargetReached: true, isToday: false, isPlanned: true),
      DailyActivityItem(day: 'Sat', minutes: 15, isTargetReached: false, isRest: true),
      DailyActivityItem(day: 'Sun', minutes: 0, isTargetReached: false, isRest: true),
    ],
    this.totalWorkouts = 12,
    this.totalMinutes = 320,
    this.totalCalories = 2450,
    this.avgHeartRate = 128.0,
    this.energyVsLastWeekPercent = 12,
    this.restDayMessage = 'Rest and recovery active today. Fuel your body and stay hydrated.',
    this.milestoneTitle = 'Consistency Champion',
    this.milestoneLevelText = 'Level 4 • 80% to Gold',
    this.milestonePercent = 80,
    this.currentBadgeName = 'Silver Streak',
    this.nextBadgeName = 'Gold Warrior',
    this.dailyReflectionQuote = 'Every small victory builds momentum towards your ultimate fitness goal.',
    this.routineTitle = 'Hypertrophy & Conditioning Plan',
    this.routineWeekLabel = 'Week 3 of 8',
    this.targetWorkouts = 5,
    this.completedWorkouts = 4,
    this.targetMinutes = 180,
    this.activeMinutes = 145,
    this.energyExpendedKcal = 1120,
  });
}
