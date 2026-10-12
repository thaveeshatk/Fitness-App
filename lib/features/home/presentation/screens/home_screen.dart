import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/fiton_logo.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/data/models/auth_user.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../profile/data/models/profile_model.dart';
import '../../../profile/data/services/profile_service.dart';
import '../../../progress/data/services/user_activity_service.dart';
import '../../../workouts/data/models/workout_model.dart';
import '../../../workouts/data/repositories/workout_repository.dart';
import '../../../workouts/data/services/workout_service.dart';
import '../../../workouts/presentation/screens/workout_detail_screen.dart';
import '../../../workouts/presentation/screens/activity_screen.dart';

import '../../data/services/recommendation_service.dart';
import 'package:fitness_app/features/profile/presentation/widgets/profile_photo_picker_dialog.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../../profile/presentation/screens/main_navigation_screen.dart';

/// Screen: Home Dashboard
/// Real dynamic, personalized data for each logged-in user using Firebase
/// Authentication and Cloud Firestore:
/// - Brand Header: "F." logo + "Home" + Notification bell + User avatar
/// - Greeting Header: personalized name + daily momentum message
/// - "YOUR WORKOUT TODAY" hero card with personalized recommended workout
/// - "THIS WEEK'S PROGRESS" with real user workout activity, active minutes, and streak
/// - "QUICK WORKOUTS" suitable bite-sized workouts based on user preferences
/// - "RECOMMENDED FOR YOU" tailored recommendation based on profile and activity
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
  String _recommendedReason = 'Based on activity';
  List<QuickWorkoutItem> _quickWorkouts = [];

  Map<String, dynamic> _progress = {
    'completed': 0,
    'total': 3,
    'activeMinutes': 0,
    'streak': 0,
    'fraction': 0.0,
    'percent': 0,
    'hasActivity': false,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    AuthService.userNotifier.addListener(_onAuthUserChanged);
    ProfileService.profileNotifier.addListener(_onProfileChanged);
    MainNavigationScreen.activeTabNotifier.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    AuthService.userNotifier.removeListener(_onAuthUserChanged);
    ProfileService.profileNotifier.removeListener(_onProfileChanged);
    MainNavigationScreen.activeTabNotifier.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onAuthUserChanged() {
    if (mounted) {
      _loadDashboardData();
    }
  }

  void _onProfileChanged() {
    if (mounted) {
      _loadDashboardData();
    }
  }

  void _onTabChanged() {
    if (mounted && MainNavigationScreen.activeTabNotifier.value == 0) {
      _loadDashboardData();
    }
  }

  Future<void> _loadDashboardData() async {
    final currentUid = AuthService.currentUser.uid;

    try {
      // 1. Fetch user's profile from Firestore
      final profile = await ProfileService.getProfile(docId: currentUid, forceRefresh: true);

      // 2. Fetch all available workouts (including custom workouts created by this user)
      _workouts = await WorkoutService.getAllWorkouts();

      // 3. Fetch user's real workout activity & progress from Firestore
      final progressData = await UserActivityService.getWeeklyProgress(uid: currentUid);
      final recentHistory = await UserActivityService.getRecentActivities(uid: currentUid);



      // 5. Personalize recommendations
      _todaysWorkout = RecommendationService.getTodaysRecommendedWorkout(
        profile: profile,
        allWorkouts: _workouts,
        recentHistory: recentHistory,
      );

      final rec = RecommendationService.getRecommendedForYou(
        profile: profile,
        allWorkouts: _workouts,
        todaysWorkout: _todaysWorkout!,
        recentHistory: recentHistory,
      );
      _recommendedWorkout = rec.workout;
      _recommendedReason = rec.reason;

      _quickWorkouts = RecommendationService.getQuickWorkouts(
        profile: profile,
        allWorkouts: _workouts,
      );

      _progress = progressData;
    } catch (e) {
      _workouts = WorkoutRepository.getMockWorkouts();
      _todaysWorkout = _workouts.first;
      _recommendedWorkout = _workouts.length > 2 ? _workouts[2] : _workouts.first;
      _quickWorkouts = RecommendationService.getQuickWorkouts(
        profile: ProfileModel.initial(),
        allWorkouts: _workouts,
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _openWorkout(WorkoutModel workout) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutDetailScreen(workout: workout),
      ),
    ).then((_) {
      _loadDashboardData();
    });
  }

  void _startWorkoutDirectly(WorkoutModel workout) {
    // Open the selected individual workout (1 individual exercise, not a multi-exercise set)
    final individualWorkout = workout.exercises.length > 1
        ? workout.copyWith(
            exercises: [
              workout.exercises.firstWhere(
                (e) => !e.phase.toLowerCase().contains('prep'),
                orElse: () => workout.exercises.first,
              ),
            ],
            durationMinutes: (workout.durationMinutes / workout.exercises.length).ceil().clamp(5, 15),
            calories: (workout.calories / workout.exercises.length).round().clamp(40, 100),
          )
        : workout;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActivityScreen(workout: individualWorkout),
      ),
    ).then((_) {
      _loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryTeal),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primaryTeal,
          onRefresh: _loadDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        const Spacer(),
        const NotificationBell(
          size: 38,
          iconSize: 26,
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
                      color: AppColors.textPrimary,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ready to build your daily momentum?',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
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

  /// Human-readable equipment summary for a workout, e.g. "No Equipment" or
  /// "Dumbbells  •  Resistance Bands".
  String _equipmentLabel(WorkoutModel w) {
    final isBodyweight = w.equipment.isEmpty ||
        w.equipment.every(
          (e) => e.toLowerCase().contains('none') || e.toLowerCase().contains('bodyweight'),
        );
    return isBodyweight ? 'No Equipment' : w.equipment.join('  •  ');
  }

  Widget _buildYourWorkoutTodaySection() {
    final workout = _todaysWorkout ?? (_workouts.isNotEmpty ? _workouts.first : WorkoutRepository.getMockWorkouts().first);


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

                  // Calories Badge
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
                          '${workout.calories} kcal',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                      ],
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
                          '${_equipmentLabel(workout)}  •  Self-Paced',
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

              // Workout Title
              Text(
                workout.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 4),

              // Subtitle: "<Category> • ⏱ <duration> min • <Difficulty>"
              Row(
                children: [
                  Text(
                    workout.category,
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
                    '${workout.durationMinutes} min',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const Text('  •  ', style: TextStyle(color: Color(0xFF94A3B8))),
                  Text(
                    workout.difficulty,
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
    final completed = (_progress['completed'] as int?) ?? 0;
    final total = (_progress['total'] as int?) ?? 3;
    final activeMinutes = (_progress['activeMinutes'] as int?) ?? 0;
    final streak = (_progress['streak'] as int?) ?? 0;
    final fraction = ((_progress['fraction'] as num?)?.toDouble() ?? 0.0);
    final percent = (_progress['percent'] as int?) ?? 0;
    final completedText = '$completed/$total';
    final percentText = '$percent% Complete';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => widget.onNavigateToTab?.call(3),
              child: Row(
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
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF475569)),
                ],
              ),
            ),
            Text(
              'Goal: $total days',
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
        GestureDetector(
          onTap: () => widget.onNavigateToTab?.call(3),
          child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: ThemeController.instance.isDarkMode ? 0.2 : 0.04),
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
                  // Stat 1: Completed
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: ThemeController.instance.isDarkMode ? AppColors.surfaceMuted : const Color(0xFFEEF5FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Text(
                            completedText,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Completed',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Stat 2: Active Time
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: ThemeController.instance.isDarkMode ? AppColors.surfaceMuted : const Color(0xFFEEF5FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${activeMinutes}m',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Active Time',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Stat 3: Day Streak
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: ThemeController.instance.isDarkMode ? const Color(0xFF2E1010) : const Color(0xFFFEEFEF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$streak',
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

              // Weekly target & percent complete Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weekly target',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    percentText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: ThemeController.instance.isDarkMode ? AppColors.primaryLight : const Color(0xFF006257),
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
                    backgroundColor: ThemeController.instance.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(ThemeController.instance.isDarkMode ? AppColors.primaryLight : const Color(0xFF006257)),
                  ),
                ),
              ),

              // Empty state banner or encouraging progress message
              const SizedBox(height: 12),
              if (completed == 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: ThemeController.instance.isDarkMode ? AppColors.surfaceMuted : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: ThemeController.instance.isDarkMode ? AppColors.primaryLight : const Color(0xFF006257)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No workouts logged yet this week. Complete today\'s workout to start your streak!',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  completed >= total
                      ? '🎉 Fantastic! You hit your weekly goal!'
                      : '${total - completed} session${(total - completed) > 1 ? 's' : ''} to reach your weekly goal.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF006257),
                  ),
                ),
            ],
          ),
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
        if (_quickWorkouts.isNotEmpty)
          Row(
            children: _quickWorkouts.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: idx < _quickWorkouts.length - 1 ? 10.0 : 0.0,
                  ),
                  child: InkWell(
                    onTap: () => _openWorkout(item.workout),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 128,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: ThemeController.instance.isDarkMode ? 0.15 : 0.03),
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
                              color: item.iconBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(item.icon, color: item.iconColor, size: 20),
                          ),
                          // Title & Duration
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.access_time_rounded, size: 12, color: AppColors.textSecondary),
                                  const SizedBox(width: 3),
                                  Text(
                                    item.duration,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // ── 6. Section: "RECOMMENDED FOR YOU" ───────────────────────────────────────

  Widget _buildRecommendedForYouSection() {
    final workout = _recommendedWorkout ?? (_workouts.isNotEmpty ? _workouts.first : WorkoutRepository.getMockWorkouts().first);

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
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              _recommendedReason,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: ThemeController.instance.isDarkMode ? AppColors.primaryLight : const Color(0xFF006257),
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
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: ThemeController.instance.isDarkMode ? 0.2 : 0.04),
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
                    workout.imageUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 72,
                      height: 72,
                      color: AppColors.surfaceMuted,
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
                              color: ThemeController.instance.isDarkMode ? AppColors.surfaceMuted : const Color(0xFFF5EBE1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              workout.difficulty,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: ThemeController.instance.isDarkMode ? AppColors.textPrimary : const Color(0xFF57534E),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${workout.durationMinutes} min',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      // Title
                      Text(
                        workout.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),

                      const SizedBox(height: 3),

                      // Subtitle: "<Category> • <Equipment>"
                      Text(
                        '${workout.category} • ${_equipmentLabel(workout)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
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
