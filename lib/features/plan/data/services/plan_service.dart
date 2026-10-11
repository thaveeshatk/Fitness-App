import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_app/core/services/firebase_service.dart';
import 'package:fitness_app/features/auth/data/services/auth_service.dart';
import 'package:fitness_app/features/profile/data/models/profile_model.dart';
import 'package:fitness_app/features/profile/data/services/profile_service.dart';
import 'package:fitness_app/features/workouts/data/models/workout_model.dart';
import 'package:fitness_app/features/workouts/data/repositories/workout_repository.dart';
import 'package:fitness_app/features/plan/data/models/plan_schedule_item.dart';
import 'package:fitness_app/features/notifications/data/services/notification_service.dart';
import 'package:fitness_app/features/progress/data/services/user_activity_service.dart';

/// Service responsible for managing the user's weekly workout plan.
/// Dynamically connects user's profile preferences with workouts from [WorkoutRepository].
class PlanService {
  PlanService._();

  static const String _completionsCollection = 'plan_completions';

  static final Map<String, List<PlanScheduleItem>> _planCache = {};

  // Simulated database for schedule settings
  static Set<String> _savedDays = {'Mon', 'Wed', 'Fri', 'Sat'};
  static String _savedTime = '07:00';
  static bool _savedIsAm = false;
  
  static Future<void> saveSchedule(Set<String> days, String time, bool isAm) async {
    // Simulate backend network delay
    await Future.delayed(const Duration(seconds: 1));
    _savedDays = days;
    _savedTime = time;
    _savedIsAm = isAm;
    
    // Trigger notification
    await NotificationService.onScheduleUpdated(
      days: days,
      time: time,
      isAm: isAm,
    );
    
    developer.log('Schedule saved to backend DB: days=$days, time=$time, isAm=$isAm', name: 'PlanService');
  }
  
  static Map<String, dynamic> getSavedSchedule() {
    return {
      'days': _savedDays,
      'time': _savedTime,
      'isAm': _savedIsAm,
    };
  }

  /// Clears in-memory plan cache (useful when switching user accounts)
  static void clearCache() {
    _planCache.clear();
  }

  /// Gets the count of plan workouts completed by this user in Firestore
  static Future<int> getCompletedItemCount({String? uid}) async {
    final currentUid = uid ?? AuthService.currentUser.uid;
    final cached = _planCache[currentUid];
    if (cached != null) {
      return cached.where((it) => it.isCompleted).length;
    }

    final items = await getWeeklyPlan(uid: currentUid);
    return items.where((it) => it.isCompleted).length;
  }

  static bool _hasBoundProfileNotifier = false;

  static void _ensureProfileNotifierBound() {
    if (!_hasBoundProfileNotifier) {
      _hasBoundProfileNotifier = true;
      ProfileService.profileNotifier.addListener(() {
        _planCache.clear();
      });
    }
  }

  /// Loads the weekly plan tailored to the user's profile, overlaying any
  /// completion status the signed-in user has saved in Firestore.
  static Future<List<PlanScheduleItem>> getWeeklyPlan({String? uid, bool forceRefresh = false}) async {
    _ensureProfileNotifierBound();
    final currentUid = uid ?? AuthService.currentUser.uid;
    if (_planCache.containsKey(currentUid) && !forceRefresh) {
      return _planCache[currentUid]!;
    }

    final profile = await ProfileService.getProfile(docId: currentUid);
    final allWorkouts = WorkoutRepository.getMockWorkouts();

    final plan = _buildScheduleFromProfile(profile, allWorkouts);
    final enrichedPlan = await _applyPersistedCompletions(plan, currentUid);
    _planCache[currentUid] = enrichedPlan;
    developer.log('Weekly plan loaded for $currentUid: ${enrichedPlan.length} items', name: 'PlanService');
    return enrichedPlan;
  }

  /// Reads this user's saved completion flags from Firestore and overlays
  /// them onto the generated plan, so completed-workout state survives app
  /// restarts once Firebase is connected.
  static Future<List<PlanScheduleItem>> _applyPersistedCompletions(
    List<PlanScheduleItem> plan,
    String uid,
  ) async {
    final completedIds = <String>{};

    if (FirebaseService.isInitialized) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection(_completionsCollection)
            .where('uid', isEqualTo: uid)
            .get();

        completedIds.addAll(snapshot.docs.map((doc) => doc.data()['itemId'] as String));
      } catch (e) {
        developer.log('Failed to load persisted plan completions: $e', name: 'PlanService');
      }
    }

    // Also check if any workouts were completed this week in UserActivityService
    try {
      final thisWeeksActs = await UserActivityService.getThisWeeksActivities(uid: uid);
      final completedWorkoutIds = thisWeeksActs.map((a) => a['workoutId']?.toString()).toSet();
      return plan.map((item) {
        if (completedIds.contains(item.id) || completedWorkoutIds.contains(item.workout.id)) {
          return item.copyWith(status: PlanItemStatus.completed);
        }
        return item;
      }).toList();
    } catch (_) {
      if (completedIds.isEmpty) return plan;
      return plan.map((item) {
        if (completedIds.contains(item.id)) {
          return item.copyWith(status: PlanItemStatus.completed);
        }
        return item;
      }).toList();
    }
  }

  /// Calculates the current progress metrics:
  /// (completedCount, totalCount, progressFraction, remainingCount)
  static Map<String, dynamic> calculateMetrics(List<PlanScheduleItem> items) {
    final completedCount = items.where((it) => it.isCompleted).length;
    final totalCount = items.length;
    final remainingCount = (totalCount - completedCount).clamp(0, totalCount);
    final progressFraction = totalCount > 0 ? (completedCount / totalCount).clamp(0.0, 1.0) : 0.0;
    final percentInt = (progressFraction * 100).round();

    return {
      'completed': completedCount,
      'total': totalCount,
      'remaining': remainingCount,
      'fraction': progressFraction,
      'percent': percentInt,
    };
  }

  /// Marks a plan item completed locally and persists it to Firestore for
  /// the signed-in user, so the status survives across sessions.
  static Future<void> markWorkoutCompleted(String itemId, {String? uid}) async {
    final currentUid = uid ?? AuthService.currentUser.uid;
    final plan = _planCache[currentUid];
    if (plan != null) {
      _planCache[currentUid] = plan.map((item) {
        if (item.id == itemId) {
          return item.copyWith(status: PlanItemStatus.completed);
        }
        return item;
      }).toList();
    }

    if (!FirebaseService.isInitialized) return;

    try {
      await FirebaseFirestore.instance
          .collection(_completionsCollection)
          .doc('${currentUid}_$itemId')
          .set({
        'uid': currentUid,
        'itemId': itemId,
        'completedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      developer.log('Failed to persist plan completion: $e', name: 'PlanService');
    }
  }

  /// Parses weekday tokens (e.g. 'M1', 'W', 'Mon', 'Fri') into unique sorted weekday integers (1..7)
  static List<int> _parseWeekdays(List<String> routineDays) {
    final daysSet = <int>{};
    for (final d in routineDays) {
      final clean = d.trim().toLowerCase();
      if (clean == 'm1' || clean == 'm' || clean == 'mon' || clean == 'monday') {
        daysSet.add(DateTime.monday);
      } else if (clean == 't1' || clean == 'tue' || clean == 'tuesday') {
        daysSet.add(DateTime.tuesday);
      } else if (clean == 'w' || clean == 'wed' || clean == 'wednesday') {
        daysSet.add(DateTime.wednesday);
      } else if (clean == 't2' || clean == 'th' || clean == 'thu' || clean == 'thursday') {
        daysSet.add(DateTime.thursday);
      } else if (clean == 'f' || clean == 'fri' || clean == 'friday') {
        daysSet.add(DateTime.friday);
      } else if (clean == 's1' || clean == 'sa' || clean == 'sat' || clean == 'saturday') {
        daysSet.add(DateTime.saturday);
      } else if (clean == 's2' || clean == 'su' || clean == 'sun' || clean == 'sunday') {
        daysSet.add(DateTime.sunday);
      } else if (clean == 't') {
        if (!daysSet.contains(DateTime.tuesday)) {
          daysSet.add(DateTime.tuesday);
        } else {
          daysSet.add(DateTime.thursday);
        }
      } else if (clean == 's') {
        if (!daysSet.contains(DateTime.saturday)) {
          daysSet.add(DateTime.saturday);
        } else {
          daysSet.add(DateTime.sunday);
        }
      }
    }
    final list = daysSet.toList()..sort();
    return list.isNotEmpty ? list : [DateTime.monday, DateTime.wednesday, DateTime.friday];
  }

  /// Generates schedule items based solely on user's profile, routine days, and fitness level.
  static List<PlanScheduleItem> _buildScheduleFromProfile(
    ProfileModel profile,
    List<WorkoutModel> allWorkouts,
  ) {
    final userMinutes = profile.workoutMinutes;
    final level = profile.fitnessLevel;
    final userLevel = level.trim().toLowerCase();

    // 1. Strict fitness level match so Beginner/Intermediate/Advanced receive level-appropriate workouts
    List<WorkoutModel> levelWorkouts = userLevel.isNotEmpty
        ? allWorkouts.where((w) => w.difficulty.trim().toLowerCase() == userLevel).toList()
        : allWorkouts;
    if (levelWorkouts.isEmpty) {
      levelWorkouts = allWorkouts;
    }

    // 2. Parse weekdays selected by user
    final weekdays = _parseWeekdays(profile.weeklyRoutineDays);

    // 3. Compute dates for current calendar week (Monday to Sunday)
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final monday = todayMidnight.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    const monthNames = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateRangeLabel = monday.month == sunday.month
        ? '${monthNames[monday.month]} ${monday.day} – ${sunday.day}'
        : '${monthNames[monday.month]} ${monday.day} – ${monthNames[sunday.month]} ${sunday.day}';

    const dayLabels = ['', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    final items = <PlanScheduleItem>[];

    for (int i = 0; i < weekdays.length; i++) {
      final weekday = weekdays[i];
      final itemDate = monday.add(Duration(days: weekday - 1));
      final dayLabel = dayLabels[weekday];
      final isToday = now.weekday == weekday;

      final workout = levelWorkouts[i % levelWorkouts.length];

      String? subtitleDetail;
      String? adviceHighlight;
      String? readyBadgeText;

      final cat = workout.category.toLowerCase();
      if (cat.contains('cardio')) {
        subtitleDetail = 'Equipment Free';
        adviceHighlight = 'Gentle on joints • High calorie burn';
      } else if (cat.contains('strength')) {
        subtitleDetail = 'Strength & Core';
        adviceHighlight = 'Build lean muscle & endurance';
      } else if (cat.contains('mobility') || cat.contains('recovery') || cat.contains('yoga')) {
        subtitleDetail = 'Recovery & Balance';
        adviceHighlight = 'Gentle mobility • Posture reset';
      } else {
        subtitleDetail = workout.category;
        adviceHighlight = 'Daily habit • Target consistency';
      }

      if (isToday) {
        readyBadgeText = 'READY';
      }

      items.add(
        PlanScheduleItem(
          id: 'plan_${dayLabel.toLowerCase()}_${itemDate.day}',
          dayLabel: dayLabel,
          dayNumber: itemDate.day,
          assignedWeekday: weekday,
          dateRangeLabel: dateRangeLabel,
          status: isToday ? PlanItemStatus.todayReady : PlanItemStatus.upcoming,
          title: workout.title,
          durationMinutes: workout.durationMinutes > 0 ? workout.durationMinutes : userMinutes,
          category: workout.category,
          subtitleDetail: subtitleDetail,
          adviceHighlight: adviceHighlight,
          readyBadgeText: readyBadgeText,
          imageUrl: workout.imageUrl,
          workout: workout,
        ),
      );
    }

    return items;
  }
}

