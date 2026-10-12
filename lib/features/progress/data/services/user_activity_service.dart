import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../plan/data/services/plan_service.dart';
import '../../../profile/data/services/profile_service.dart';
import '../../../workouts/data/models/workout_model.dart';
import '../../../notifications/data/services/notification_service.dart';

import '../models/progress_data.dart';

/// Service responsible for recording and querying user workout activity in Cloud Firestore.
/// Uses collection 'workout_history' keyed by authenticated user's UID.
class UserActivityService {
  UserActivityService._();

  static const String _collection = 'workout_history';

  // In-memory cache for offline/instant updates
  static final List<Map<String, dynamic>> _inMemoryActivities = [];

  /// Clears in-memory activity records
  static void clearCache() {
    _inMemoryActivities.clear();
  }

  /// Logs a finished workout session to Firestore
  static Future<void> logCompletedWorkout({
    required String workoutId,
    required String workoutTitle,
    required String category,
    required int durationMinutes,
    required int calories,
    String? difficulty,
    String? imageUrl,
    String? uid,
    String? planItemId,
    bool isPlanWorkout = true,
  }) async {
    final currentUid = uid ?? AuthService.currentUser.uid;
    final now = DateTime.now();
    final docId = '${currentUid}_${now.millisecondsSinceEpoch}';

    final data = <String, dynamic>{
      'id': docId,
      'uid': currentUid,
      'workoutId': workoutId,
      'workoutTitle': workoutTitle,
      'category': category,
      'difficulty': difficulty ?? 'Intermediate',
      'durationMinutes': durationMinutes,
      'calories': calories,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (planItemId != null) 'planItemId': planItemId,
      'isPlanWorkout': isPlanWorkout,
      'completedAt': now.toIso8601String(),
    };

    // Store in-memory for instant feedback
    _inMemoryActivities.insert(0, data);

    // Trigger Notification for Workout Completion
    await NotificationService.onWorkoutCompleted(
      workoutTitle: workoutTitle,
      durationMinutes: durationMinutes,
      calories: calories,
      workoutId: workoutId,
    );

    // Milestone Check: If user completes first workout or hits 3 workouts
    final totalCompleted = _inMemoryActivities.where((a) => a['uid'] == currentUid).length;
    if (totalCompleted == 1) {
      await NotificationService.onMilestoneReached(
        milestoneTitle: 'First Workout Completed',
        details: 'You completed your first workout session! 🌟 Keep the momentum going.',
      );
    } else if (totalCompleted == 3) {
      await NotificationService.onGoalAchieved(
        goalTitle: 'Weekly 3-Day Habit',
        subtitle: 'Congratulations! You reached 3 completed workouts this week.',
      );
    }

    if (FirebaseService.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection(_collection)
            .doc(docId)
            .set(data);
        developer.log('Workout logged to Firestore: $docId', name: 'UserActivityService');
      } catch (e, stack) {
        developer.log(
          'Failed saving workout log to Firestore: $e',
          name: 'UserActivityService',
          error: e,
          stackTrace: stack,
        );
      }
    }
  }

  /// Logs a WorkoutModel directly
  static Future<void> logWorkoutModel({
    required WorkoutModel workout,
    int? customDurationMinutes,
    int? customCalories,
    String? uid,
  }) async {
    await logCompletedWorkout(
      workoutId: workout.id,
      workoutTitle: workout.title,
      category: workout.category,
      durationMinutes: customDurationMinutes ?? workout.durationMinutes,
      calories: customCalories ?? workout.calories,
      difficulty: workout.difficulty,
      uid: uid,
    );
  }

  /// Returns all completed workouts for the authenticated user, sorted by date descending
  static Future<List<Map<String, dynamic>>> getAllActivities({String? uid}) async {
    final currentUid = uid ?? AuthService.currentUser.uid;
    List<Map<String, dynamic>> results = [];

    if (FirebaseService.isInitialized) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection(_collection)
            .where('uid', isEqualTo: currentUid)
            .get();

        results = snapshot.docs.map((doc) => doc.data()).toList();
      } catch (e) {
        developer.log('Error querying all activities from Firestore: $e', name: 'UserActivityService');
      }
    }

    // Merge in-memory activities for this user that may not have synced
    for (final act in _inMemoryActivities) {
      if (act['uid'] == currentUid && !results.any((r) => r['id'] == act['id'])) {
        results.add(act);
      }
    }

    results.sort((a, b) {
      final aDate = a['completedAt']?.toString() ?? '';
      final bDate = b['completedAt']?.toString() ?? '';
      return bDate.compareTo(aDate);
    });

    return results;
  }

  /// Returns workouts completed in the given timeframe
  static Future<List<Map<String, dynamic>>> getActivitiesForTimeframe({
    required ProgressTimeframe timeframe,
    String? uid,
  }) async {
    final all = await getAllActivities(uid: uid);
    final now = DateTime.now();

    switch (timeframe) {
      case ProgressTimeframe.thisWeek:
        final startOfWeek = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        return all.where((item) {
          final dateStr = item['completedAt']?.toString();
          if (dateStr == null) return false;
          final d = DateTime.tryParse(dateStr);
          return d != null && d.isAfter(startOfWeek.subtract(const Duration(seconds: 1)));
        }).toList();

      case ProgressTimeframe.lastWeek:
        final startOfThisWeek = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
        return all.where((item) {
          final dateStr = item['completedAt']?.toString();
          if (dateStr == null) return false;
          final d = DateTime.tryParse(dateStr);
          return d != null &&
              d.isAfter(startOfLastWeek.subtract(const Duration(seconds: 1))) &&
              d.isBefore(startOfThisWeek);
        }).toList();

      case ProgressTimeframe.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        return all.where((item) {
          final dateStr = item['completedAt']?.toString();
          if (dateStr == null) return false;
          final d = DateTime.tryParse(dateStr);
          return d != null && d.isAfter(startOfMonth.subtract(const Duration(seconds: 1)));
        }).toList();

      case ProgressTimeframe.allTime:
        return all;
    }
  }

  /// Returns workouts completed in the current calendar week (Monday to Sunday)
  static Future<List<Map<String, dynamic>>> getThisWeeksActivities({String? uid}) async {
    return getActivitiesForTimeframe(timeframe: ProgressTimeframe.thisWeek, uid: uid);
  }

  /// Returns recent completed workouts for this user
  static Future<List<Map<String, dynamic>>> getRecentActivities({
    String? uid,
    int limit = 10,
  }) async {
    final all = await getAllActivities(uid: uid);
    if (all.length > limit) {
      return all.sublist(0, limit);
    }
    return all;
  }

  /// Calculates real weekly progress data for the given user:
  /// - completed: number of workouts finished this week
  /// - total: weekly target (from user's profile weeklyRoutineDays)
  /// - activeMinutes: total minutes worked out this week
  /// - streak: consecutive daily streak
  /// - fraction: completion ratio (0.0 to 1.0)
  /// - percent: completion percentage (0 to 100)
  /// - hasActivity: whether the user has logged any activity this week
  static Future<Map<String, dynamic>> getWeeklyProgress({String? uid}) async {
    final currentUid = uid ?? AuthService.currentUser.uid;

    final profile = await ProfileService.getProfile(docId: currentUid);
    final targetDays = profile.weeklyRoutineDays.isNotEmpty
        ? profile.weeklyRoutineDays.length
        : 3;

    final thisWeeksActivities = await getThisWeeksActivities(uid: currentUid);
    final planCompletedCount = await PlanService.getCompletedItemCount(uid: currentUid);

    // Number of completed plan sessions this week (strictly only workouts from weekly plan)
    final planActivitiesCount = thisWeeksActivities
        .where((a) => a['isPlanWorkout'] == true || a['planItemId'] != null)
        .length;
    final completedCount = planCompletedCount > 0 ? planCompletedCount : planActivitiesCount;

    final activeMinutes = thisWeeksActivities.fold<int>(
      0,
      (totalMins, item) => totalMins + ((item['durationMinutes'] as num?)?.toInt() ?? 0),
    );

    final streak = _calculateStreak(thisWeeksActivities);

    final fraction = targetDays > 0
        ? (completedCount / targetDays).clamp(0.0, 1.0)
        : 0.0;
    final percent = (fraction * 100).round();

    return {
      'completed': completedCount,
      'total': targetDays,
      'activeMinutes': activeMinutes,
      'streak': streak,
      'fraction': fraction,
      'percent': percent,
      'hasActivity': completedCount > 0 || thisWeeksActivities.isNotEmpty,
    };
  }

  /// Computes the consecutive daily streak based on unique workout dates
  static int calculateStreak(List<Map<String, dynamic>> activities) => _calculateStreak(activities);

  static int _calculateStreak(List<Map<String, dynamic>> activities) {
    if (activities.isEmpty) return 0;

    final dates = <DateTime>{};
    for (final act in activities) {
      final dateStr = act['completedAt']?.toString();
      if (dateStr != null) {
        final d = DateTime.tryParse(dateStr);
        if (d != null) {
          dates.add(DateTime(d.year, d.month, d.day));
        }
      }
    }

    if (dates.isEmpty) return 0;

    final sortedDates = dates.toList()..sort((a, b) => b.compareTo(a));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // If latest workout was neither today nor yesterday, streak is 0
    final latest = sortedDates.first;
    if (latest != today && latest != yesterday) {
      return 0;
    }

    int streak = 1;
    DateTime current = latest;
    for (int i = 1; i < sortedDates.length; i++) {
      final previous = sortedDates[i];
      if (current.difference(previous).inDays == 1) {
        streak++;
        current = previous;
      } else {
        break;
      }
    }

    return streak;
  }
}
