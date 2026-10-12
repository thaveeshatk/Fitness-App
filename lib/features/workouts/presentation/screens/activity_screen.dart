import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../data/models/workout_model.dart';
import 'exercise_guidance_screen.dart';
import 'workout_complete_screen.dart';
import '../../../progress/data/services/user_activity_service.dart';
import '../../../plan/data/services/plan_service.dart';

class ActivityScreen extends StatefulWidget {
  final WorkoutModel workout;
  final String? planItemId;

  const ActivityScreen({
    super.key,
    required this.workout,
    this.planItemId,
  });

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  int _totalSets = 3;

  int _intervalSecondsRemaining = 60;
  int _totalIntervalSeconds = 60;
  int _elapsedSeconds = 0; // Starts fresh at 00:00
  bool _isRunning = true;
  bool _isResting = false;
  bool _isTransitionToNextExercise = false;
  final int _restDurationSeconds = 30; // Standard 30-sec rest between sets
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.workout.exercises.isNotEmpty) {
      final firstEx = widget.workout.exercises.first;
      _totalIntervalSeconds = _calculateExerciseInterval(firstEx);
      _intervalSecondsRemaining = _totalIntervalSeconds;
      _totalSets = _calculateTotalSets(firstEx);
    }
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int _calculateExerciseInterval(ExerciseItem exercise) {
    final badge = exercise.badge.toLowerCase().trim();

    // 1. Explicit seconds (e.g., '45 sec', '30 sec', '20 sec', '40 sec', '60 sec', '30 sec/side')
    final secRegex = RegExp(r'(\d+)\s*(sec|seconds|s\b)');
    final secMatch = secRegex.firstMatch(badge);
    if (secMatch != null) {
      final val = int.tryParse(secMatch.group(1) ?? '');
      if (val != null && val > 0) return val;
    }

    // 2. EMOM drills (e.g., '15 reps every min', '10 reps every min')
    if (badge.contains('every min')) {
      return 60;
    }

    // 3. Multi-minute or single-minute continuous duration (e.g., '1 min', '2 min', '3 min', '4 min', '5 min', '4 sets × 1 min')
    final minRegex = RegExp(r'(\d+)\s*(min|minute|minutes|m\b)');
    final minMatch = minRegex.firstMatch(badge);
    if (minMatch != null) {
      final val = int.tryParse(minMatch.group(1) ?? '');
      if (val != null && val > 0) {
        return val * 60; // 1 min -> 60s, 2 min -> 120s, 3 min -> 180s, 4 min -> 240s, 5 min -> 300s
      }
    }

    // 4. Reps per side (e.g., '3 sets × 12 reps/side', '2 sets × 3 reps/side', '3 sets × 6 reps/side')
    final repsPerSideRegex = RegExp(r'(\d+)\s*(?:reps|rep)\s*/\s*side');
    final repsPerSideMatch = repsPerSideRegex.firstMatch(badge);
    if (repsPerSideMatch != null) {
      final reps = int.tryParse(repsPerSideMatch.group(1) ?? '');
      if (reps != null && reps > 0) {
        // Turkish get-up (3 reps) takes ~12s per rep (36s total); higher reps: ~4s/rep
        return (reps <= 4) ? (reps * 12) : ((reps * 4).clamp(30, 75));
      }
    }

    // 5. Standard repetitions (e.g., '3 sets × 6 reps', '3 sets × 8 reps', '3 sets × 10 reps', '3 sets × 12 reps', '3 sets × 16 reps', '3 sets × 20 reps')
    final repsRegex = RegExp(r'(\d+)\s*(reps|rep\b)');
    final repsMatch = repsRegex.firstMatch(badge);
    if (repsMatch != null) {
      final reps = int.tryParse(repsMatch.group(1) ?? '');
      if (reps != null && reps > 0) {
        // Natural pacing: ~3.5 seconds per repetition
        // 6 reps -> 21s, 8 reps -> 28s, 10 reps -> 35s, 12 reps -> 42s, 15 reps -> 52s, 16 reps -> 56s, 20 reps -> 70s
        return (reps * 3.5).round().clamp(20, 75);
      }
    }

    // 6. Rep ladder (e.g., '10 - 20 - 30 reps')
    if (badge.contains('10 - 20 - 30') || badge.contains('ladder')) {
      return 60;
    }

    // 7. Steps (e.g., '3 sets × 20 steps')
    final stepsRegex = RegExp(r'(\d+)\s*steps');
    final stepsMatch = stepsRegex.firstMatch(badge);
    if (stepsMatch != null) {
      final steps = int.tryParse(stepsMatch.group(1) ?? '');
      if (steps != null && steps > 0) {
        return (steps * 2).clamp(20, 60); // 20 steps -> 40s
      }
    }

    // 8. Cycles (e.g., '5 cycles')
    final cyclesRegex = RegExp(r'(\d+)\s*cycles');
    final cyclesMatch = cyclesRegex.firstMatch(badge);
    if (cyclesMatch != null) {
      final cycles = int.tryParse(cyclesMatch.group(1) ?? '');
      if (cycles != null && cycles > 0) {
        return (cycles * 8).clamp(20, 60); // 5 cycles -> 40s
      }
    }

    // Fallback default
    return 30;
  }

  int _calculateTotalSets(ExerciseItem exercise) {
    final badge = exercise.badge.toLowerCase().trim();

    // Check for explicit sets / rounds / cycles
    final setsRegex = RegExp(r'(\d+)\s*(sets|rounds|cycles)');
    final setsMatch = setsRegex.firstMatch(badge);
    if (setsMatch != null) {
      final val = int.tryParse(setsMatch.group(1) ?? '');
      if (val != null && val > 0) return val;
    }

    // Rep ladder (e.g., '10 - 20 - 30 reps') has 3 stages/sets
    if (badge.contains('10 - 20 - 30')) return 3;

    // Single continuous duration (e.g., '2 min', '3 min', '4 min', '5 min' continuous warm-up / cool-down)
    if (badge.contains('min') && !badge.contains('every min')) return 1;

    // If unilateral per side without explicit sets, 2 sets (one per side)
    if (badge.contains('/side') || badge.contains('per side')) return 2;

    // Standard default sets
    return 3;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning) return;

      setState(() {
        _elapsedSeconds++;
        if (_intervalSecondsRemaining > 0) {
          _intervalSecondsRemaining--;
        } else {
          final exercises = widget.workout.exercises;
          final hasMoreExercises = _currentExerciseIndex < exercises.length - 1;

          if (!_isResting) {
            // Active Interval ended:
            if (_currentSet < _totalSets) {
              // Transition into REST INTERVAL before the next set of this exercise
              _isResting = true;
              _isTransitionToNextExercise = false;
              _totalIntervalSeconds = _restDurationSeconds;
              _intervalSecondsRemaining = _totalIntervalSeconds;
            } else if (hasMoreExercises) {
              // All sets finished for current exercise -> Transition rest before next exercise!
              _isResting = true;
              _isTransitionToNextExercise = true;
              _totalIntervalSeconds = _restDurationSeconds;
              _intervalSecondsRemaining = _totalIntervalSeconds;
            } else {
              // All sets of final exercise finished!
              _isRunning = false;
              _intervalSecondsRemaining = 0;
              _showCompletionDialog();
            }
          } else {
            // Rest Interval ended:
            _isResting = false;
            if (_isTransitionToNextExercise) {
              // Advance to next exercise automatically!
              _isTransitionToNextExercise = false;
              if (_currentExerciseIndex < exercises.length - 1) {
                _currentExerciseIndex++;
                _currentSet = 1;
                final nextEx = exercises[_currentExerciseIndex];
                _totalIntervalSeconds = _calculateExerciseInterval(nextEx);
                _intervalSecondsRemaining = _totalIntervalSeconds;
                _totalSets = _calculateTotalSets(nextEx);
              }
            } else {
              // Advance to next set of current exercise!
              _currentSet++;
              final currentEx = exercises[_currentExerciseIndex];
              _totalIntervalSeconds = _calculateExerciseInterval(currentEx);
              _intervalSecondsRemaining = _totalIntervalSeconds;
            }
          }
        }
      });
    });
  }

  void _skipRest() {
    setState(() {
      _isResting = false;
      final exercises = widget.workout.exercises;
      if (_isTransitionToNextExercise) {
        _isTransitionToNextExercise = false;
        if (_currentExerciseIndex < exercises.length - 1) {
          _currentExerciseIndex++;
          _currentSet = 1;
          final nextEx = exercises[_currentExerciseIndex];
          _totalIntervalSeconds = _calculateExerciseInterval(nextEx);
          _intervalSecondsRemaining = _totalIntervalSeconds;
          _totalSets = _calculateTotalSets(nextEx);
        } else {
          _showCompletionDialog();
        }
      } else {
        _currentSet++;
        final currentEx = exercises[_currentExerciseIndex];
        _totalIntervalSeconds = _calculateExerciseInterval(currentEx);
        _intervalSecondsRemaining = _totalIntervalSeconds;
      }
      _isRunning = true;
    });
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
  }

  void _resumeTimer() {
    setState(() {
      _isRunning = true;
    });
  }

  void _nextExercise() {
    final exercises = widget.workout.exercises;
    if (_currentExerciseIndex < exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _isResting = false;
        _isTransitionToNextExercise = false;
        final nextEx = exercises[_currentExerciseIndex];
        _totalIntervalSeconds = _calculateExerciseInterval(nextEx);
        _intervalSecondsRemaining = _totalIntervalSeconds;
        _totalSets = _calculateTotalSets(nextEx);
        _currentSet = 1;
        _isRunning = true;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _jumpToExercise(int index) {
    final exercises = widget.workout.exercises;
    if (index >= 0 && index < exercises.length) {
      setState(() {
        _currentExerciseIndex = index;
        _isResting = false;
        _isTransitionToNextExercise = false;
        final targetEx = exercises[index];
        _totalIntervalSeconds = _calculateExerciseInterval(targetEx);
        _intervalSecondsRemaining = _totalIntervalSeconds;
        _totalSets = _calculateTotalSets(targetEx);
        _currentSet = 1;
        _isRunning = true;
      });
    }
  }

  void _confirmEndSession() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'End Activity?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: Text(
          'Are you sure you want to quit the current workout session?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Continue',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => WorkoutCompleteScreen(
                    workoutTitle: widget.workout.title,
                    durationMinutes: (_elapsedSeconds / 60).ceil() > 0 ? (_elapsedSeconds / 60).ceil() : 25,
                    activeMinutes: (_elapsedSeconds / 60).floor() > 0 ? (_elapsedSeconds / 60).floor() : 22,
                    caloriesBurned: widget.workout.calories,
                    coachName: widget.workout.coach,
                    coachAvatar: widget.workout.coachAvatar,
                  ),
                ),
              );
            },
            child: Text(
              'End Session',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFC8F3EA),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, size: 48, color: Color(0xFF005953)),
            ),
            const SizedBox(height: 16),
            Text(
              'Workout Complete! 🎉',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You successfully completed all ${widget.workout.exercises.length} exercises in "${widget.workout.title}".',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatPill('TIME', '${(_elapsedSeconds / 60).floor()}m ${(_elapsedSeconds % 60)}s'),
                _buildStatPill('CALORIES', '~${widget.workout.calories} kcal'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005953),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close dialog
                  final elapsedMins = (_elapsedSeconds / 60).ceil();
                  final duration = elapsedMins > 0 ? elapsedMins : widget.workout.durationMinutes;
                  final active = (_elapsedSeconds / 60).floor() > 0 
                      ? (_elapsedSeconds / 60).floor() 
                      : (duration > 2 ? duration - 2 : duration);

                  // Log completed workout to Firebase Firestore
                  UserActivityService.logCompletedWorkout(
                    workoutId: widget.workout.id,
                    workoutTitle: widget.workout.title,
                    category: widget.workout.category,
                    durationMinutes: duration,
                    calories: widget.workout.calories,
                    difficulty: widget.workout.difficulty,
                    imageUrl: widget.workout.imageUrl,
                    planItemId: widget.planItemId,
                    isPlanWorkout: widget.planItemId != null,
                  );

                  if (widget.planItemId != null) {
                    PlanService.markWorkoutCompleted(widget.planItemId!);
                  }

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => WorkoutCompleteScreen(
                        workoutTitle: widget.workout.title,
                        durationMinutes: duration,
                        activeMinutes: active,
                        caloriesBurned: widget.workout.calories,
                        coachName: widget.workout.coach,
                        coachAvatar: widget.workout.coachAvatar,
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Finish & View Summary',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _openExerciseGuidance(ExerciseItem exercise) {
    // Optionally pause the active interval timer while studying guidance
    final wasRunning = _isRunning;
    if (_isRunning) {
      _pauseTimer();
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExerciseGuidanceScreen(
          exercise: exercise,
          workout: widget.workout,
        ),
      ),
    ).then((_) {
      // Resume timer if it was running before opening guidance
      if (wasRunning && mounted) {
        _resumeTimer();
      }
    });
  }

  String _formatElapsed(int totalSeconds) {
    final mins = (totalSeconds / 60).floor().toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.workout.exercises;
    final currentExercise = exercises.isNotEmpty ? exercises[_currentExerciseIndex] : null;
    final nextExercise = (_currentExerciseIndex < exercises.length - 1)
        ? exercises[_currentExerciseIndex + 1]
        : null;

    final progressPercent = (((_currentExerciseIndex + 1) / exercises.length) * 100).toInt();
    final remainingCount = exercises.length - (_currentExerciseIndex + 1);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: _buildSessionDrawer(context),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary, size: 24),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          'ACTIVITY',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: 2.0,
          ),
        ),
        actions: [
          Center(
            child: GestureDetector(
              onTap: _confirmEndSession,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  '[ END ]',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: UserAvatar(radius: 17),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── CARD 1: EXERCISE PROGRESS ────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFEDF2F7)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'EXERCISE PROGRESS',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          'Exercise ${_currentExerciseIndex + 1} of ${exercises.length} Completed ($progressPercent%)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF005953),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 6 Horizontal Segmented Bars
                    Row(
                      children: List.generate(exercises.length, (idx) {
                        final isCompleted = idx < _currentExerciseIndex;
                        final isCurrent = idx == _currentExerciseIndex;

                        return Expanded(
                          child: Container(
                            height: 6,
                            margin: EdgeInsets.only(right: idx < exercises.length - 1 ? 6 : 0),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? const Color(0xFF005953)
                                  : isCurrent
                                      ? const Color(0xFF005953)
                                      : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF005953)),
                            const SizedBox(width: 4),
                            Text(
                              nextExercise != null
                                  ? 'Up next: ${nextExercise.name}'
                                  : 'Final exercise in routine!',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$remainingCount REMAINING',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── CARD 2: CURRENT EXERCISE ─────────────────────────────────
              if (currentExercise != null)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFEDF2F7)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'CURRENT EXERCISE',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF005953),
                              letterSpacing: 0.8,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _isResting ? const Color(0xFFE65100) : const Color(0xFF005953),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _isResting
                                  ? (_isTransitionToNextExercise ? 'REST BEFORE NEXT EXERCISE' : 'SET REST')
                                  : 'SET $_currentSet OF $_totalSets',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Exercise Title
                      Text(
                        currentExercise.name,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC8F3EA),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              currentExercise.badge,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF005953),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Target rest: ${_restDurationSeconds}s',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // [ HOW TO PERFORM -> ] Button
                      GestureDetector(
                        onTap: () => _openExerciseGuidance(currentExercise),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.menu_book_rounded, size: 15, color: Color(0xFF005953)),
                              const SizedBox(width: 6),
                              Text(
                                'HOW TO PERFORM GUIDE →',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF005953),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // ── CARD 3: CIRCULAR INTERVAL TIMER DIAL ─────────────────────
              Container(
                padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFEDF2F7)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Dial Stack
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft Ambient Glow Aura behind timer dial
                        Container(
                          width: 175,
                          height: 175,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (_isResting ? const Color(0xFFE65100) : const Color(0xFF005953))
                                    .withValues(alpha: 0.08),
                                blurRadius: 36,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 190,
                          height: 190,
                          child: CircularProgressIndicator(
                            value: _totalIntervalSeconds > 0
                                ? (_intervalSecondsRemaining / _totalIntervalSeconds)
                                : 0.0,
                            strokeWidth: 12,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _isResting ? const Color(0xFFE65100) : const Color(0xFF005953),
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isResting
                                  ? (_isTransitionToNextExercise ? 'TRANSITION REST' : 'REST INTERVAL')
                                  : 'ACTIVE INTERVAL',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: _isResting ? const Color(0xFFE65100) : const Color(0xFF005953),
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatElapsed(_intervalSecondsRemaining),
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                color: _isResting ? const Color(0xFFE65100) : const Color(0xFF005953),
                                letterSpacing: -1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Elapsed: ${_formatElapsed(_elapsedSeconds)}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Active Linear Progress Timeline Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _totalIntervalSeconds > 0
                            ? 1.0 - (_intervalSecondsRemaining / _totalIntervalSeconds)
                            : 0.0,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _isResting ? const Color(0xFFE65100) : const Color(0xFF005953),
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 00:00  ACTIVE INTERVAL / REST INTERVAL  MM:SS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '00:00',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: _isResting ? const Color(0xFFE65100) : const Color(0xFF005953),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isResting
                                  ? (_isTransitionToNextExercise ? 'TRANSITION REST' : 'REST INTERVAL')
                                  : 'ACTIVE INTERVAL',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _isResting ? const Color(0xFFE65100) : const Color(0xFF005953),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _formatElapsed(_totalIntervalSeconds),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── PRIMARY ACTION BUTTON: [ NEXT EXERCISE -> ] > ───────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isResting ? const Color(0xFFE65100) : const Color(0xFF005953),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                    shadowColor: (_isResting ? const Color(0xFFE65100) : const Color(0xFF005953))
                        .withValues(alpha: 0.3),
                  ),
                  onPressed: _isResting ? _skipRest : _nextExercise,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isResting
                            ? (_isTransitionToNextExercise && nextExercise != null
                                ? '[ SKIP REST & START ${nextExercise.name.toUpperCase()} → ]'
                                : '[ SKIP REST & START SET ${_currentSet + 1} → ]')
                            : '[ NEXT EXERCISE → ]',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── ROW: [ || Pause ] and [ Start / Resume ] ────────────────
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        onPressed: _pauseTimer,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.pause_rounded, size: 18, color: AppColors.textPrimary),
                            const SizedBox(width: 6),
                            Text(
                              '[ || Pause ]',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF005953), width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _resumeTimer,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.play_arrow_rounded, size: 20, color: Color(0xFF005953)),
                            const SizedBox(width: 4),
                            Text(
                              '[ Start / Resume ]',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF005953),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Footer Note
              Center(
                child: Text(
                  'Target zone optimized for one-handed operation • Tap response < 50ms',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionDrawer(BuildContext context) {
    final exercises = widget.workout.exercises;
    final progressPercent = exercises.isNotEmpty
        ? (((_currentExerciseIndex + 1) / exercises.length) * 100).toInt()
        : 0;

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.featureTealBg,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          'ACTIVE SESSION',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryTeal,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondary),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.workout.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.workout.category} • ${widget.workout.difficulty} • ~${widget.workout.calories} kcal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: exercises.isNotEmpty ? (_currentExerciseIndex + 1) / exercises.length : 0.0,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Exercise ${_currentExerciseIndex + 1} of ${exercises.length}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '$progressPercent%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Controls Row (Pause / Resume)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: BorderSide(
                          color: _isRunning ? const Color(0xFFCBD5E1) : AppColors.primaryTeal,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        backgroundColor: _isRunning ? Colors.white : AppColors.featureTealBg,
                      ),
                      icon: Icon(
                        _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size: 18,
                        color: _isRunning ? AppColors.textPrimary : AppColors.primaryTeal,
                      ),
                      label: Text(
                        _isRunning ? 'Pause Timer' : 'Resume Timer',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _isRunning ? AppColors.textPrimary : AppColors.primaryTeal,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          if (_isRunning) {
                            _pauseTimer();
                          } else {
                            _resumeTimer();
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Checklist Section Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'CIRCUIT MOVEMENTS (${exercises.length})',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                  letterSpacing: 1.0,
                ),
              ),
            ),

            // Exercises Flow List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: exercises.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, idx) {
                  final ex = exercises[idx];
                  final isCurrent = idx == _currentExerciseIndex;
                  final isDone = idx < _currentExerciseIndex;

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.of(context).pop();
                      _jumpToExercise(idx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(0xFFF0FDF4)
                            : isDone
                                ? const Color(0xFFF8FAFC)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrent
                              ? const Color(0xFF86EFAC)
                              : isDone
                                  ? const Color(0xFFE2E8F0)
                                  : const Color(0xFFF1F5F9),
                          width: isCurrent ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Status Icon / Number
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? AppColors.primaryTeal
                                  : isDone
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFE2E8F0),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isDone
                                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                                  : isCurrent
                                      ? const Icon(Icons.fitness_center_rounded, color: Colors.white, size: 14)
                                      : Text(
                                          '${idx + 1}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ex.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                                    color: isCurrent
                                        ? AppColors.textPrimary
                                        : isDone
                                            ? AppColors.textSecondary
                                            : AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  ex.badge,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: isCurrent ? AppColors.primaryTeal : AppColors.textMuted,
                                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'ACTIVE',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF16A34A),
                                ),
                              ),
                            )
                          else if (isDone)
                            Text(
                              'Done',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Quit / End Session Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
              ),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Color(0xFFFEE2E2)),
                    ),
                    backgroundColor: const Color(0xFFFEF2F2),
                  ),
                  icon: const Icon(Icons.exit_to_app_rounded, size: 18),
                  label: Text(
                    'Quit Workout Session',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _confirmEndSession();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
