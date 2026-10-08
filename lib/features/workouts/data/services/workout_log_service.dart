import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/workout_session.dart';

class WorkoutLogService extends ChangeNotifier {
  static final WorkoutLogService _instance = WorkoutLogService._internal();
  factory WorkoutLogService() => _instance;
  WorkoutLogService._internal();

  static WorkoutLogService get instance => _instance;

  static const String _storageKey = 'fitness_workout_sessions_v1';

  List<WorkoutSession> _sessions = [];
  bool _isInitialized = false;

  List<WorkoutSession> get sessions => List.unmodifiable(_sessions);
  bool get isInitialized => _isInitialized;

  int get totalWorkouts => _sessions.length;

  int get totalMinutes =>
      _sessions.fold(0, (acc, s) => acc + s.durationMinutes);

  int get totalCalories =>
      _sessions.fold(0, (acc, s) => acc + s.calories);

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? jsonList = prefs.getStringList(_storageKey);
      if (jsonList != null && jsonList.isNotEmpty) {
        _sessions = jsonList
            .map((item) {
              try {
                return WorkoutSession.fromJson(item);
              } catch (_) {
                return null;
              }
            })
            .whereType<WorkoutSession>()
            .toList();

        // Sort descending by endTime
        _sessions.sort((a, b) => b.endTime.compareTo(a.endTime));
      } else {
        _sessions = [];
      }
    } catch (e) {
      debugPrint('WorkoutLogService init error: $e');
      _sessions = [];
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> addSession(WorkoutSession session) async {
    // Insert newest first
    _sessions.insert(0, session);
    notifyListeners();

    // Persist to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> jsonList =
          _sessions.map((s) => s.toJson()).toList();
      await prefs.setStringList(_storageKey, jsonList);
    } catch (e) {
      debugPrint('Error saving workout session locally: $e');
    }

    // Optionally mirror to Firestore if initialized
    try {
      if (Firebase.apps.isNotEmpty) {
        final firestore = FirebaseFirestore.instance;
        await firestore.collection('workout_logs').doc(session.id).set(session.toMap());
      }
    } catch (e) {
      debugPrint('Firestore sync optional skip: $e');
    }
  }

  /// Calculates the current consecutive day streak
  int getStreakDays([DateTime? clockNow]) {
    if (_sessions.isEmpty) return 0;

    final now = clockNow ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Get unique workout dates normalized to midnight
    final Set<DateTime> activeDates = _sessions.map((s) {
      return DateTime(s.endTime.year, s.endTime.month, s.endTime.day);
    }).toSet();

    if (activeDates.isEmpty) return 0;

    // Check if streak is active (worked out today or yesterday)
    DateTime checkDate;
    if (activeDates.contains(today)) {
      checkDate = today;
    } else if (activeDates.contains(yesterday)) {
      checkDate = yesterday;
    } else {
      return 0; // Streak broken
    }

    int streak = 0;
    while (activeDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Sets sessions directly (useful for testing or clearing)
  @visibleForTesting
  void setSessionsForTesting(List<WorkoutSession> testSessions) {
    _sessions = List.from(testSessions);
    _sessions.sort((a, b) => b.endTime.compareTo(a.endTime));
    notifyListeners();
  }
}
