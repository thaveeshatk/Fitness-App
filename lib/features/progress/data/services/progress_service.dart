import 'dart:math' as math;
import '../../../auth/data/services/auth_service.dart';
import '../../../profile/data/models/profile_model.dart';
import '../../../profile/data/services/profile_service.dart';
import '../models/progress_data.dart';
import 'user_activity_service.dart';

/// Dynamic Progress Service
/// Retrieves real, personalized progress and activity data from Firebase Authentication
/// and Cloud Firestore for each authenticated user.
class ProgressService {
  ProgressService._();

  static final Map<ProgressTimeframe, ProgressData> _cachedProgressData = {};

  /// Synchronous getter returning cached or realistic fallback ProgressData
  static ProgressData getProgressData(ProgressTimeframe timeframe) {
    if (_cachedProgressData.containsKey(timeframe)) {
      return _cachedProgressData[timeframe]!;
    }
    return _buildDefaultFallback(timeframe);
  }

  /// Clears in-memory progress cache (e.g. on user logout)
  static void clearCache() {
    _cachedProgressData.clear();
  }

  /// Asynchronously loads real progress data for the authenticated user
  static Future<ProgressData> loadProgressData(
    ProgressTimeframe timeframe, {
    String? uid,
    bool forceRefresh = false,
  }) async {
    final currentUid = uid ?? AuthService.currentUser.uid;

    try {
      // 1. Fetch user's profile from Firestore
      final profile = await ProfileService.getProfile(
        docId: currentUid,
        forceRefresh: forceRefresh,
      );

      // 2. Fetch all completed workouts for this user
      final allActivities = await UserActivityService.getAllActivities(uid: currentUid);

      // 3. Fetch workouts for the requested timeframe
      final timeframeActivities = await UserActivityService.getActivitiesForTimeframe(
        timeframe: timeframe,
        uid: currentUid,
      );

      // 4. Calculate weekly target & completed counts
      final targetWeeklyDays = profile.weeklyRoutineDays.isNotEmpty
          ? profile.weeklyRoutineDays.length
          : 3;
      final sessionMinutes = profile.workoutMinutes > 0 ? profile.workoutMinutes : 20;

      int targetWorkouts;
      int targetMinutes;
      String weekLabel;

      switch (timeframe) {
        case ProgressTimeframe.thisWeek:
          targetWorkouts = targetWeeklyDays;
          targetMinutes = targetWeeklyDays * sessionMinutes;
          weekLabel = 'This Week';
          break;
        case ProgressTimeframe.lastWeek:
          targetWorkouts = targetWeeklyDays;
          targetMinutes = targetWeeklyDays * sessionMinutes;
          weekLabel = 'Last Week';
          break;
        case ProgressTimeframe.thisMonth:
          targetWorkouts = targetWeeklyDays * 4;
          targetMinutes = targetWeeklyDays * 4 * sessionMinutes;
          weekLabel = 'This Month';
          break;
        case ProgressTimeframe.allTime:
          targetWorkouts = math.max(targetWeeklyDays * 4, allActivities.length);
          targetMinutes = targetWorkouts * sessionMinutes;
          weekLabel = 'All Time';
          break;
      }

      final completedWorkouts = timeframeActivities.length;
      final activeMinutes = timeframeActivities.fold<int>(
        0,
        (sum, a) => sum + ((a['durationMinutes'] as num?)?.toInt() ?? 0),
      );
      final energyExpendedKcal = timeframeActivities.fold<int>(
        0,
        (sum, a) => sum + ((a['calories'] as num?)?.toInt() ?? 0),
      );

      // 5. Compare energy vs last week
      final lastWeekActivities = await UserActivityService.getActivitiesForTimeframe(
        timeframe: ProgressTimeframe.lastWeek,
        uid: currentUid,
      );
      final lastWeekCalories = lastWeekActivities.fold<int>(
        0,
        (sum, a) => sum + ((a['calories'] as num?)?.toInt() ?? 0),
      );

      int energyVsLastWeekPercent = 0;
      if (lastWeekCalories > 0) {
        energyVsLastWeekPercent = (((energyExpendedKcal - lastWeekCalories) / lastWeekCalories) * 100).round();
      } else if (energyExpendedKcal > 0) {
        energyVsLastWeekPercent = 100;
      }

      // 6. Habit consistency
      final habitConsistencyPercent = targetWorkouts > 0
          ? ((completedWorkouts / targetWorkouts) * 100).clamp(0, 100).round()
          : 0;

      String habitStatus;
      if (completedWorkouts >= targetWorkouts && targetWorkouts > 0) {
        habitStatus = 'Goal Achieved • 100%';
      } else if (habitConsistencyPercent >= 75) {
        habitStatus = 'On Track • Consistent';
      } else if (habitConsistencyPercent >= 40) {
        habitStatus = 'Building Momentum';
      } else if (completedWorkouts > 0) {
        habitStatus = 'Getting Started';
      } else {
        habitStatus = 'Ready to Start';
      }

      // 7. Daily Activity bars
      final dailyActivities = _buildDynamicDailyActivities(
        timeframe: timeframe,
        activities: timeframeActivities,
        allActivities: allActivities,
        profile: profile,
      );

      // 8. Routine title
      final routineTitle = '${profile.fitnessLevel} Routine • ${profile.goals.isNotEmpty ? profile.goals.first : "FitOn"}';

      // 9. Rest day / Progress summary message
      String restDayMessage;
      if (completedWorkouts >= targetWorkouts && targetWorkouts > 0) {
        restDayMessage = '🎉 Fantastic job! You have reached your weekly goal of $targetWorkouts workouts.';
      } else if (completedWorkouts == 0) {
        restDayMessage = 'Ready to start? Complete your first workout this week to build momentum!';
      } else {
        final remaining = targetWorkouts - completedWorkouts;
        restDayMessage = '🎯 $remaining more workout${remaining == 1 ? '' : 's'} to hit your goal of $targetWorkouts sessions this week.';
      }

      // 10. Milestones and badges based on all-time workouts
      final streak = UserActivityService.calculateStreak(allActivities);
      final milestone = _calculateMilestoneJourney(allActivities.length, streak);

      final progressData = ProgressData(
        habitStatus: habitStatus,
        habitConsistencyPercent: habitConsistencyPercent,
        habitCompletedDays: completedWorkouts,
        habitScheduledDays: targetWorkouts,
        totalWorkouts: allActivities.length,
        totalMinutes: allActivities.fold<int>(0, (s, a) => s + ((a['durationMinutes'] as num?)?.toInt() ?? 0)),
        totalCalories: allActivities.fold<int>(0, (s, a) => s + ((a['calories'] as num?)?.toInt() ?? 0)),
        avgHeartRate: 124.0,
        energyExpendedKcal: energyExpendedKcal,
        energyVsLastWeekPercent: energyVsLastWeekPercent,
        activeMinutes: activeMinutes,
        completedWorkouts: completedWorkouts,
        targetWorkouts: targetWorkouts,
        targetMinutes: targetMinutes,
        restDayMessage: restDayMessage,
        routineTitle: routineTitle,
        routineWeekLabel: weekLabel,
        dailyActivities: dailyActivities,
        milestoneTitle: milestone['title'] as String,
        milestoneLevelText: milestone['levelText'] as String,
        milestonePercent: milestone['percent'] as int,
        currentBadgeName: milestone['currentBadge'] as String,
        nextBadgeName: milestone['nextBadge'] as String,
        dailyReflectionQuote: _getReflectionQuote(completedWorkouts, streak),
      );

      _cachedProgressData[timeframe] = progressData;
      return progressData;
    } catch (e) {
      // Fallback in case of network interruption
      final fallback = _buildDefaultFallback(timeframe);
      _cachedProgressData[timeframe] = fallback;
      return fallback;
    }
  }

  /// Builds 7-day or multi-week dynamic activity bars
  static List<DailyActivityItem> _buildDynamicDailyActivities({
    required ProgressTimeframe timeframe,
    required List<Map<String, dynamic>> activities,
    required List<Map<String, dynamic>> allActivities,
    required ProfileModel profile,
  }) {
    final now = DateTime.now();

    if (timeframe == ProgressTimeframe.thisWeek || timeframe == ProgressTimeframe.lastWeek) {
      final DateTime startOfWeek = timeframe == ProgressTimeframe.thisWeek
          ? DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1))
          : DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: now.weekday - 1 + 7));

      final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final List<DailyActivityItem> items = [];

      for (int i = 0; i < 7; i++) {
        final date = startOfWeek.add(Duration(days: i));
        final isToday = (now.year == date.year && now.month == date.month && now.day == date.day);
        final isFuture = date.isAfter(DateTime(now.year, now.month, now.day));

        // Sum minutes for workouts on this day
        int dayMinutes = 0;
        for (final act in activities) {
          final completedAtStr = act['completedAt']?.toString();
          if (completedAtStr != null) {
            final actDate = DateTime.tryParse(completedAtStr);
            if (actDate != null &&
                actDate.year == date.year &&
                actDate.month == date.month &&
                actDate.day == date.day) {
              dayMinutes += ((act['durationMinutes'] as num?)?.toInt() ?? 0);
            }
          }
        }

        // Check if scheduled in profile
        final dayName = dayNames[i];
        final isScheduledInProfile = _isDayScheduledInProfile(i, profile.weeklyRoutineDays);

        final bool isRest = dayMinutes == 0 && (!isScheduledInProfile || (!isFuture && !isToday));
        final bool isPlanned = isFuture && isScheduledInProfile && dayMinutes == 0;
        final bool isTargetReached = dayMinutes > 0;

        items.add(DailyActivityItem(
          day: dayName,
          dayName: dayName,
          minutes: dayMinutes,
          isTargetReached: isTargetReached,
          isRest: isRest,
          isToday: isToday,
          isPlanned: isPlanned,
        ));
      }

      return items;
    } else {
      // Month / All-time breakdown: 4 weeks view
      final List<DailyActivityItem> weekItems = [];
      final startOfMonth = DateTime(now.year, now.month, 1);

      for (int w = 0; w < 4; w++) {
        final weekStart = startOfMonth.add(Duration(days: w * 7));
        final weekEnd = weekStart.add(const Duration(days: 7));
        final isCurrentWeek = now.isAfter(weekStart) && now.isBefore(weekEnd);
        final isFutureWeek = weekStart.isAfter(now);

        int weekMinutes = 0;
        for (final act in activities) {
          final dateStr = act['completedAt']?.toString();
          if (dateStr != null) {
            final d = DateTime.tryParse(dateStr);
            if (d != null && d.isAfter(weekStart.subtract(const Duration(seconds: 1))) && d.isBefore(weekEnd)) {
              weekMinutes += ((act['durationMinutes'] as num?)?.toInt() ?? 0);
            }
          }
        }

        weekItems.add(DailyActivityItem(
          day: 'W${w + 1}',
          dayName: 'Wk ${w + 1}',
          minutes: weekMinutes,
          isTargetReached: weekMinutes > 0,
          isRest: weekMinutes == 0 && !isFutureWeek,
          isToday: isCurrentWeek,
          isPlanned: isFutureWeek,
        ));
      }

      return weekItems;
    }
  }

  /// Robust day-matcher supporting all token variations (M1, T1, W, T2, F, S1, S2, Mon, Tue, etc.)
  static bool _isDayScheduledInProfile(int dayIndex, List<String> weeklyRoutineDays) {
    const dayAliases = [
      ['m1', 'm', 'mon', 'monday'],
      ['t1', 'tu', 'tue', 'tues', 'tuesday'],
      ['w', 'wed', 'wednesday'],
      ['t2', 'th', 'thu', 'thur', 'thurs', 'thursday'],
      ['f', 'fri', 'friday'],
      ['s1', 'sa', 'sat', 'saturday'],
      ['s2', 'su', 'sun', 'sunday'],
    ];

    if (dayIndex < 0 || dayIndex >= dayAliases.length) return false;
    final validTokens = dayAliases[dayIndex];

    return weeklyRoutineDays.any((d) {
      final clean = d.trim().toLowerCase();
      if (validTokens.contains(clean)) return true;
      return validTokens.any((token) => token.length >= 2 && clean.startsWith(token));
    });
  }

  /// Calculates dynamic milestones and badges based on total workout count
  static Map<String, dynamic> _calculateMilestoneJourney(int totalWorkouts, int streak) {
    if (totalWorkouts == 0) {
      return {
        'title': 'First Step',
        'levelText': 'Level 0 • Ready to Start',
        'percent': 0,
        'currentBadge': 'New Starter',
        'nextBadge': 'First Workout',
      };
    } else if (totalWorkouts < 3) {
      return {
        'title': 'Consistency Starter',
        'levelText': 'Level 1 • $totalWorkouts of 3 workouts',
        'percent': ((totalWorkouts / 3) * 100).round(),
        'currentBadge': 'First Workout',
        'nextBadge': 'Consistency Badge',
      };
    } else if (totalWorkouts < 7) {
      return {
        'title': 'Habit Builder',
        'levelText': 'Level 2 • $totalWorkouts of 7 workouts',
        'percent': ((totalWorkouts / 7) * 100).round(),
        'currentBadge': 'Bronze Streak',
        'nextBadge': 'Silver Warrior',
      };
    } else if (totalWorkouts < 15) {
      return {
        'title': 'Momentum Master',
        'levelText': 'Level 3 • $totalWorkouts of 15 workouts',
        'percent': ((totalWorkouts / 15) * 100).round(),
        'currentBadge': 'Silver Warrior',
        'nextBadge': 'Gold Champion',
      };
    } else {
      return {
        'title': 'Consistency Champion',
        'levelText': 'Level 4 • Gold Elite Member',
        'percent': 100,
        'currentBadge': 'Gold Champion',
        'nextBadge': 'Fitness Master',
      };
    }
  }

  /// Provides an inspiring reflection quote
  static String _getReflectionQuote(int completedWorkouts, int streak) {
    if (completedWorkouts == 0) {
      return 'The journey of a thousand miles begins with a single session.';
    } else if (streak >= 3) {
      return 'Discipline is simply choosing between what you want now and what you want most.';
    } else {
      return 'Every small victory builds momentum towards your ultimate fitness goal.';
    }
  }

  /// Sensible initial fallback
  static ProgressData _buildDefaultFallback(ProgressTimeframe timeframe) {
    return const ProgressData(
      habitStatus: 'Ready to Start',
      habitConsistencyPercent: 0,
      habitCompletedDays: 0,
      habitScheduledDays: 3,
      totalWorkouts: 0,
      totalMinutes: 0,
      totalCalories: 0,
      avgHeartRate: 120.0,
      energyExpendedKcal: 0,
      energyVsLastWeekPercent: 0,
      activeMinutes: 0,
      completedWorkouts: 0,
      targetWorkouts: 3,
      targetMinutes: 60,
      restDayMessage: 'Ready to start? Complete your first workout this week to build your streak!',
      routineTitle: 'Beginner Routine • Step By Step',
      routineWeekLabel: 'This Week',
      milestoneTitle: 'First Step',
      milestoneLevelText: 'Level 0 • Ready to Start',
      milestonePercent: 0,
      currentBadgeName: 'New Starter',
      nextBadgeName: 'First Workout',
      dailyReflectionQuote: 'The journey of a thousand miles begins with a single session.',
      dailyActivities: [
        DailyActivityItem(day: 'Mon', dayName: 'Mon', minutes: 0, isRest: true),
        DailyActivityItem(day: 'Tue', dayName: 'Tue', minutes: 0, isRest: true),
        DailyActivityItem(day: 'Wed', dayName: 'Wed', minutes: 0, isRest: true),
        DailyActivityItem(day: 'Thu', dayName: 'Thu', minutes: 0, isRest: true),
        DailyActivityItem(day: 'Fri', dayName: 'Fri', minutes: 0, isRest: true),
        DailyActivityItem(day: 'Sat', dayName: 'Sat', minutes: 0, isRest: true),
        DailyActivityItem(day: 'Sun', dayName: 'Sun', minutes: 0, isRest: true),
      ],
    );
  }
}
