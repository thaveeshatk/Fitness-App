import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/features/profile/data/services/profile_service.dart';
import 'package:fitness_app/features/profile/presentation/screens/main_navigation_screen.dart';
import 'package:fitness_app/features/profile/presentation/screens/profile_preferences_screen.dart';
import 'package:fitness_app/features/workouts/presentation/screens/workout_detail_screen.dart';
import 'package:fitness_app/features/workouts/presentation/screens/activity_screen.dart';
import 'package:fitness_app/features/plan/data/models/plan_schedule_item.dart';
import 'package:fitness_app/features/plan/data/services/plan_service.dart';
import 'package:fitness_app/features/plan/presentation/widgets/my_plan_header.dart';
import 'package:fitness_app/features/plan/presentation/widgets/plan_hero_progress_card.dart';
import 'package:fitness_app/features/plan/presentation/widgets/plan_schedule_card.dart';
import 'package:fitness_app/features/plan/presentation/screens/weekly_schedule_screen.dart';
import 'package:fitness_app/core/theme/theme_controller.dart';

/// Screen 3: "My Plan"
/// Faithfully converts the provided wireframe into a rich, connected Flutter screen:
/// - Brand header with FitOn logo badge ("F."), "My Plan" title, notification bell, and user avatar
/// - "YOUR WEEKLY PLAN" hero card with 60% progress, 3 of 5 completed, 2 sessions to go
/// - "Weekly Schedule" section header with "Nov 13 – 19" pill badge and "5 Days Active"
/// - Dynamic schedule cards connected directly to [WorkoutDetailScreen] and [ProfileService]
/// - Pinned / floating CTA buttons: "Continue Plan" and "View Weekly Schedule"
class MyPlanScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const MyPlanScreen({
    super.key,
    this.onNavigateToTab,
  });

  @override
  State<MyPlanScreen> createState() => _MyPlanScreenState();
}

class _MyPlanScreenState extends State<MyPlanScreen> {
  List<PlanScheduleItem> _planItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    ProfileService.profileNotifier.addListener(_onProfileOrTabChanged);
    MainNavigationScreen.activeTabNotifier.addListener(_onProfileOrTabChanged);
    _loadPlan();
  }

  @override
  void dispose() {
    ProfileService.profileNotifier.removeListener(_onProfileOrTabChanged);
    MainNavigationScreen.activeTabNotifier.removeListener(_onProfileOrTabChanged);
    super.dispose();
  }

  void _onProfileOrTabChanged() {
    PlanService.clearCache();
    if (mounted) {
      _loadPlan(forceRefresh: true);
    }
  }

  Future<void> _loadPlan({bool forceRefresh = false}) async {
    try {
      final items = await PlanService.getWeeklyPlan(forceRefresh: forceRefresh);
      if (mounted) {
        setState(() {
          _planItems = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showLockedNotice(PlanScheduleItem item) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF1E293B),
        content: Row(
          children: [
            const Icon(Icons.lock_rounded, color: Color(0xFFFBBF24), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Scheduled for ${item.dayLabel} (${item.dayNumber}). You can only start workouts on their scheduled days.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _onOpenWorkout(PlanScheduleItem item) {
    final nowWeekday = DateTime.now().weekday;
    final isAssignedToday = item.assignedWeekday == nowWeekday;

    // Users must only be able to start workouts on their scheduled days
    if (!item.isCompleted && !isAssignedToday) {
      _showLockedNotice(item);
      return;
    }

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => WorkoutDetailScreen(
          workout: item.workout,
          planItemId: item.id,
        ),
      ),
    )
        .then((_) {
      // Reload on return to catch potential progress changes
      _loadPlan(forceRefresh: true);
    });
  }

  void _startWorkoutDirectly(PlanScheduleItem item) {
    final nowWeekday = DateTime.now().weekday;
    final isAssignedToday = item.assignedWeekday == nowWeekday;

    // Users must only be able to start workouts on their scheduled days
    if (!item.isCompleted && !isAssignedToday) {
      _showLockedNotice(item);
      return;
    }

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => ActivityScreen(
          workout: item.workout,
          planItemId: item.id,
        ),
      ),
    )
        .then((_) {
      _loadPlan(forceRefresh: true);
    });
  }

  void _onContinuePlan() {
    final nowWeekday = DateTime.now().weekday;

    // Find today's ready workout
    final todayItem = _planItems.where((it) => it.assignedWeekday == nowWeekday && !it.isCompleted).firstOrNull;
    if (todayItem != null) {
      _startWorkoutDirectly(todayItem);
      return;
    }

    // Check if today's workout was already finished
    final todayCompleted = _planItems.any((it) => it.assignedWeekday == nowWeekday && it.isCompleted);
    if (todayCompleted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: const Color(0xFF005953),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF00D18D), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "You've already completed today's scheduled workout! Great job.",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Otherwise today is a rest day
    final nextItem = _planItems.where((it) => it.assignedWeekday > nowWeekday && !it.isCompleted).firstOrNull ??
        _planItems.where((it) => !it.isCompleted).firstOrNull;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF1E293B),
        content: Row(
          children: [
            const Icon(Icons.nightlight_round, color: Color(0xFF60A5FA), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                nextItem != null
                    ? "Today is a rest day! Your next scheduled session is on ${nextItem.dayLabel}."
                    : "All scheduled workouts for this week are completed! Great dedication!",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _onViewWeeklySchedule() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const WeeklyScheduleScreen(),
      ),
    );
  }

  void _onProfileTap() {
    if (widget.onNavigateToTab != null) {
      // Switch to Profile tab (Index 4) in the persistent bottom bar
      widget.onNavigateToTab!(4);
    } else {
      // Fallback: push Profile Preferences screen directly
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProfilePreferencesScreen(
            onBack: () {
              Navigator.of(context).pop();
              _loadPlan(forceRefresh: true);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF005953),
          ),
        ),
      );
    }

    final isDark = ThemeController.instance.isDarkMode;
    final metrics = PlanService.calculateMetrics(_planItems);
    final completedCount = metrics['completed'] as int;
    final totalCount = metrics['total'] as int;

    // Display workouts strictly for the user's selected routine days
    final visibleSchedule = _planItems;
    final dateRangeLabel = _planItems.isNotEmpty ? _planItems.first.dateRangeLabel : 'Current Week';
    final activeDaysLabel = completedCount > 0
        ? '$completedCount of $totalCount Days Active'
        : '$totalCount Days Active';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar Header
            MyPlanHeader(
              onProfileTap: _onProfileTap,
            ),

            // Main Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Progress Card: "YOUR WEEKLY PLAN"
                    PlanHeroProgressCard(
                      completedSessions: completedCount,
                      totalSessions: totalCount,
                      motivationalSubtitle: completedCount == totalCount && totalCount > 0
                          ? "All done! Amazing dedication this week!"
                          : "You're on track! Keep up the great work.",
                    ),

                    const SizedBox(height: 24),

                    // Section Title: "Weekly Schedule"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Weekly Schedule',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Date Range Pill Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE2EBF5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                dateRangeLabel,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Active Days count linked to user profile and completed activity
                        Text(
                          activeDaysLabel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // List of Schedule Workout Cards
                    ...visibleSchedule.map((item) {
                      return PlanScheduleCard(
                        item: item,
                        onTap: () => _onOpenWorkout(item),
                        onPlayTap: () => _startWorkoutDirectly(item),
                      );
                    }),

                    const SizedBox(height: 14),

                    // Primary Action Button: "Continue Plan"
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005953),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: const Color(0xFF005953).withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        onPressed: _onContinuePlan,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.play_circle_filled_rounded,
                              size: 22,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Continue Plan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Secondary Action Button: "View Weekly Schedule"
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: isDark ? AppColors.cardBackground : const Color(0xFFF1EFEA),
                          foregroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: BorderSide(
                              color: isDark ? AppColors.border : Colors.transparent,
                            ),
                          ),
                        ),
                        onPressed: _onViewWeeklySchedule,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 17,
                              color: AppColors.textPrimary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'View Weekly Schedule',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
