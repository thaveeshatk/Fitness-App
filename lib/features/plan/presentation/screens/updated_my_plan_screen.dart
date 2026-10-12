import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitness_app/features/plan/data/services/plan_service.dart';
import 'package:fitness_app/features/plan/data/models/plan_schedule_item.dart';
import 'package:fitness_app/features/workouts/presentation/screens/workout_detail_screen.dart';
import 'package:fitness_app/features/notifications/presentation/widgets/notification_bell.dart';

class UpdatedMyPlanScreen extends StatefulWidget {
  const UpdatedMyPlanScreen({super.key});

  @override
  State<UpdatedMyPlanScreen> createState() => _UpdatedMyPlanScreenState();
}

class _UpdatedMyPlanScreenState extends State<UpdatedMyPlanScreen> {
  bool _isLoading = true;
  List<PlanScheduleItem> _planItems = [];
  Map<String, dynamic> _metrics = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final items = await PlanService.getWeeklyPlan(forceRefresh: true);
      if (mounted) {
        setState(() {
          _planItems = items;
          _metrics = PlanService.calculateMetrics(items);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
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
      _loadData();
    });
  }

  void _onContinuePlan() {
    if (_planItems.isEmpty) return;
    final activeItem = _planItems.firstWhere(
      (it) => it.isTodayReady,
      orElse: () => _planItems.firstWhere(
        (it) => !it.isCompleted,
        orElse: () => _planItems.first,
      ),
    );
    _onOpenWorkout(activeItem);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tealColor = isDark ? const Color(0xFF2DD4BF) : const Color(0xFF006257);
    final bgLightColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF9F9FC);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgLightColor,
        body: Center(child: CircularProgressIndicator(color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF006257))),
      );
    }

    // Prepare lists
    final completedItems = _planItems.where((it) => it.isCompleted).toList().reversed.toList();
    final upcomingItems = _planItems.where((it) => it.isUpcoming).toList();
    final todayItem = _planItems.firstWhere((it) => it.isTodayReady, orElse: () => _planItems.isNotEmpty ? _planItems.first : PlanScheduleItem(
      id: '', dayLabel: '', dayNumber: 0, dateRangeLabel: '', status: PlanItemStatus.upcoming, title: '', durationMinutes: 0, category: '', imageUrl: '', workout: _planItems.first.workout
    ));

    return Scaffold(
      backgroundColor: bgLightColor,
      appBar: AppBar(
        backgroundColor: bgLightColor,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2DD4BF) : tealColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.show_chart, color: isDark ? const Color(0xFF0F172A) : Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              'My Plan',
              style: GoogleFonts.plusJakartaSans(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          const NotificationBell(),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: isDark ? const Color(0xFF2DD4BF) : tealColor,
              child: Icon(Icons.person, color: isDark ? const Color(0xFF0F172A) : Colors.white, size: 18),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sub-header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(20),
                    border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569), size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Week 2 of 4 • Beginner\nFoundation',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4, right: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(30),
                    border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Hi, Alex\n👋',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: isDark ? const Color(0xFF2DD4BF) : tealColor,
                        child: Text(
                          'A',
                          style: GoogleFonts.plusJakartaSans(
                            color: isDark ? const Color(0xFF0F172A) : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Weekly Goal Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
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
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2DD4BF) : tealColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Weekly Goal',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF064E3B)
                              : const Color(0xFF86EFAC).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_metrics['completed'] ?? 0} of ${_metrics['total'] ?? 0} completed',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF065F46),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Progress Bar
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: _metrics['fraction'] ?? 0.0,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2DD4BF) : tealColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.arrow_back_ios, color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF006257), size: 10),
                      const SizedBox(width: 4),
                      Text(
                        "You're ${_metrics['remaining'] ?? 0} workouts away from your weekly goal!",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Days row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDayStatus('M', 'Done', Icons.check, true, false, false, false, isDark),
                      _buildDayStatus('T', 'Rest', Icons.access_alarm, false, false, true, false, isDark),
                      _buildDayStatus('W', 'Done', Icons.check, true, false, false, false, isDark),
                      _buildDayStatus('T', 'Missed', Icons.error_outline, false, true, false, false, isDark),
                      _buildDayStatus('F', 'TODAY', Icons.play_arrow, true, false, false, true, isDark),
                      _buildDayStatus('S', 'Plan', Icons.calendar_today, false, false, true, false, isDark),
                      _buildDayStatus('S', 'Rest', Icons.access_alarm, false, false, true, false, isDark),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Today's Workout Card
            if (todayItem.id.isNotEmpty) ...[
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF334155).withValues(alpha: 0.6),
                                  const Color(0xFF1E293B),
                                ]
                              : [
                                  const Color(0xFFFDE6D2).withValues(alpha: 0.5),
                                  const Color(0xFFD4F7F2).withValues(alpha: 0.5),
                                ],
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFFF87171) : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "TODAY'S WORKOUT • ${todayItem.dayLabel.toUpperCase()}",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? const Color(0xFFFCA5A5) : Colors.red.shade800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : Colors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
                            ),
                            child: Text(
                              'Not started',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      children: [
                        Image.network(
                          todayItem.imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildImageTag(Icons.access_time, '${todayItem.durationMinutes} min', isDark: isDark),
                              _buildImageTag(Icons.local_fire_department, todayItem.category, color: isDark ? const Color(0xFFF87171) : Colors.red.shade700, isDark: isDark),
                              if (todayItem.subtitleDetail != null)
                                _buildImageTag(Icons.fitness_center, todayItem.subtitleDetail!, isDark: isDark),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            todayItem.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            todayItem.adviceHighlight ?? 'Gentle joint-friendly circuits designed to build core stability, improve overall posture, and ignite stamina.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? const Color(0xFF2DD4BF) : tealColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () => _onOpenWorkout(todayItem),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.play_circle_fill, color: isDark ? const Color(0xFF0F172A) : Colors.white, size: 22),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Continue Workout',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
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
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Upcoming Workouts
            if (upcomingItems.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upcoming Workouts',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    'See full week >',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF2DD4BF) : tealColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...upcomingItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => _onOpenWorkout(item),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    item.dayLabel.toUpperCase(),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? const Color(0xFFFDBA74) : const Color(0xFFB45309),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF312E81) : const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Beginner',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4F46E5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.title,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 10, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${item.durationMinutes} min • ${item.category}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.event_available, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569), size: 20),
                          onPressed: () => _onOpenWorkout(item),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
              const SizedBox(height: 12),
            ],

            // Completed This Week
            if (completedItems.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Completed This Week',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    '${completedItems.length} sessions',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...completedItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCompletedCard(
                  item.dayLabel.toUpperCase(),
                  item.title,
                  '${item.durationMinutes} min • 130 kcal burned',
                  () => _onOpenWorkout(item),
                  isDark,
                ),
              )),
              const SizedBox(height: 20),
            ],

            // Continue Plan Bottom Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E7FF),
                  side: isDark ? const BorderSide(color: Color(0xFF334155)) : BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                onPressed: _onContinuePlan,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_circle_outline, color: isDark ? Colors.white : const Color(0xFF1E293B), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Continue Plan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Next suggested rest interval: Sunday',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Plan
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        selectedItemColor: isDark ? const Color(0xFF2DD4BF) : tealColor,
        unselectedItemColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        selectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Plan'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workouts'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildDayStatus(String day, String label, IconData icon, bool isDone, bool isMissed, bool isRest, bool isToday, bool isDark) {
    Color circleColor;
    Color iconColor;
    Color textColor;

    if (isDone) {
      circleColor = isDark ? const Color(0xFF064E3B) : const Color(0xFF006257);
      iconColor = isDark ? const Color(0xFF2DD4BF) : Colors.white;
      textColor = isDark ? const Color(0xFF2DD4BF) : const Color(0xFF006257);
    } else if (isMissed) {
      circleColor = isDark ? const Color(0xFF7C2D12).withValues(alpha: 0.4) : const Color(0xFFFDE6D2);
      iconColor = isDark ? const Color(0xFFFDBA74) : const Color(0xFFB45309);
      textColor = isDark ? const Color(0xFFFDBA74) : const Color(0xFFB45309);
    } else if (isToday) {
      circleColor = isDark ? const Color(0xFF2DD4BF) : const Color(0xFF006257);
      iconColor = isDark ? const Color(0xFF0F172A) : Colors.white;
      textColor = isDark ? const Color(0xFF2DD4BF) : const Color(0xFF006257);
    } else {
      // Rest or Plan
      circleColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFEEF2FF);
      iconColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
      textColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    }

    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            border: isDark && !isDone && !isToday && !isMissed ? Border.all(color: const Color(0xFF334155)) : null,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: isDone || isToday ? FontWeight.w800 : FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildImageTag(IconData icon, String text, {Color? color, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.85) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color ?? (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF006257)), size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedCard(String day, String title, String subtitle, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF064E3B) : const Color(0xFFC8F3EA),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle_outline, color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF065F46), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        day,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF064E3B) : const Color(0xFF006257),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Completed',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFF2DD4BF) : Colors.white,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(Icons.check, color: isDark ? const Color(0xFF2DD4BF) : Colors.white, size: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.refresh, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
              onPressed: onTap,
            ),
          ],
        ),
      ),
    );
  }
}
