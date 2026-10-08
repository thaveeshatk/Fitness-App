import '../models/progress_data.dart';
import '../../../workouts/data/models/workout_session.dart';
import '../../../workouts/data/services/workout_log_service.dart';
import '../../../profile/data/services/profile_service.dart';
import '../../../profile/data/models/profile_model.dart';

class ProgressService {
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();

  static ProgressService get instance => _instance;

  static ProgressData getProgressData(
    ProgressTimeframe timeframe, {
    DateTime? clockNow,
    List<WorkoutSession>? overrideSessions,
    ProfileModel? overrideProfile,
  }) {
    final now = clockNow ?? DateTime.now();
    final sessions = overrideSessions ?? WorkoutLogService.instance.sessions;
    final profile = overrideProfile ?? ProfileService.currentProfile;

    return computeProgressData(
      timeframe: timeframe,
      now: now,
      sessions: sessions,
      profile: profile,
    );
  }

  static ProgressData computeProgressData({
    required ProgressTimeframe timeframe,
    required DateTime now,
    required List<WorkoutSession> sessions,
    required ProfileModel profile,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    // Monday of current week
    final startOfThisWeek = today.subtract(Duration(days: now.weekday - 1));
    final endOfThisWeek = startOfThisWeek.add(const Duration(days: 7));

    // Previous week
    final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
    final endOfLastWeek = startOfThisWeek;

    // Current month
    final startOfThisMonth = DateTime(now.year, now.month, 1);
    final endOfThisMonth = DateTime(now.year, now.month + 1, 1);

    // Filter sessions by timeframe
    final List<WorkoutSession> timeframeSessions;
    final String routineWeekLabel;

    switch (timeframe) {
      case ProgressTimeframe.thisWeek:
        timeframeSessions = sessions.where((s) {
          return !s.endTime.isBefore(startOfThisWeek) && s.endTime.isBefore(endOfThisWeek);
        }).toList();
        routineWeekLabel = 'This Week';
        break;

      case ProgressTimeframe.lastWeek:
        timeframeSessions = sessions.where((s) {
          return !s.endTime.isBefore(startOfLastWeek) && s.endTime.isBefore(endOfLastWeek);
        }).toList();
        routineWeekLabel = 'Last Week';
        break;

      case ProgressTimeframe.thisMonth:
        timeframeSessions = sessions.where((s) {
          return !s.endTime.isBefore(startOfThisMonth) && s.endTime.isBefore(endOfThisMonth);
        }).toList();
        routineWeekLabel = 'Month ${now.month}';
        break;

      case ProgressTimeframe.allTime:
        timeframeSessions = sessions;
        routineWeekLabel = 'All Time';
        break;
    }

    final totalCompleted = timeframeSessions.length;
    final totalMins = timeframeSessions.fold(0, (sum, s) => sum + s.durationMinutes);
    final totalKcal = timeframeSessions.fold(0, (sum, s) => sum + s.calories);

    // Target calculations
    final scheduledDaysCount = profile.weeklyRoutineDays.isNotEmpty ? profile.weeklyRoutineDays.length : 3;
    final targetMinsPerDay = profile.workoutMinutes > 0 ? profile.workoutMinutes : 20;

    final int targetWorkouts;
    final int targetMinutes;

    switch (timeframe) {
      case ProgressTimeframe.thisWeek:
      case ProgressTimeframe.lastWeek:
        targetWorkouts = scheduledDaysCount;
        targetMinutes = scheduledDaysCount * targetMinsPerDay;
        break;
      case ProgressTimeframe.thisMonth:
        targetWorkouts = scheduledDaysCount * 4;
        targetMinutes = targetWorkouts * targetMinsPerDay;
        break;
      case ProgressTimeframe.allTime:
        targetWorkouts = totalCompleted > 0 ? totalCompleted : scheduledDaysCount * 4;
        targetMinutes = targetWorkouts * targetMinsPerDay;
        break;
    }

    // Energy comparison vs last week
    final thisWeekSessions = sessions.where((s) {
      return !s.endTime.isBefore(startOfThisWeek) && s.endTime.isBefore(endOfThisWeek);
    }).toList();
    final lastWeekSessions = sessions.where((s) {
      return !s.endTime.isBefore(startOfLastWeek) && s.endTime.isBefore(endOfLastWeek);
    }).toList();

    final thisWeekKcal = thisWeekSessions.fold(0, (sum, s) => sum + s.calories);
    final lastWeekKcal = lastWeekSessions.fold(0, (sum, s) => sum + s.calories);

    int energyDiffPercent = 0;
    if (lastWeekKcal > 0) {
      energyDiffPercent = (((thisWeekKcal - lastWeekKcal) / lastWeekKcal) * 100).round();
    } else if (thisWeekKcal > 0) {
      energyDiffPercent = 100;
    }

    // Daily Activities chart
    final List<DailyActivityItem> activities;
    if (timeframe == ProgressTimeframe.thisMonth) {
      activities = _buildMonthActivities(now, sessions, targetMinsPerDay);
    } else if (timeframe == ProgressTimeframe.lastWeek) {
      activities = _buildWeekActivities(startOfLastWeek, now, sessions, profile, isPastWeek: true);
    } else {
      activities = _buildWeekActivities(startOfThisWeek, now, sessions, profile, isPastWeek: false);
    }

    // Habit consistency (worked out on scheduled days)
    final routineDayMatches = _getRoutineWeekdayIndices(profile.weeklyRoutineDays);
    int scheduledDaysElapsed = 0;
    int completedScheduledDays = 0;

    for (int i = 1; i <= (timeframe == ProgressTimeframe.lastWeek ? 7 : now.weekday); i++) {
      if (routineDayMatches.contains(i)) {
        scheduledDaysElapsed++;
        final dayDate = (timeframe == ProgressTimeframe.lastWeek ? startOfLastWeek : startOfThisWeek)
            .add(Duration(days: i - 1));
        final hasWorkedOut = sessions.any((s) {
          final sDate = DateTime(s.endTime.year, s.endTime.month, s.endTime.day);
          return sDate == dayDate;
        });
        if (hasWorkedOut) {
          completedScheduledDays++;
        }
      }
    }

    final int consistencyPercent;
    if (scheduledDaysElapsed == 0) {
      consistencyPercent = totalCompleted > 0 ? 100 : 0;
    } else {
      consistencyPercent = ((completedScheduledDays / scheduledDaysElapsed) * 100).round().clamp(0, 100);
    }

    String habitStatus;
    if (totalCompleted == 0 && sessions.isEmpty) {
      habitStatus = 'Getting Started';
    } else if (consistencyPercent >= 80) {
      habitStatus = 'On Track • Consistent';
    } else if (consistencyPercent >= 50) {
      habitStatus = 'Building Momentum';
    } else {
      habitStatus = 'Keep Pushing';
    }

    // Milestone calculation based on all-time total sessions
    final allTimeTotal = sessions.length;
    final String milestoneTitle;
    final String milestoneLevelText;
    final int milestonePercent;
    final String currentBadgeName;
    final String nextBadgeName;

    if (allTimeTotal == 0) {
      milestoneTitle = 'Habit Starter';
      milestoneLevelText = 'Level 1 • 0% to Bronze';
      milestonePercent = 0;
      currentBadgeName = 'Newcomer';
      nextBadgeName = 'Bronze Streak';
    } else if (allTimeTotal < 5) {
      milestoneTitle = 'Habit Starter';
      milestonePercent = ((allTimeTotal / 5) * 100).round();
      milestoneLevelText = 'Level 1 • $milestonePercent% to Bronze';
      currentBadgeName = 'Bronze Starter';
      nextBadgeName = 'Silver Consistency';
    } else if (allTimeTotal < 15) {
      milestoneTitle = 'Consistency Builder';
      milestonePercent = (((allTimeTotal - 5) / 10) * 100).round();
      milestoneLevelText = 'Level 2 • $milestonePercent% to Gold';
      currentBadgeName = 'Silver Streak';
      nextBadgeName = 'Gold Warrior';
    } else {
      milestoneTitle = 'Consistency Champion';
      milestonePercent = 100;
      milestoneLevelText = 'Level 3 • Master';
      currentBadgeName = 'Gold Warrior';
      nextBadgeName = 'Diamond Legend';
    }

    // Rest day message
    final String restDayMessage;
    final isTodayScheduled = routineDayMatches.contains(now.weekday);
    final workedOutToday = sessions.any((s) {
      final sDate = DateTime(s.endTime.year, s.endTime.month, s.endTime.day);
      return sDate == today;
    });

    if (workedOutToday) {
      restDayMessage = 'Great job finishing today\'s session! Hydrate and recover well.';
    } else if (!isTodayScheduled) {
      restDayMessage = 'Today is a scheduled recovery day. Light stretching is encouraged.';
    } else {
      restDayMessage = 'Today is a workout day! Complete your ${profile.workoutMinutes} min routine to stay on track.';
    }

    return ProgressData(
      habitStatus: habitStatus,
      habitConsistencyPercent: consistencyPercent,
      habitCompletedDays: completedScheduledDays,
      habitScheduledDays: scheduledDaysElapsed > 0 ? scheduledDaysElapsed : scheduledDaysCount,
      dailyActivities: activities,
      totalWorkouts: totalCompleted,
      totalMinutes: totalMins,
      totalCalories: totalKcal,
      avgHeartRate: 0.0, // No sensor connected, displayed as "--"
      energyVsLastWeekPercent: energyDiffPercent,
      restDayMessage: restDayMessage,
      milestoneTitle: milestoneTitle,
      milestoneLevelText: milestoneLevelText,
      milestonePercent: milestonePercent,
      currentBadgeName: currentBadgeName,
      nextBadgeName: nextBadgeName,
      dailyReflectionQuote: 'Every small victory builds momentum towards your ultimate fitness goal.',
      routineTitle: '${profile.fitnessLevel} • ${profile.goals.isNotEmpty ? profile.goals.first : "Fitness"} Plan',
      routineWeekLabel: routineWeekLabel,
      targetWorkouts: targetWorkouts,
      completedWorkouts: totalCompleted,
      targetMinutes: targetMinutes,
      activeMinutes: totalMins,
      energyExpendedKcal: totalKcal,
    );
  }

  static Set<int> _getRoutineWeekdayIndices(List<String> routineDays) {
    // Routine day ids: M1/M -> 1, T1 -> 2, W -> 3, T2 -> 4, F -> 5, S1 -> 6, S2 -> 7
    final Set<int> indices = {};
    for (final d in routineDays) {
      final upper = d.toUpperCase();
      if (upper == 'M1' || upper == 'M') indices.add(DateTime.monday);
      if (upper == 'T1') indices.add(DateTime.tuesday);
      if (upper == 'W') indices.add(DateTime.wednesday);
      if (upper == 'T2') indices.add(DateTime.thursday);
      if (upper == 'F') indices.add(DateTime.friday);
      if (upper == 'S1') indices.add(DateTime.saturday);
      if (upper == 'S2') indices.add(DateTime.sunday);
    }
    if (indices.isEmpty) {
      // Default Mon, Wed, Fri
      return {DateTime.monday, DateTime.wednesday, DateTime.friday};
    }
    return indices;
  }

  static List<DailyActivityItem> _buildWeekActivities(
    DateTime startOfWeek,
    DateTime now,
    List<WorkoutSession> sessions,
    ProfileModel profile, {
    bool isPastWeek = false,
  }) {
    final routineIndices = _getRoutineWeekdayIndices(profile.weeklyRoutineDays);
    final targetMins = profile.workoutMinutes > 0 ? profile.workoutMinutes : 20;
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final today = DateTime(now.year, now.month, now.day);
    final List<DailyActivityItem> result = [];

    for (int i = 0; i < 7; i++) {
      final dayDate = startOfWeek.add(Duration(days: i));
      final weekdayIndex = i + 1;
      final isScheduled = routineIndices.contains(weekdayIndex);
      final isToday = !isPastWeek && dayDate == today;
      final isFuture = !isPastWeek && dayDate.isAfter(today);

      // Sum minutes logged on dayDate
      final dayMinutes = sessions.where((s) {
        final sDate = DateTime(s.endTime.year, s.endTime.month, s.endTime.day);
        return sDate == dayDate;
      }).fold(0, (sum, s) => sum + s.durationMinutes);

      final isRest = !isScheduled && dayMinutes == 0;
      final isPlanned = isFuture && isScheduled;
      final isTargetReached = dayMinutes >= targetMins || dayMinutes > 0;

      result.add(DailyActivityItem(
        day: dayLabels[i],
        dayName: dayLabels[i],
        minutes: dayMinutes,
        isTargetReached: isTargetReached,
        isRest: isRest,
        isToday: isToday,
        isPlanned: isPlanned,
      ));
    }

    return result;
  }

  static List<DailyActivityItem> _buildMonthActivities(
    DateTime now,
    List<WorkoutSession> sessions,
    int targetMinsPerDay,
  ) {
    final startOfMonth = DateTime(now.year, now.month, 1);
    final List<DailyActivityItem> result = [];

    for (int w = 0; w < 4; w++) {
      final weekStart = startOfMonth.add(Duration(days: w * 7));
      final weekEnd = startOfMonth.add(Duration(days: (w + 1) * 7));

      final weekMins = sessions.where((s) {
        return !s.endTime.isBefore(weekStart) && s.endTime.isBefore(weekEnd);
      }).fold(0, (sum, s) => sum + s.durationMinutes);

      final isCurrentWeek = !now.isBefore(weekStart) && now.isBefore(weekEnd);
      final isFutureWeek = weekStart.isAfter(now);

      result.add(DailyActivityItem(
        day: 'W${w + 1}',
        dayName: 'Wk ${w + 1}',
        minutes: weekMins,
        isTargetReached: weekMins > 0,
        isRest: weekMins == 0 && !isFutureWeek,
        isToday: isCurrentWeek,
        isPlanned: isFutureWeek,
      ));
    }

    return result;
  }
}
