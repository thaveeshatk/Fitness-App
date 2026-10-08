import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/features/profile/data/services/profile_service.dart';
import 'package:fitness_app/features/profile/presentation/screens/profile_preferences_screen.dart';
import 'package:fitness_app/features/workouts/presentation/screens/workout_detail_screen.dart';
import 'package:fitness_app/features/plan/data/models/plan_schedule_item.dart';
import 'package:fitness_app/features/plan/data/services/plan_service.dart';
import 'package:fitness_app/features/plan/presentation/widgets/my_plan_header.dart';
import 'package:fitness_app/features/plan/presentation/widgets/plan_hero_progress_card.dart';
import 'package:fitness_app/features/plan/presentation/widgets/plan_schedule_card.dart';
import 'package:fitness_app/features/plan/presentation/screens/weekly_schedule_screen.dart';
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
    _loadPlan();
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

  void _onOpenWorkout(PlanScheduleItem item) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => WorkoutDetailScreen(workout: item.workout),
      ),
    )
        .then((_) {
      // Reload on return to catch potential progress changes
      _loadPlan();
    });
  }

  void _onContinuePlan() {
    // Find today's active workout or first pending workout
    final activeItem = _planItems.firstWhere(
      (it) => it.isTodayReady,
      orElse: () => _planItems.firstWhere(
        (it) => !it.isCompleted,
        orElse: () => _planItems.first,
      ),
    );
    _onOpenWorkout(activeItem);
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
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF005953),
          ),
        ),
      );
    }

    final metrics = PlanService.calculateMetrics(_planItems);
    final completedCount = metrics['completed'] as int;
    final totalCount = metrics['total'] as int;

    // Filter display items (matches wireframe: Monday 13, Wednesday 15, Friday 17, Sunday 19)
    final visibleSchedule = _planItems.where((it) => it.dayLabel != 'TUE').toList();

    return Scaffold(
      backgroundColor: Colors.white,
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
                      motivationalSubtitle: "You're on track! Keep up the great work.",
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
                            // Date Range Pill Badge: "Nov 13 – 19"
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2EBF5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Nov 13 – 19',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Active Days count linked to profile
                        Text(
                          '$totalCount Days Active',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
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
                        onPlayTap: _onContinuePlan,
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
                          backgroundColor: const Color(0xFFF1EFEA),
                          foregroundColor: const Color(0xFF1E293B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: _onViewWeeklySchedule,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 17,
                              color: Color(0xFF1E293B),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'View Weekly Schedule',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E293B),
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
