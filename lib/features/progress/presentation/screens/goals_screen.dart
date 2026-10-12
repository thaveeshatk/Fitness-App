import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../profile/data/services/profile_service.dart';
import '../../data/services/user_activity_service.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../profile/presentation/screens/profile_preferences_screen.dart';

class GoalsScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const GoalsScreen({super.key, this.onNavigateToTab});

  static const Color _primaryTeal = Color(0xFF00635A);
  static const Color _mintGreen = Color(0xFF00D18D);
  static const Color _mintGreenTint = Color(0xFFE6FAF3);
  static const Color _darkTeal = Color(0xFF0A4D4E);

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  String _userName = 'Alex';
  int _targetDays = 3;
  int _completedDays = 0;
  int _streak = 0;
  int _percent = 0;
  int _totalWorkouts = 0;
  int _totalMinutes = 0;
  List<bool> _completedDayFlags = List.filled(7, false);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoalData();
    AuthService.userNotifier.addListener(_onAuthChanged);
    ProfileService.profileNotifier.addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    AuthService.userNotifier.removeListener(_onAuthChanged);
    ProfileService.profileNotifier.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) _loadGoalData(forceRefresh: true);
  }

  void _onProfileChanged() {
    if (mounted) _loadGoalData(forceRefresh: true);
  }

  Future<void> _loadGoalData({bool forceRefresh = false}) async {
    final currentUid = AuthService.currentUser.uid;
    final user = AuthService.currentUser;

    try {
      final profile = await ProfileService.getProfile(docId: currentUid, forceRefresh: forceRefresh);
      final progress = await UserActivityService.getWeeklyProgress(uid: currentUid);
      final allActivities = await UserActivityService.getAllActivities(uid: currentUid);
      final thisWeeksActivities = await UserActivityService.getThisWeeksActivities(uid: currentUid);
      final totalMinutes = allActivities.fold<int>(
        0,
        (sum, act) => sum + ((act['durationMinutes'] as num?)?.toInt() ?? 0),
      );

      final target = profile.weeklyRoutineDays.isNotEmpty ? profile.weeklyRoutineDays.length : 3;
      final completed = (progress['completed'] as int?) ?? 0;
      final streak = (progress['streak'] as int?) ?? 0;
      final percent = target > 0 ? ((completed / target) * 100).round() : 0;

      // 7 days of this week (Mon-Sun)
      final now = DateTime.now();
      final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
      final List<bool> flags = List.filled(7, false);

      for (int i = 0; i < 7; i++) {
        final d = startOfWeek.add(Duration(days: i));
        flags[i] = thisWeeksActivities.any((a) {
          final completedAtStr = a['completedAt']?.toString();
          if (completedAtStr == null) return false;
          final actDate = DateTime.tryParse(completedAtStr);
          return actDate != null &&
              actDate.year == d.year &&
              actDate.month == d.month &&
              actDate.day == d.day;
        });
      }

      if (mounted) {
        setState(() {
          _userName = user.name;
          _targetDays = target;
          _completedDays = completed;
          _streak = streak;
          _percent = percent;
          _totalWorkouts = allActivities.length;
          _totalMinutes = totalMinutes;
          _completedDayFlags = flags;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: _buildTopHeader(context),
            ),
            Expanded(
              child: RefreshIndicator(
                color: GoalsScreen._primaryTeal,
                onRefresh: _loadGoalData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildGreeting(),
                      const SizedBox(height: 20),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: Center(
                            child: CircularProgressIndicator(color: GoalsScreen._primaryTeal),
                          ),
                        )
                      else ...[
                        _buildMainObjectiveCard(),
                        const SizedBox(height: 16),
                        _buildStreakCard(),
                        const SizedBox(height: 24),
                        _buildSectionHeader('Active Challenges', '2 Ongoing'),
                        const SizedBox(height: 16),
                        _buildChallengeCard(
                          title: 'Consistency Starter',
                          subtitle: 'Work out 3 days in a row',
                          icon: Icons.repeat_rounded,
                          iconBg: GoalsScreen._mintGreenTint,
                          iconColor: GoalsScreen._primaryTeal,
                          status: _streak >= 3 ? 'Completed' : 'In Progress',
                          progress: (_streak / 3).clamp(0.0, 1.0),
                          progressText: _streak >= 3
                              ? '3 / 3 days (100%)'
                              : '$_streak / 3 days (${((_streak / 3) * 100).round()}%)',
                        ),
                        const SizedBox(height: 12),
                        _buildChallengeCard(
                          title: 'Weekend Warrior',
                          subtitle: 'Complete 1 weekend mobility session',
                          icon: Icons.self_improvement_rounded,
                          iconBg: const Color(0xFFFEF3C7),
                          iconColor: const Color(0xFFD97706),
                          status: _completedDayFlags[5] || _completedDayFlags[6]
                              ? 'Completed'
                              : 'Upcoming',
                          rewardText: 'Reward: Consistency Badge',
                          unlocksText: _completedDayFlags[5] || _completedDayFlags[6]
                              ? 'Unlocked 🎉'
                              : 'Unlocks Sat/Sun',
                        ),
                        const SizedBox(height: 24),
                        _buildSectionHeader('Achievements & Badges', 'View All'),
                        const SizedBox(height: 16),
                        _buildBadgesGrid(),
                        const SizedBox(height: 24),
                        _buildGentleReminder(),
                        const SizedBox(height: 40),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Goals',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        const Spacer(),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: const Center(
            child: NotificationBell(
              size: 36,
              iconSize: 20,
            ),
          ),
        ),
        const SizedBox(width: 10),
        UserAvatar(
          radius: 19,
          border: Border.all(color: GoalsScreen._mintGreen, width: 1.5),
          onTap: () {
            if (widget.onNavigateToTab != null) {
              Navigator.of(context).pop();
              widget.onNavigateToTab!(4);
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProfilePreferencesScreen(
                    onBack: () => Navigator.of(context).pop(),
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WEEKLY RHYTHM',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _completedDays > 0 ? "You're in the flow, $_userName!" : "Welcome to your goals, $_userName!",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF4F5),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: const Icon(Icons.share_outlined, size: 16, color: GoalsScreen._primaryTeal),
        ),
      ],
    );
  }

  Widget _buildMainObjectiveCard() {
    final daysRemainingInWeek = 7 - DateTime.now().weekday;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GoalsScreen._darkTeal,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: GoalsScreen._darkTeal.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 12, color: GoalsScreen._mintGreen),
                        const SizedBox(width: 4),
                        Text(
                          'Main Objective',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Complete $_targetDays\nworkouts this week',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$_percent%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: GoalsScreen._mintGreen,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    'Completed',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Segmented progress for Mon through Sun
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDaySegment('M', _completedDayFlags[0]),
              _buildDaySegment('T', _completedDayFlags[1]),
              _buildDaySegment('W', _completedDayFlags[2]),
              _buildDaySegment('T', _completedDayFlags[3]),
              _buildDaySegment('F', _completedDayFlags[4]),
              _buildDaySegment('S', _completedDayFlags[5]),
              _buildDaySegment('S', _completedDayFlags[6]),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded, size: 14, color: GoalsScreen._mintGreen),
                  const SizedBox(width: 6),
                  Text(
                    '$_completedDays / $_targetDays workouts completed',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 14, color: Colors.white.withValues(alpha: 0.8)),
                  const SizedBox(width: 6),
                  Text(
                    daysRemainingInWeek > 0 ? '$daysRemainingInWeek days left' : 'Last day of week',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDaySegment(String day, bool isCompleted) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isCompleted ? GoalsScreen._mintGreen : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            day,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isCompleted ? Colors.white : Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_fire_department_rounded, color: Color(0xFFEF4444), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$_streak-Day Streak',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _streak > 0 ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _streak > 0 ? 'Active' : 'Start Today',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: _streak > 0 ? const Color(0xFFEF4444) : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _streak > 0
                      ? 'Keep the momentum going! Every session counts.'
                      : 'Complete a workout today to light up your streak flame!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.show_chart_rounded, color: AppColors.textSecondary, size: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String status,
    double? progress,
    String? progressText,
    String? rewardText,
    String? unlocksText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'Completed'
                      ? const Color(0xFFD1FAE5)
                      : (status == 'In Progress' ? GoalsScreen._mintGreenTint : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: status == 'Completed'
                        ? const Color(0xFF047857)
                        : (status == 'In Progress' ? GoalsScreen._primaryTeal : AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
          if (progress != null && progressText != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Progress',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  progressText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: const AlwaysStoppedAnimation<Color>(GoalsScreen._primaryTeal),
              ),
            ),
          ],
          if (rewardText != null && unlocksText != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_outlined, size: 14, color: Color(0xFFD97706)),
                  const SizedBox(width: 8),
                  Text(
                    rewardText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFD97706),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    unlocksText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadgesGrid() {
    final isFirstWorkoutUnlocked = _totalWorkouts >= 1;
    final isTargetAchieverUnlocked = _completedDays >= _targetDays && _targetDays > 0;
    final isConsistencyChampionUnlocked = _totalWorkouts >= 5;
    final isCenturyClubUnlocked = _totalMinutes >= 100;

    return Column(
      children: [
        Row(
          children: [
            // Badge 1: 🥇 First Workout Badge
            Expanded(
              child: _badgeCard(
                title: 'First Workout',
                badgeEmoji: '🥇',
                accentColor: const Color(0xFFD97706),
                unlocked: isFirstWorkoutUnlocked,
                progress: isFirstWorkoutUnlocked ? 1.0 : (_totalWorkouts / 1.0),
                progressText: isFirstWorkoutUnlocked ? '1 / 1 (100%)' : '0 / 1 workout',
                remainingText: isFirstWorkoutUnlocked ? 'Unlocked 🎉' : '1 session left',
                description: 'Complete 1st workout',
              ),
            ),
            const SizedBox(width: 12),
            // Badge 2: 🎯 Target Achiever
            Expanded(
              child: _badgeCard(
                title: 'Target Achiever',
                badgeEmoji: '🎯',
                accentColor: GoalsScreen._primaryTeal,
                unlocked: isTargetAchieverUnlocked,
                progress: _targetDays > 0 ? (_completedDays / _targetDays).clamp(0.0, 1.0) : 0.0,
                progressText: isTargetAchieverUnlocked
                    ? '$_completedDays / $_targetDays (100%)'
                    : '$_completedDays / $_targetDays days',
                remainingText: isTargetAchieverUnlocked
                    ? 'Unlocked 🎉'
                    : '${math.max(1, _targetDays - _completedDays)} sessions left',
                description: 'Hit weekly target',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Badge 3: ⚡ Consistency Champion
            Expanded(
              child: _badgeCard(
                title: 'Consistency\nChampion',
                badgeEmoji: '⚡',
                accentColor: const Color(0xFFF59E0B),
                unlocked: isConsistencyChampionUnlocked,
                progress: (_totalWorkouts / 5.0).clamp(0.0, 1.0),
                progressText: isConsistencyChampionUnlocked
                    ? '$_totalWorkouts / 5 (100%)'
                    : '$_totalWorkouts / 5 workouts',
                remainingText: isConsistencyChampionUnlocked
                    ? 'Unlocked 🎉'
                    : '${math.max(1, 5 - _totalWorkouts)} sessions left',
                description: 'Log 5 workouts',
              ),
            ),
            const SizedBox(width: 12),
            // Badge 4: ⏱️ Century Club
            Expanded(
              child: _badgeCard(
                title: 'Century Club',
                badgeEmoji: '⏱️',
                accentColor: const Color(0xFF0D9488),
                unlocked: isCenturyClubUnlocked,
                progress: (_totalMinutes / 100.0).clamp(0.0, 1.0),
                progressText: isCenturyClubUnlocked
                    ? '${_totalMinutes}m / 100m'
                    : '${_totalMinutes}m / 100m',
                remainingText: isCenturyClubUnlocked
                    ? 'Unlocked 🎉'
                    : '${math.max(1, 100 - _totalMinutes)}m left',
                description: '100 active mins',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _badgeCard({
    required String title,
    required String badgeEmoji,
    required Color accentColor,
    required bool unlocked,
    required double progress,
    required String progressText,
    required String remainingText,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: unlocked ? accentColor.withValues(alpha: 0.45) : AppColors.cardBorder,
          width: unlocked ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: unlocked
                ? accentColor.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Emoji avatar & Unlocked/In Progress Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: unlocked ? accentColor.withValues(alpha: 0.12) : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: unlocked ? accentColor.withValues(alpha: 0.3) : Colors.transparent,
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    badgeEmoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: unlocked
                      ? const Color(0xFFD1FAE5) // Soft green
                      : const Color(0xFFF1F5F9), // Soft slate
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (unlocked) ...[
                      const Icon(Icons.check_rounded, size: 10, color: Color(0xFF047857)),
                      const SizedBox(width: 2),
                    ],
                    Text(
                      unlocked ? 'Unlocked' : 'In Progress',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: unlocked ? const Color(0xFF047857) : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Title
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 2),

          // Description
          Text(
            description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 10),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(
                unlocked ? GoalsScreen._mintGreen : accentColor,
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Progress text & remaining badge text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                unlocked ? 'Goal Met' : progressText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                remainingText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: unlocked ? GoalsScreen._primaryTeal : accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGentleReminder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF0284C7), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gentle Habit Reminder',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0369A1),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Consistent light movement builds stronger neuro-muscular pathways than sporadic high-intensity sessions.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF0C4A6E),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
