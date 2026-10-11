import 'package:flutter/material.dart';
import '../../../profile/data/models/profile_model.dart';
import '../../../workouts/data/models/workout_model.dart';
import '../../../workouts/data/repositories/workout_repository.dart';

/// Model representing a quick bite-sized workout item for the Home screen
class QuickWorkoutItem {
  final WorkoutModel workout;
  final String title;
  final String duration;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const QuickWorkoutItem({
    required this.workout,
    required this.title,
    required this.duration,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });
}

/// Service that provides personalized workout recommendations based on
/// the authenticated user's profile, fitness goals, level, equipment, and workout history.
class RecommendationService {
  RecommendationService._();

  /// Returns the top recommended workout for "YOUR WORKOUT TODAY"
  static WorkoutModel getTodaysRecommendedWorkout({
    required ProfileModel profile,
    required List<WorkoutModel> allWorkouts,
    List<Map<String, dynamic>> recentHistory = const [],
  }) {
    if (allWorkouts.isEmpty) {
      return WorkoutRepository.getMockWorkouts().first;
    }

    // 1. Filter out incompatible difficulty (Beginner never gets Advanced)
    final userLevel = profile.fitnessLevel.trim().toLowerCase();
    List<WorkoutModel> candidates = allWorkouts;
    if (userLevel == 'beginner') {
      candidates = allWorkouts.where((w) => w.difficulty.trim().toLowerCase() != 'advanced').toList();
    } else if (userLevel == 'advanced') {
      final adv = allWorkouts.where((w) => w.difficulty.trim().toLowerCase() == 'advanced').toList();
      if (adv.isNotEmpty) candidates = adv;
    }

    if (candidates.isEmpty) {
      candidates = allWorkouts;
    }

    // 2. When a workout is completed today, exclude it to recommend another suitable workout
    if (recentHistory.isNotEmpty) {
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final completedTodayIds = recentHistory
          .where((h) => (h['completedAt']?.toString() ?? '').startsWith(todayStr))
          .map((h) => h['workoutId']?.toString())
          .toSet();

      final uncompletedToday = candidates.where((w) => !completedTodayIds.contains(w.id)).toList();
      if (uncompletedToday.isNotEmpty) {
        candidates = uncompletedToday;
      }
    }

    final scored = candidates.map((workout) {
      double score = _scoreWorkout(workout, profile, recentHistory);
      return MapEntry(workout, score);
    }).toList();

    scored.sort((a, b) => b.value.compareTo(a.value));
    final best = scored.first.key;

    // Display only one recommended individual workout, not a workout set
    if (best.exercises.length > 1) {
      final individualExercise = best.exercises.firstWhere(
        (e) => !e.phase.toLowerCase().contains('prep'),
        orElse: () => best.exercises.first,
      );
      return best.copyWith(
        exercises: [individualExercise],
        durationMinutes: (best.durationMinutes / best.exercises.length).ceil().clamp(5, 15),
        calories: (best.calories / best.exercises.length).round().clamp(40, 100),
      );
    }

    return best;
  }

  /// Returns the secondary recommendation for "RECOMMENDED FOR YOU"
  /// Workouts match user's selected fitness level (e.g. Beginner only receives Beginner recommendations).
  static ({WorkoutModel workout, String reason}) getRecommendedForYou({
    required ProfileModel profile,
    required List<WorkoutModel> allWorkouts,
    required WorkoutModel todaysWorkout,
    List<Map<String, dynamic>> recentHistory = const [],
  }) {
    if (allWorkouts.isEmpty) {
      return (workout: WorkoutRepository.getMockWorkouts().first, reason: 'Based on activity');
    }

    // 1. Strict fitness level match so user only receives level-appropriate recommendations
    final userLevel = profile.fitnessLevel.trim().toLowerCase();
    List<WorkoutModel> levelWorkouts = userLevel.isNotEmpty
        ? allWorkouts.where((w) => w.difficulty.trim().toLowerCase() == userLevel).toList()
        : allWorkouts;
    if (levelWorkouts.isEmpty) {
      levelWorkouts = allWorkouts;
    }

    // 2. Filter out today's workout to avoid recommending the same one twice
    var candidates = levelWorkouts.where((w) => w.id != todaysWorkout.id).toList();
    if (candidates.isEmpty) {
      candidates = levelWorkouts;
    }

    // Prefer complementary category if available
    final differentCategory = candidates.where((w) => w.category != todaysWorkout.category).toList();
    final listToScore = differentCategory.isNotEmpty ? differentCategory : candidates;

    final scored = listToScore.map((workout) {
      double score = _scoreWorkout(workout, profile, recentHistory);
      return MapEntry(workout, score);
    }).toList();

    scored.sort((a, b) => b.value.compareTo(a.value));
    final best = scored.first.key;

    // Generate contextual reason string
    String reason = '${profile.fitnessLevel} friendly';
    if (profile.goals.isNotEmpty) {
      reason = 'Matches: ${profile.goals.first}';
    }

    return (workout: best, reason: reason);
  }

  /// Returns 3 personalized bite-sized workouts (duration <= 20 min) for "QUICK WORKOUTS":
  /// 1. Strength / Full Body
  /// 2. Cardio / HIIT
  /// 3. Stretch / Recovery
  static List<QuickWorkoutItem> getQuickWorkouts({
    required ProfileModel profile,
    required List<WorkoutModel> allWorkouts,
  }) {
    if (allWorkouts.isEmpty) return const [];

    // Filter by short duration or sort by shortest
    final shortWorkouts = allWorkouts.where((w) => w.durationMinutes <= 25).toList();
    final pool = shortWorkouts.isNotEmpty ? shortWorkouts : allWorkouts;

    // Helper to find best match for a keyword/category
    WorkoutModel findBest(String category, String keyword, WorkoutModel fallback) {
      final matches = pool.where((w) {
        final cat = w.category.toLowerCase();
        final title = w.title.toLowerCase();
        return cat == category.toLowerCase() || title.contains(keyword.toLowerCase());
      }).toList();

      if (matches.isNotEmpty) {
        matches.sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
        return matches.first;
      }
      return fallback;
    }

    final fallback = allWorkouts.first;
    final w1 = findBest('Strength', 'body', fallback);
    final w2 = findBest('Cardio', 'cardio', allWorkouts.length > 1 ? allWorkouts[1] : fallback);
    final w3 = findBest('Mobility', 'stretch', allWorkouts.length > 2 ? allWorkouts[2] : fallback);

    return [
      QuickWorkoutItem(
        workout: w1,
        title: '${w1.durationMinutes} Min Full\nBody',
        duration: '${w1.durationMinutes} min',
        icon: Icons.accessibility_new_rounded,
        iconBg: const Color(0xFFF1F5F9),
        iconColor: const Color(0xFF64748B),
      ),
      QuickWorkoutItem(
        workout: w2,
        title: '${w2.durationMinutes} Min\nCardio',
        duration: '${w2.durationMinutes} min',
        icon: Icons.directions_run_rounded,
        iconBg: const Color(0xFFFEE2E2),
        iconColor: const Color(0xFFDC2626),
      ),
      QuickWorkoutItem(
        workout: w3,
        title: '${w3.durationMinutes} Min\nStretch',
        duration: '${w3.durationMinutes} min',
        icon: Icons.self_improvement_rounded,
        iconBg: const Color(0xFFCCFBF1),
        iconColor: const Color(0xFF0D9488),
      ),
    ];
  }

  /// Calculates a personalized relevance score for a given workout
  static double _scoreWorkout(
    WorkoutModel workout,
    ProfileModel profile,
    List<Map<String, dynamic>> recentHistory,
  ) {
    double score = 50.0;

    // 1. Fitness Level Match (Weight: 25)
    final userLevel = profile.fitnessLevel.toLowerCase();
    final workoutDiff = workout.difficulty.toLowerCase();
    if (userLevel == workoutDiff) {
      score += 25.0;
    } else if (userLevel == 'beginner' && workoutDiff == 'advanced') {
      score -= 20.0;
    } else if (userLevel == 'advanced' && workoutDiff == 'beginner') {
      score += 5.0;
    }

    // 2. Goals Match (Weight: 30)
    for (final goal in profile.goals) {
      final g = goal.toLowerCase();
      final cat = workout.category.toLowerCase();
      final sub = workout.subCategory.toLowerCase();

      if (g.contains('muscle') || g.contains('strength')) {
        if (cat == 'strength') score += 30.0;
      }
      if (g.contains('weight loss') || g.contains('fat')) {
        if (cat == 'cardio' || sub.contains('hiit')) score += 30.0;
      }
      if (g.contains('stamina') || g.contains('endurance')) {
        if (cat == 'cardio') score += 25.0;
      }
      if (g.contains('flexibility') || g.contains('mobility')) {
        if (cat == 'mobility' || cat == 'recovery') score += 30.0;
      }
      if (g.contains('active') || g.contains('tone')) {
        if (workout.durationMinutes <= 30) score += 15.0;
      }
    }

    // 3. Preferred Styles Match (Weight: 20)
    for (final style in profile.preferredStyles) {
      final s = style.toLowerCase();
      final cat = workout.category.toLowerCase();
      final title = workout.title.toLowerCase();
      final tags = workout.tags.map((t) => t.toLowerCase()).toList();

      if (cat.contains(s) || title.contains(s) || tags.contains(s)) {
        score += 20.0;
      }
    }

    // 4. Equipment Compatibility (Weight: 15)
    final isBodyweightWorkout = workout.equipment.isEmpty ||
        workout.equipment.every(
          (e) => e.toLowerCase().contains('none') || e.toLowerCase().contains('bodyweight'),
        );

    if (isBodyweightWorkout) {
      score += 15.0;
    } else {
      // Check if user has the equipment
      final userEq = profile.equipment.map((e) => e.toLowerCase()).toList();
      bool hasEquipment = workout.equipment.any(
        (eq) => userEq.any((ue) => ue.contains(eq.toLowerCase()) || eq.toLowerCase().contains(ue)),
      );
      if (hasEquipment) {
        score += 10.0;
      } else {
        score -= 25.0; // Needs equipment user doesn't have
      }
    }

    // 5. Preferred Duration Match (Weight: 10)
    final diff = (workout.durationMinutes - profile.workoutMinutes).abs();
    if (diff <= 5) {
      score += 10.0;
    } else if (diff <= 15) {
      score += 5.0;
    }

    // 6. Custom workout preference (boost user-created workouts)
    if (workout.isCustom) {
      score += 15.0;
    }

    // 7. Workout History Variety (avoid repeating same workout from today)
    if (recentHistory.isNotEmpty) {
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      bool doneToday = recentHistory.any((h) {
        final date = h['completedAt']?.toString() ?? '';
        return h['workoutId'] == workout.id && date.startsWith(todayStr);
      });
      if (doneToday) {
        score -= 30.0; // Don't recommend same workout already finished today
      }
    }

    return score;
  }
}
