import 'dart:developer' as developer;
import 'package:fitness_app/features/profile/data/models/profile_model.dart';
import 'package:fitness_app/features/profile/data/services/profile_service.dart';
import 'package:fitness_app/features/workouts/data/models/workout_model.dart';
import 'package:fitness_app/features/workouts/data/repositories/workout_repository.dart';
import 'package:fitness_app/features/plan/data/models/plan_schedule_item.dart';

/// Service responsible for managing the user's weekly workout plan.
/// Dynamically connects user's profile preferences with workouts from [WorkoutRepository].
class PlanService {
  PlanService._();

  static List<PlanScheduleItem>? _cachedPlan;
  
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

  /// Loads the weekly plan tailored to the user's profile.
  static Future<List<PlanScheduleItem>> getWeeklyPlan({bool forceRefresh = false}) async {
    if (_cachedPlan != null && !forceRefresh) {
      return _cachedPlan!;
    }

    final profile = await ProfileService.getProfile();
    final allWorkouts = WorkoutRepository.getMockWorkouts();

    _cachedPlan = _buildScheduleFromProfile(profile, allWorkouts);
    developer.log('Weekly plan loaded: ${_cachedPlan!.length} items', name: 'PlanService');
    return _cachedPlan!;
  }

  /// Calculates the current progress metrics:
  /// (completedCount, totalCount, progressFraction, remainingCount)
  static Map<String, dynamic> calculateMetrics(List<PlanScheduleItem> items) {
    // According to wireframe: "3 of 5 completed", "2 sessions to go", 60%
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

  /// Updates status of a workout item (e.g. mark completed when finished)
  static void markWorkoutCompleted(String itemId) {
    if (_cachedPlan == null) return;
    _cachedPlan = _cachedPlan!.map((item) {
      if (item.id == itemId) {
        return item.copyWith(status: PlanItemStatus.completed);
      }
      return item;
    }).toList();
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
      // 1. Monday 13 (Completed)
      PlanScheduleItem(
        id: 'plan_mon_13',
        dayLabel: 'MON',
        dayNumber: 13,
        dateRangeLabel: 'Nov 13 – 19',
        status: PlanItemStatus.completed,
        title: level == 'Advanced' ? 'Full Body Advanced' : 'Full Body Beginner',
        durationMinutes: userMinutes,
        category: 'Strength',
        imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=600&auto=format&fit=crop',
        workout: fullBodyWorkout,
      ),

      // 2. Tuesday 14 (Completed Active Rest / Recovery)
      PlanScheduleItem(
        id: 'plan_tue_14',
        dayLabel: 'TUE',
        dayNumber: 14,
        dateRangeLabel: 'Nov 13 – 19',
        status: PlanItemStatus.completed,
        title: 'Light Core & Walk',
        durationMinutes: 15,
        category: 'Recovery',
        imageUrl: 'https://images.unsplash.com/photo-1545205597-3d9d02c29597?q=80&w=600&auto=format&fit=crop',
        workout: mobilityWorkout,
      ),

      // 3. Wednesday 15 (Today • Ready)
      PlanScheduleItem(
        id: 'plan_wed_15',
        dayLabel: 'WED',
        dayNumber: 15,
        dateRangeLabel: 'Nov 13 – 19',
        status: PlanItemStatus.todayReady,
        title: 'Low Impact Cardio',
        durationMinutes: userMinutes,
        category: 'Cardio',
        subtitleDetail: 'Equipment Free',
        adviceHighlight: 'Gentle on knees • High calorie burn',
        readyBadgeText: 'READY',
        imageUrl: 'https://images.unsplash.com/photo-1548690312-e3b507d8c110?q=80&w=600&auto=format&fit=crop',
        workout: cardioWorkout,
      ),

      // 4. Friday 17 (Upcoming)
      PlanScheduleItem(
        id: 'plan_fri_17',
        dayLabel: 'FRI',
        dayNumber: 17,
        dateRangeLabel: 'Nov 13 – 19',
        status: PlanItemStatus.upcoming,
        title: 'Beginner Strength',
        durationMinutes: userMinutes,
        category: 'Strength',
        imageUrl: 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?q=80&w=600&auto=format&fit=crop',
        workout: strengthWorkout,
      ),

      // 5. Sunday 19 (Upcoming)
      PlanScheduleItem(
        id: 'plan_sun_19',
        dayLabel: 'SUN',
        dayNumber: 19,
        dateRangeLabel: 'Nov 13 – 19',
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
