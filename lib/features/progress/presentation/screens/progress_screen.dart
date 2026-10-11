import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../data/models/progress_data.dart';
import '../../data/services/progress_service.dart';
import 'history_screen.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';

/// Progress Tracker Screen
/// Pixel-perfect, consistent with the rest of the application screens,
/// powered by live user profile data and workout statistics.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  // Brand color tokens
  static const Color _primaryTeal = Color(0xFF00635A);
  static const Color _mintGreen = Color(0xFF00D18D);
  static const Color _mintGreenTint = Color(0xFFE6FAF3);
  static const Color _darkTeal = Color(0xFF0A4D4E);

  ProgressTimeframe _selectedTimeframe = ProgressTimeframe.thisWeek;
  late ProgressData _data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _data = ProgressService.getProgressData(_selectedTimeframe);
    });
  }

  void _onTimeframeChanged(ProgressTimeframe timeframe) {
    if (_selectedTimeframe != timeframe) {
      HapticFeedback.selectionClick();
      setState(() {
        _selectedTimeframe = timeframe;
        _data = ProgressService.getProgressData(timeframe);
      });
    }
  }

  void _shareQuote() {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(
      text: '✨ "${_data.dailyReflectionQuote}" — Track your progress on FitOn App',
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _primaryTeal,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: _mintGreen, size: 20),
            const SizedBox(width: 10),
            Text(
              'Reflection quote copied to clipboard!',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Refresh data in case profile was updated in another tab
    _data = ProgressService.getProgressData(_selectedTimeframe);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopHeader(),
              const SizedBox(height: 16),
              _buildSegmentedFilter(),
              const SizedBox(height: 14),
              _buildRoutineCapsuleBadge(),
              const SizedBox(height: 14),
              _buildStatsCardsRow(),
              const SizedBox(height: 12),
              _buildEnergyExpendedCard(),
              const SizedBox(height: 14),
              _buildHabitHealthCard(),
              const SizedBox(height: 14),
              _buildDailyActivityCard(),
              const SizedBox(height: 14),
              _buildMilestoneJourneyCard(),
              const SizedBox(height: 14),
              _buildDailyReflectionCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── 1. Top Header ──────────────────────────────────────────────────────────
  Widget _buildTopHeader() {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _primaryTeal,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _primaryTeal.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.show_chart_rounded, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            Text(
              'Insights & Consistency',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const Spacer(),
        // Notification bell
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: NotificationBell(
              size: 36,
              iconSize: 20,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // User Avatar
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _mintGreen, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: _primaryTeal.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              AssetPaths.userAvatar,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: _primaryTeal,
                child: const Center(
                  child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── 2. Segmented Filter Tabs ───────────────────────────────────────────────
  Widget _buildSegmentedFilter() {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4F5),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          _filterPill('This Week', ProgressTimeframe.thisWeek),
          _filterPill('This Month', ProgressTimeframe.thisMonth),
          _filterPill('All Time', ProgressTimeframe.allTime),
        ],
      ),
    );
  }

  Widget _filterPill(String title, ProgressTimeframe timeframe) {
    final isSelected = _selectedTimeframe == timeframe;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTimeframeChanged(timeframe),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── 3. Routine Capsule Badge ───────────────────────────────────────────────
  Widget _buildRoutineCapsuleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _mintGreenTint,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _mintGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: _mintGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '✦ ${_data.routineTitle}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: _darkTeal,
                letterSpacing: 0.8,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _data.routineWeekLabel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: _primaryTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. Stats Cards Row (Workouts & Active Movement) ────────────────────────
  Widget _buildStatsCardsRow() {
    return Row(
      children: [
        // Left Card: Workouts
        Expanded(
          child: _statCard(
            badgeIcon: Icons.check_circle_rounded,
            badgeIconColor: _primaryTeal,
            badgeBgColor: _mintGreenTint,
            targetText: 'Target: ${_data.targetWorkouts}',
            bigValue: '${_data.completedWorkouts} Workouts',
            subtitle: 'Completed so far',
            progressFraction: _data.targetWorkouts > 0 ? _data.completedWorkouts / _data.targetWorkouts : 0.0,
            progressColor: _primaryTeal,
          ),
        ),
        const SizedBox(width: 12),
        // Right Card: Active Movement
        Expanded(
          child: _statCard(
            badgeIcon: Icons.timer_outlined,
            badgeIconColor: const Color(0xFFD97706),
            badgeBgColor: const Color(0xFFFEF3C7),
            targetText: 'Target: ${_data.targetMinutes}m',
            bigValue: '${_data.activeMinutes} mins',
            subtitle: 'Active Movement',
            progressFraction: _data.targetMinutes > 0 ? _data.activeMinutes / _data.targetMinutes : 0.0,
            progressColor: const Color(0xFFD97706),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData badgeIcon,
    required Color badgeIconColor,
    required Color badgeBgColor,
    required String targetText,
    required String bigValue,
    required String subtitle,
    required double progressFraction,
    required Color progressColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(badgeIcon, size: 17, color: badgeIconColor),
              ),
              const Spacer(),
              Text(
                targetText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            bigValue,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressFraction.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }

  // ── 5. Energy Expended Card ────────────────────────────────────────────────
  Widget _buildEnergyExpendedCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Coral flame icon
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              size: 22,
              color: Color(0xFFEF4444),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ENERGY EXPENDED',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${_data.energyExpendedKcal} kcal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          const Spacer(),
          // +12% pill & vs last week
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _mintGreenTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_outward_rounded,
                      size: 11,
                      color: _darkTeal,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '+${_data.energyVsLastWeekPercent}%',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _darkTeal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'vs last week',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 6. Habit Health Card (Custom Painted Circular Gauge 80%) ───────────────
  Widget _buildHabitHealthCard() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const HistoryScreen(),
          ),
        );
      },
      child: Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HABIT HEALTH',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMuted,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Workout Consistency',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // On Track Consistent pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _mintGreenTint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: _mintGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _data.habitStatus,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: _darkTeal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Custom-painted smooth circular gauge
              SizedBox(
                width: 68,
                height: 68,
                child: CustomPaint(
                  painter: _CircularGaugePainter(
                    progress: _data.habitConsistencyPercent / 100.0,
                    activeColor: _primaryTeal,
                    backgroundColor: const Color(0xFFEFF4F5),
                    strokeWidth: 6.8,
                  ),
                  child: Center(
                    child: Text(
                      '${_data.habitConsistencyPercent}%',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(text: 'You have worked out '),
                          TextSpan(
                            text: '${_data.habitCompletedDays} out of the last ${_data.habitScheduledDays} scheduled days.',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Consistency beats intensity every single time.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  // ── 7. Daily Activity Section (7-Day Bar Chart) ────────────────────────────
  Widget _buildDailyActivityCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with legend
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DAILY ACTIVITY',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMuted,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Minutes Moved',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Legend
              Row(
                children: [
                  _legendDot(_primaryTeal, 'Workout'),
                  const SizedBox(width: 10),
                  _legendDot(const Color(0xFFE2E8F0), 'Rest'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          // 7-day bar chart
          SizedBox(
            height: 130,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _data.dailyActivities.map((day) => _buildDayBar(day)).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Bottom banner: gentle stretch day note
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: _primaryTeal,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _data.restDayMessage,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDayBar(DailyActivityItem day) {
    const double maxBarHeight = 72.0;
    final maxMinutes = _data.dailyActivities
        .map((d) => d.minutes)
        .fold(1, (a, b) => a > b ? a : b);
    final double barHeight = day.isRest
        ? 5.0
        : ((day.minutes / maxMinutes) * maxBarHeight).clamp(12.0, maxBarHeight);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Tag badge (Today or Plan)
        if (day.isToday)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: _darkTeal,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Today',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          )
        else if (day.isPlanned)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: _mintGreenTint,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Plan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                color: _darkTeal,
              ),
            ),
          )
        else
          const SizedBox(height: 18),

        // Value text (e.g. 20m or Rest)
        Text(
          day.isRest ? 'Rest' : '${day.minutes}m',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: day.isToday ? FontWeight.w800 : FontWeight.w600,
            color: day.isRest
                ? AppColors.textMuted
                : (day.isToday ? _primaryTeal : AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 5),

        // Vertical Bar
        Container(
          width: 28,
          height: barHeight,
          decoration: BoxDecoration(
            gradient: day.isRest || day.isPlanned
                ? null
                : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: day.isToday
                        ? [_mintGreen, _primaryTeal]
                        : [const Color(0xFF00796B), const Color(0xFF004D40)],
                  ),
            color: day.isRest
                ? const Color(0xFFE2E8F0)
                : (day.isPlanned ? _mintGreen.withValues(alpha: 0.3) : null),
            borderRadius: BorderRadius.circular(day.isRest ? 3 : 7),
            border: day.isToday
                ? Border.all(color: _mintGreen.withValues(alpha: 0.6), width: 1.5)
                : null,
            boxShadow: day.isToday
                ? [
                    BoxShadow(
                      color: _primaryTeal.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 7),

        // Day label
        Text(
          day.dayName,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.5,
            fontWeight: day.isToday ? FontWeight.w800 : FontWeight.w600,
            color: day.isToday ? _primaryTeal : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ── 8. Milestone Journey Card ──────────────────────────────────────────────
  Widget _buildMilestoneJourneyCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Trophy container
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  size: 22,
                  color: Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MILESTONE JOURNEY',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _data.milestoneTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      _data.milestoneLevelText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${_data.milestonePercent}%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: _primaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Mint green progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _data.milestonePercent / 100.0,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(_mintGreen),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _data.currentBadgeName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _data.nextBadgeName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 9. Daily Reflection Card ───────────────────────────────────────────────
  Widget _buildDailyReflectionCard() {
    return Container(
      height: 154,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.asset(
              AssetPaths.dailyReflection,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: _darkTeal,
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.68),
                    Colors.black.withValues(alpha: 0.42),
                    Colors.black.withValues(alpha: 0.65),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Quote content
            Padding(
              padding: const EdgeInsets.all(17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _mintGreen.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _mintGreen.withValues(alpha: 0.45),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'DAILY REFLECTION',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: _mintGreen,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '"${_data.dailyReflectionQuote}"',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.35,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _shareQuote,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.45),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.share_rounded,
                            size: 17,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Custom Painted Smooth Circular Gauge ─────────────────────────────────────
class _CircularGaugePainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color backgroundColor;
  final double strokeWidth;

  const _CircularGaugePainter({
    required this.progress,
    required this.activeColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    // Background track circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Active progress arc
    final activePaint = Paint()
      ..color = activeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start at top
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
