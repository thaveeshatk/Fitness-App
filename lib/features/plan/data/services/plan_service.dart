import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_app/core/services/firebase_service.dart';
import 'package:fitness_app/features/auth/data/services/auth_service.dart';
import 'package:fitness_app/features/profile/data/models/profile_model.dart';
import 'package:fitness_app/features/profile/data/services/profile_service.dart';
import 'package:fitness_app/features/workouts/data/models/workout_model.dart';
import 'package:fitness_app/features/workouts/data/repositories/workout_repository.dart';
import 'package:fitness_app/features/plan/data/models/plan_schedule_item.dart';

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
    if (!FirebaseService.isInitialized) {
      final cached = _planCache[currentUid];
      return cached?.where((it) => it.isCompleted).length ?? 0;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_completionsCollection)
          .where('uid', isEqualTo: currentUid)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      developer.log('Error counting plan completions: $e', name: 'PlanService');
      final cached = _planCache[currentUid];
      return cached?.where((it) => it.isCompleted).length ?? 0;
    }
  }

  /// Loads the weekly plan tailored to the user's profile, overlaying any
  /// completion status the signed-in user has saved in Firestore.
  static Future<List<PlanScheduleItem>> getWeeklyPlan({String? uid, bool forceRefresh = false}) async {
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
    if (!FirebaseService.isInitialized) {
      return plan;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_completionsCollection)
          .where('uid', isEqualTo: uid)
          .get();

      final completedIds = snapshot.docs.map((doc) => doc.data()['itemId'] as String).toSet();
      if (completedIds.isEmpty) return plan;

      return plan.map((item) {
        if (completedIds.contains(item.id)) {
          return item.copyWith(status: PlanItemStatus.completed);
        }
        return item;
      }).toList();
    } catch (e) {
      developer.log('Failed to load persisted plan completions: $e', name: 'PlanService');
      return plan;
    }
  }

  /// Calculates the current progress metrics:
  /// (completedCount, totalCount, progressFraction, remainingCount)
  static Map<String, dynamic> calculateMetrics(List<PlanScheduleItem> items) {
    final completedCount = items.where((it) => it.isCompleted).length;
    final totalCount = items.length;
    final remainingCount = totalCount - completedCount;
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

  /// Generates the wireframe-specified plan items enriched with profile data and linked workouts.
  static List<PlanScheduleItem> _buildScheduleFromProfile(
    ProfileModel profile,
    List<WorkoutModel> allWorkouts,
  ) {
    final userMinutes = profile.workoutMinutes;
    final level = profile.fitnessLevel;

    // Helper to find closest matching workout from repository
    WorkoutModel findWorkout(String categoryFallback, {String? titleKeyword}) {
      if (titleKeyword != null) {
        final match = allWorkouts.firstWhere(
          (w) => w.title.toLowerCase().contains(titleKeyword.toLowerCase()),
          orElse: () => allWorkouts.first,
        );
        return match;
      }
      return allWorkouts.firstWhere(
        (w) => w.category.toLowerCase() == categoryFallback.toLowerCase(),
        orElse: () => allWorkouts.first,
      );
    }

    final fullBodyWorkout = findWorkout('Strength', titleKeyword: 'Full Body');
    final cardioWorkout = findWorkout('Cardio', titleKeyword: 'Tabata');
    final strengthWorkout = findWorkout('Strength', titleKeyword: 'Pyramid');
    final mobilityWorkout = findWorkout('Mobility', titleKeyword: 'Mobility');

    return [
      // 1. Monday
      PlanScheduleItem(
        id: 'plan_mon_13',
        dayLabel: 'MON',
        dayNumber: 13,
        dateRangeLabel: 'Current Week',
        status: PlanItemStatus.todayReady,
        title: level == 'Advanced' ? 'Full Body Advanced' : 'Full Body Beginner',
        durationMinutes: userMinutes,
        category: 'Strength',
        imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=600&auto=format&fit=crop',
        workout: fullBodyWorkout,
      ),

      // 2. Tuesday (Active Rest / Recovery)
      PlanScheduleItem(
        id: 'plan_tue_14',
        dayLabel: 'TUE',
        dayNumber: 14,
        dateRangeLabel: 'Current Week',
        status: PlanItemStatus.upcoming,
        title: 'Light Core & Walk',
        durationMinutes: 15,
        category: 'Recovery',
        imageUrl: 'https://images.unsplash.com/photo-1545205597-3d9d02c29597?q=80&w=600&auto=format&fit=crop',
        workout: mobilityWorkout,
      ),

      // 3. Wednesday (Ready)
      PlanScheduleItem(
        id: 'plan_wed_15',
        dayLabel: 'WED',
        dayNumber: 15,
        dateRangeLabel: 'Current Week',
        status: PlanItemStatus.upcoming,
        title: 'Low Impact Cardio',
        durationMinutes: userMinutes,
        category: 'Cardio',
        subtitleDetail: 'Equipment Free',
        adviceHighlight: 'Gentle on knees • High calorie burn',
        readyBadgeText: 'READY',
        imageUrl: 'https://images.unsplash.com/photo-1548690312-e3b507d8c110?q=80&w=600&auto=format&fit=crop',
        workout: cardioWorkout,
      ),

      // 4. Friday (Upcoming)
      PlanScheduleItem(
        id: 'plan_fri_17',
        dayLabel: 'FRI',
        dayNumber: 17,
        dateRangeLabel: 'Current Week',
        status: PlanItemStatus.upcoming,
        title: 'Beginner Strength',
        durationMinutes: userMinutes,
        category: 'Strength',
        imageUrl: 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?q=80&w=600&auto=format&fit=crop',
        workout: strengthWorkout,
      ),

      // 5. Sunday (Upcoming)
      PlanScheduleItem(
        id: 'plan_sun_19',
        dayLabel: 'SUN',
        dayNumber: 19,
        dateRangeLabel: 'Current Week',
        status: PlanItemStatus.upcoming,
        title: 'Mobility & Posture Reset',
        durationMinutes: 10,
        category: 'Recovery',
        imageUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=600&auto=format&fit=crop',
        workout: mobilityWorkout,
      ),
    ];
  }
}

