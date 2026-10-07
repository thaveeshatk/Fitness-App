import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/workout_model.dart';
import '../repositories/workout_repository.dart';

/// Service responsible for managing Workouts and supporting full CRUD operations.
/// Connects to Cloud Firestore under collection 'custom_workouts' when initialized,
/// with seamless local in-memory fallback for offline or unauthenticated mode.
class WorkoutService {
  WorkoutService._();

  static const String _collection = 'custom_workouts';

  /// ValueNotifier that increments whenever workouts are created, updated, or deleted.
  static final ValueNotifier<int> workoutsRevisionNotifier = ValueNotifier<int>(0);

  static final List<WorkoutModel> _inMemoryCustomWorkouts = [
    const WorkoutModel(
      id: 'custom_default_01',
      title: 'My Daily Core & Mobility',
      specificationSubtitle: 'Custom User Routine • Personalized Fitness Track',
      coach: 'You (Personal Routine)',
      coachRole: 'Custom Creator',
      coachAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150&auto=format&fit=crop',
      rating: 5.0,
      durationMinutes: 20,
      calories: 180,
      category: 'Mobility',
      subCategory: 'PERSONAL CIRCUIT',
      difficulty: 'Beginner',
      equipment: ['Exercise Mat'],
      tags: ['MY ROUTINE', 'CORE', 'MOBILITY'],
      imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=600&auto=format&fit=crop',
      overview: 'Gentle core engagement and full-body dynamic flow built to start each morning with energy and focus.',
      safetyInfo: 'Focus on diaphragmatic breathing and never rush lumbar movements.',
      isCustom: true,
      exercises: [
        ExerciseItem(
          id: 'ce_01',
          name: 'Warm-Up Jumping Jacks',
          phase: 'PHASE: PREP',
          subtitle: 'Dynamic movement',
          badge: '3 min',
          imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=1200&auto=format&fit=crop',
        ),
        ExerciseItem(
          id: 'ce_02',
          name: 'Plank Hold',
          phase: 'PHASE: CORE',
          subtitle: 'Isometric anti-extension',
          badge: '3 sets × 45 sec',
          imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=1200&auto=format&fit=crop',
        ),
        ExerciseItem(
          id: 'ce_03',
          name: 'Child\'s Pose Breathwork',
          phase: 'PHASE: RECOVERY',
          subtitle: 'Heart rate lowering reset',
          badge: '4 min',
          imageUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?q=80&w=1200&auto=format&fit=crop',
        ),
      ],
    ),
  ];

  /// Fetches custom user workouts from Firestore or in-memory fallback.
  static Future<List<WorkoutModel>> getCustomWorkouts() async {
    if (!FirebaseService.isInitialized) {
      return List.unmodifiable(_inMemoryCustomWorkouts);
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_collection)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final firestoreList = snapshot.docs.map((doc) {
          final data = doc.data();
          return WorkoutModel.fromMap(data, doc.id);
        }).toList();

        // Merge or replace in-memory cache
        _inMemoryCustomWorkouts.clear();
        _inMemoryCustomWorkouts.addAll(firestoreList);
        return List.unmodifiable(_inMemoryCustomWorkouts);
      }
    } catch (e, stack) {
      developer.log(
        'Failed to fetch workouts from Firestore, using cache: $e',
        name: 'WorkoutService',
        error: e,
        stackTrace: stack,
      );
    }

    return List.unmodifiable(_inMemoryCustomWorkouts);
  }

  /// Fetches all workouts (custom workouts first, followed by system curated workouts).
  static Future<List<WorkoutModel>> getAllWorkouts() async {
    final customList = await getCustomWorkouts();
    final systemList = WorkoutRepository.getMockWorkouts();

    return [...customList, ...systemList];
  }

  /// Creates a new custom workout and saves to Firestore & cache.
  static Future<WorkoutModel> createWorkout(WorkoutModel workout) async {
    final String workoutId = workout.id.isNotEmpty
        ? workout.id
        : 'custom_${DateTime.now().millisecondsSinceEpoch}';

    final readyWorkout = workout.copyWith(
      id: workoutId,
      isCustom: true,
      coach: workout.coach.isEmpty ? 'You (Custom)' : workout.coach,
      subCategory: workout.subCategory.isEmpty ? 'CUSTOM ROUTINE' : workout.subCategory,
      tags: workout.tags.isEmpty ? ['CUSTOM', 'MY ROUTINE'] : workout.tags,
    );

    // Update in-memory cache
    _inMemoryCustomWorkouts.insert(0, readyWorkout);
    workoutsRevisionNotifier.value++;

    if (FirebaseService.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection(_collection)
            .doc(workoutId)
            .set(readyWorkout.toMap());

        developer.log('Custom workout created in Firestore: $workoutId', name: 'WorkoutService');
      } catch (e, stack) {
        developer.log(
          'Error saving custom workout to Firestore: $e',
          name: 'WorkoutService',
          error: e,
          stackTrace: stack,
        );
      }
    } else {
      // Simulate slight async response for realistic feedback
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }

    return readyWorkout;
  }

  /// Updates an existing custom workout in Firestore and cache.
  static Future<WorkoutModel> updateWorkout(WorkoutModel workout) async {
    final index = _inMemoryCustomWorkouts.indexWhere((w) => w.id == workout.id);
    if (index != -1) {
      _inMemoryCustomWorkouts[index] = workout;
    } else {
      _inMemoryCustomWorkouts.insert(0, workout);
    }

    workoutsRevisionNotifier.value++;

    if (FirebaseService.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection(_collection)
            .doc(workout.id)
            .set(workout.toMap(), SetOptions(merge: true));

        developer.log('Custom workout updated in Firestore: ${workout.id}', name: 'WorkoutService');
      } catch (e, stack) {
        developer.log(
          'Error updating custom workout in Firestore: $e',
          name: 'WorkoutService',
          error: e,
          stackTrace: stack,
        );
      }
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }

    return workout;
  }

  /// Deletes a custom workout by ID.
  static Future<bool> deleteWorkout(String workoutId) async {
    _inMemoryCustomWorkouts.removeWhere((w) => w.id == workoutId);
    workoutsRevisionNotifier.value++;

    if (FirebaseService.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection(_collection)
            .doc(workoutId)
            .delete();

        developer.log('Custom workout deleted from Firestore: $workoutId', name: 'WorkoutService');
      } catch (e, stack) {
        developer.log(
          'Error deleting custom workout from Firestore: $e',
          name: 'WorkoutService',
          error: e,
          stackTrace: stack,
        );
      }
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }

    return true;
  }
}
