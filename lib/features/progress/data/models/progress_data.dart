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
    this.habitStatus = 'Getting Started',
    this.habitConsistencyPercent = 0,
    this.habitCompletedDays = 0,
    this.habitScheduledDays = 0,
    this.dailyActivities = const [],
    this.totalWorkouts = 0,
    this.totalMinutes = 0,
    this.totalCalories = 0,
    this.avgHeartRate = 0.0,
    this.energyVsLastWeekPercent = 0,
    this.restDayMessage = 'Ready for your next workout! Stay consistent to reach your goals.',
    this.milestoneTitle = 'Habit Builder',
    this.milestoneLevelText = 'Level 1 • Beginner',
    this.milestonePercent = 0,
    this.currentBadgeName = 'First Step',
    this.nextBadgeName = 'Consistency Pro',
    this.dailyReflectionQuote = 'Every small victory builds momentum towards your ultimate fitness goal.',
    this.routineTitle = 'Personalized Routine',
    this.routineWeekLabel = 'This Week',
    this.targetWorkouts = 0,
    this.completedWorkouts = 0,
    this.targetMinutes = 0,
    this.activeMinutes = 0,
    this.energyExpendedKcal = 0,
  });
}
