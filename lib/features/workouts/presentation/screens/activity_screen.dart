import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/workout_model.dart';
import 'exercise_guidance_screen.dart';
import 'workout_complete_screen.dart';

class ActivityScreen extends StatefulWidget {
  final WorkoutModel workout;

  const ActivityScreen({super.key, required this.workout});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  int _totalSets = 3;

  int _intervalSecondsRemaining = 60;
  int _totalIntervalSeconds = 60;
  int _elapsedSeconds = 0; // Starts fresh at 00:00
  bool _isRunning = true;
  bool _isResting = false;
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
    final badge = exercise.badge.toLowerCase();

    // Check for exact seconds (e.g., '45 sec', '30 sec', '20 sec')
    final secRegex = RegExp(r'(\d+)\s*(sec|s\b)');
    final secMatch = secRegex.firstMatch(badge);
    if (secMatch != null) {
      final val = int.tryParse(secMatch.group(1) ?? '');
      if (val != null && val > 0) return val;
    }

    // Check for exact minutes (e.g., '3 min', '5 min', '2 min')
    final minRegex = RegExp(r'(\d+)\s*(min|m\b)');
    final minMatch = minRegex.firstMatch(badge);
    if (minMatch != null) {
      final val = int.tryParse(minMatch.group(1) ?? '');
      if (val != null && val > 0) return val * 60;
    }

    // Default for rep-based movements (e.g., '3 sets × 12 reps') -> standard 60-second set
    return 60;
  }

  int _calculateTotalSets(ExerciseItem exercise) {
    final badge = exercise.badge.toLowerCase();
    final setsRegex = RegExp(r'(\d+)\s*(sets|rounds|cycles)');
    final setsMatch = setsRegex.firstMatch(badge);
    if (setsMatch != null) {
      final val = int.tryParse(setsMatch.group(1) ?? '');
      if (val != null && val > 0) return val;
    }
    // Single continuous duration (e.g., '3 min' or '5 min')
    if (badge.contains('min')) return 1;
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
          // If in Active Interval and sets remain:
          if (!_isResting) {
            if (_currentSet < _totalSets) {
              // Transition into REST INTERVAL
              _isResting = true;
              _totalIntervalSeconds = _restDurationSeconds;
              _intervalSecondsRemaining = _totalIntervalSeconds;
            } else {
              // All sets finished for this exercise
              _intervalSecondsRemaining = 0;
            }
          } else {
            // Rest interval finished -> transition back to ACTIVE INTERVAL for next set
            _isResting = false;
            _currentSet++;
            final currentEx = widget.workout.exercises[_currentExerciseIndex];
            _totalIntervalSeconds = _calculateExerciseInterval(currentEx);
            _intervalSecondsRemaining = _totalIntervalSeconds;
          }
        }
      });
    });
  }

  void _skipRest() {
    setState(() {
      _isResting = false;
      _currentSet++;
      final currentEx = widget.workout.exercises[_currentExerciseIndex];
      _totalIntervalSeconds = _calculateExerciseInterval(currentEx);
      _intervalSecondsRemaining = _totalIntervalSeconds;
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
              'You successfully completed all 6 exercises in "${widget.workout.title}".',
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
                  'Finish & Return',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary, size: 24),
          onPressed: () {},
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
              onTap: () {
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
              },
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
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 17,
              backgroundImage: NetworkImage(widget.workout.coachAvatar),
              backgroundColor: AppColors.surfaceMuted,
            ),
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
                              color: const Color(0xFF005953),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'SET $_currentSet OF $_totalSets',
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
                            'Target rest: 60s',
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.info_outline, size: 15, color: Color(0xFF005953)),
                              const SizedBox(width: 6),
                              Text(
                                '[ HOW TO PERFORM → ]',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
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
                              _isResting ? 'REST INTERVAL' : 'INTERVAL',
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
                              _isResting ? 'REST INTERVAL' : 'ACTIVE INTERVAL',
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
                            ? '[ SKIP REST & START SET $_currentSet → ]'
                            : '[ NEXT EXERCISE → ]',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
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
}
