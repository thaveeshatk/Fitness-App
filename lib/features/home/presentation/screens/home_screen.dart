import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/fiton_logo.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/data/models/auth_user.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../workouts/data/models/workout_model.dart';
import '../../../workouts/data/repositories/workout_repository.dart';
import '../../../workouts/presentation/screens/workout_detail_screen.dart';
import '../../../workouts/presentation/screens/activity_screen.dart';
import '../../../plan/data/services/plan_service.dart';
import '../../../plan/data/models/plan_schedule_item.dart';
import 'package:fitness_app/features/profile/presentation/widgets/profile_photo_picker_dialog.dart';

/// Screen: Home Dashboard
/// Faithfully reproduces the provided wireframe pixel-for-pixel:
/// - Brand Header: "F." logo + "Home" + Notification bell + User avatar
/// - Greeting Header: "Good morning, Alex!" + "Ready to build your daily momentum?"
/// - "YOUR WORKOUT TODAY" hero card with Ready, 145 kcal, Day 3 of 5, thumbnail, and "Start Workout"
/// - "THIS WEEK'S PROGRESS" with 3 stat cards (3/5 Completed, 60m Active Time, 2 Day Streak) and 60% progress bar
/// - "QUICK WORKOUTS" bite-sized cards (10 Min Full Body, 15 Min Cardio, 10 Min Stretch)
/// - "RECOMMENDED FOR YOU" card (Core Starter Routine, Beginner • 15 min, Gentle Core • No Equipment)
class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<WorkoutModel> _workouts;
  WorkoutModel? _todaysWorkout;
  WorkoutModel? _recommendedWorkout;
  List<PlanScheduleItem> _planItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    _workouts = WorkoutRepository.getMockWorkouts();

    // Find full body beginner or matching workout
    _todaysWorkout = _workouts.firstWhere(
      (w) => w.title.toLowerCase().contains('full body') || w.difficulty == 'Beginner',
      orElse: () => _workouts.first,
    );

    // Find core or recommended workout
    _recommendedWorkout = _workouts.firstWhere(
      (w) => w.title.toLowerCase().contains('core') || w.category == 'Mobility',
      orElse: () => _workouts.length > 2 ? _workouts[2] : _workouts.first,
    );

    try {
      _planItems = await PlanService.getWeeklyPlan();
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _openWorkout(WorkoutModel workout) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutDetailScreen(workout: workout),
      ),
    );
  }

  void _startWorkoutDirectly(WorkoutModel workout) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActivityScreen(workout: workout),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFBFDFF),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryTeal),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFF),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top App Bar Header
              _buildTopHeader(),

              const SizedBox(height: 20),

              // 2. Greeting Row
              _buildGreetingRow(),

              const SizedBox(height: 24),

              // 3. Section: "YOUR WORKOUT TODAY"
              _buildYourWorkoutTodaySection(),

              const SizedBox(height: 28),

              // 4. Section: "THIS WEEK'S PROGRESS"
              _buildThisWeeksProgressSection(),

              const SizedBox(height: 28),

              // 5. Section: "QUICK WORKOUTS"
              _buildQuickWorkoutsSection(),

              const SizedBox(height: 28),

              // 6. Section: "RECOMMENDED FOR YOU"
              _buildRecommendedForYouSection(),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  // ── 1. Top Header Bar ──────────────────────────────────────────────────────

  Widget _buildTopHeader() {
    return Row(
      children: [
        // App Icon "F."
        const FitOnLogoBadge(
          size: 36,
          borderRadius: 10,
          showAccentMark: false,
        ),
        const SizedBox(width: 12),
        // Title "Home"
        Text(
          'Home',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.4,
          ),
        ),
        const Spacer(),
        // Notification bell with red dot
        InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'No new notifications. You are on track for today! 🎯',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
                ),
                backgroundColor: AppColors.primaryTeal,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Padding(
                padding: EdgeInsets.all(6.0),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF334155),
                  size: 26,
                ),
              ),
              Positioned(
                top: 6,
                right: 7,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF3B30),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // User profile avatar
        UserAvatar(
          radius: 19,
          onTap: () {
            if (widget.onNavigateToTab != null) {
              widget.onNavigateToTab!(4); // Profile tab
            } else {
              ProfilePhotoPickerDialog.show(context);
            }
          },
        ),
      ],
    );
  }

  // ── 2. Greeting Row ────────────────────────────────────────────────────────

  Widget _buildGreetingRow() {
    return ValueListenableBuilder<AuthUser?>(
      valueListenable: AuthService.userNotifier,
      builder: (context, user, _) {
        final displayName = (user?.name != null && user!.name.isNotEmpty) ? user.name : 'Alex';

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good morning, $displayName!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ready to build your daily momentum?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ── 3. Section: "YOUR WORKOUT TODAY" ───────────────────────────────────────

  Widget _buildYourWorkoutTodaySection() {
    final workout = _todaysWorkout ?? _workouts.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'YOUR WORKOUT TODAY',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
                letterSpacing: 0.8,
              ),
            ),
            Row(
              children: [
                const Icon(
                  Icons.electric_bolt_rounded,
                  size: 15,
                  color: Color(0xFFDC2626),
                ),
                const SizedBox(width: 4),
                Text(
                  'Recommended',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Hero Workout Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE8FAF6),
                Color(0xFFF3FCFA),
                Colors.white,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFC8F3EA), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF006257).withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Meta Row: [ Ready ]  [ 145 kcal ]  Day 3 of 5
              Row(
                children: [
                  // Ready Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006257),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Ready',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 145 kcal Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department_rounded, color: Color(0xFFDC2626), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '145 kcal',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Day 3 of 5
                  Text(
                    'Day 3 of 5',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Workout Video / Thumbnail Banner
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/hero_workout.jpg',
                      height: 145,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.network(
                        workout.imageUrl,
                        height: 145,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Dark soft bottom gradient
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.45),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Floating Badge: "No Equipment • Self-Paced"
                    Positioned(
                      left: 12,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          'No Equipment  •  Self-Paced',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Workout Title: "Full Body Beginner"
              Text(
                'Full Body Beginner',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 4),

              // Subtitle: "Strength • ⏱ 20 min • Gentle Intro"
              Row(
                children: [
                  Text(
                    'Strength',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const Text('  •  ', style: TextStyle(color: Color(0xFF94A3B8))),
                  const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    '20 min',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const Text('  •  ', style: TextStyle(color: Color(0xFF94A3B8))),
                  Text(
                    'Gentle Intro',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF006257),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Action Button: "▶  Start Workout"
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005953),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    elevation: 3,
                    shadowColor: const Color(0xFF005953).withValues(alpha: 0.35),
                  ),
                  onPressed: () => _startWorkoutDirectly(workout),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'Start Workout',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 4. Section: "THIS WEEK'S PROGRESS" ──────────────────────────────────────

  Widget _buildThisWeeksProgressSection() {
    final metrics = _planItems.isNotEmpty
        ? PlanService.calculateMetrics(_planItems)
        : {'completed': 3, 'total': 5, 'percent': 60, 'fraction': 0.60};
    final completedText = '${metrics['completed']}/${metrics['total']}';
    final percentText = '${metrics['percent']}% Complete';
    final fraction = (metrics['fraction'] as num).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "THIS WEEK'S PROGRESS",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
                letterSpacing: 0.8,
              ),
            ),
            Text(
              'Goal: 5 days',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Progress Card Container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 3 Stat Cards Row
              Row(
                children: [
                  // Stat 1: 3/5 Completed
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF5FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Text(
                            completedText,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Completed',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Stat 2: 60m Active Time
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF5FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '60m',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Active Time',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Stat 3: 2 Day Streak
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEEFEF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '2',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFDC2626),
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.local_fire_department_rounded,
                                color: Color(0xFFDC2626),
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Day Streak',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Weekly target & 60% Complete Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weekly target',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  Text(
                    percentText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF006257),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 7,
                  child: LinearProgressIndicator(
                    value: fraction,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF006257)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 5. Section: "QUICK WORKOUTS" ───────────────────────────────────────────

  Widget _buildQuickWorkoutsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'QUICK WORKOUTS',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
                letterSpacing: 0.8,
              ),
            ),
            Text(
              'Bite-sized',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFDC2626),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 3 Horizontal Cards Row
        Row(
          children: [
            // Card 1: 10 Min Full Body
            Expanded(
              child: _buildQuickWorkoutCard(
                title: '10 Min Full\nBody',
                duration: '10 min',
                icon: Icons.accessibility_new_rounded,
                iconBg: const Color(0xFFF1F5F9),
                iconColor: const Color(0xFF64748B),
                workoutKeyword: 'Full Body',
              ),
            ),

            const SizedBox(width: 10),

            // Card 2: 15 Min Cardio
            Expanded(
              child: _buildQuickWorkoutCard(
                title: '15 Min\nCardio',
                duration: '15 min',
                icon: Icons.directions_run_rounded,
                iconBg: const Color(0xFFFEE2E2),
                iconColor: const Color(0xFFDC2626),
                workoutKeyword: 'Cardio',
              ),
            ),

            const SizedBox(width: 10),

            // Card 3: 10 Min Stretch
            Expanded(
              child: _buildQuickWorkoutCard(
                title: '10 Min\nStretch',
                duration: '10 min',
                icon: Icons.self_improvement_rounded,
                iconBg: const Color(0xFFCCFBF1),
                iconColor: const Color(0xFF0D9488),
                workoutKeyword: 'Mobility',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickWorkoutCard({
    required String title,
    required String duration,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String workoutKeyword,
  }) {
    return InkWell(
      onTap: () {
        final match = _workouts.firstWhere(
          (w) => w.title.toLowerCase().contains(workoutKeyword.toLowerCase()) ||
              w.category.toLowerCase().contains(workoutKeyword.toLowerCase()),
          orElse: () => _workouts.first,
        );
        _openWorkout(match);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 128,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Icon Box
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            // Title & Duration
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF64748B)),
                    const SizedBox(width: 3),
                    Text(
                      duration,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── 6. Section: "RECOMMENDED FOR YOU" ───────────────────────────────────────

  Widget _buildRecommendedForYouSection() {
    final workout = _recommendedWorkout ?? _workouts.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECOMMENDED FOR YOU',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
                letterSpacing: 0.8,
              ),
            ),
            Text(
              'Based on activity',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Recommendation Card
        InkWell(
          onTap: () => _openWorkout(workout),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Thumbnail on Left
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1545205597-3d9d02c29597?q=80&w=300&auto=format&fit=crop',
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 72,
                      height: 72,
                      color: const Color(0xFFF1F5F9),
                      child: const Icon(Icons.fitness_center_rounded, color: AppColors.primaryTeal),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Center Content: Badges + Title + Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge Row: "Beginner"  "15 min"
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5EBE1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Beginner',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF57534E),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '15 min',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      // Title: "Core Starter Routine"
                      Text(
                        'Core Starter Routine',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),

                      const SizedBox(height: 3),

                      // Subtitle: "Gentle Core • No Equipment"
                      Text(
                        'Gentle Core • No Equipment',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Forward button on right (chevron)
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF64748B),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
