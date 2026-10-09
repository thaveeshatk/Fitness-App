import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  static const Color _primaryTeal = Color(0xFF00635A);
  static const Color _mintGreen = Color(0xFF00D18D);
  static const Color _mintGreenTint = Color(0xFFE6FAF3);
  static const Color _darkTeal = Color(0xFF0A4D4E);

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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildGreeting(),
                    const SizedBox(height: 20),
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
                      iconBg: _mintGreenTint,
                      iconColor: _primaryTeal,
                      status: 'In Progress',
                      progress: 0.66,
                      progressText: '2 / 3 days (66%)',
                    ),
                    const SizedBox(height: 12),
                    _buildChallengeCard(
                      title: 'Weekend Warrior',
                      subtitle: 'Complete 1 weekend mobility session',
                      icon: Icons.self_improvement_rounded,
                      iconBg: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFD97706),
                      status: 'upcoming',
                      rewardText: 'Reward: Consistency Badge',
                      unlocksText: 'Unlocks Sat',
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Achievements & Badges', 'View All'),
                    const SizedBox(height: 16),
                    _buildBadgesGrid(),
                    const SizedBox(height: 24),
                    _buildGentleReminder(),
                    const SizedBox(height: 40),
                  ],
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
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
        const NotificationBell(),
        const SizedBox(width: 10),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _mintGreen, width: 1.5),
          ),
          child: ClipOval(
            child: Image.asset(
              AssetPaths.userAvatar,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: _primaryTeal,
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
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
              "You're in the flow, Alex!",
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
          child: const Icon(Icons.share_outlined, size: 16, color: _primaryTeal),
        ),
      ],
    );
  }

  Widget _buildMainObjectiveCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _darkTeal,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _darkTeal.withValues(alpha: 0.3),
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
                        const Icon(Icons.check_circle_outline_rounded, size: 12, color: _mintGreen),
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
                    'Complete 5\nworkouts this week',
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
                    '60%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _mintGreen,
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
          // Segmented progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDaySegment('M', true),
              _buildDaySegment('T', true),
              _buildDaySegment('W', true),
              _buildDaySegment('T', false),
              _buildDaySegment('F', false),
              _buildDaySegment('S', false),
              _buildDaySegment('S', false),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded, size: 14, color: _mintGreen),
                  const SizedBox(width: 6),
                  Text(
                    '3 / 5 workouts completed',
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
                    '2 days left',
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
              color: isCompleted ? _mintGreen : Colors.white.withValues(alpha: 0.2),
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
        color: Colors.white,
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
                      '4-Day Streak',
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
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Active',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Personal best: 5 days. Keep the momentum!',
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
          const Icon(Icons.show_chart_rounded, color: AppColors.textSecondary, size: 20),
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
        color: Colors.white,
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
                  color: status == 'In Progress' ? _mintGreenTint : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: status == 'In Progress' ? _primaryTeal : AppColors.textSecondary,
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
                valueColor: const AlwaysStoppedAnimation<Color>(_primaryTeal),
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
    return Row(
      children: [
        Expanded(child: _badgeItem('First\nMilestone', Icons.stars_rounded, _mintGreen, true)),
        const SizedBox(width: 12),
        Expanded(child: _badgeItem('Streak\nMaster', Icons.local_fire_department_rounded, const Color(0xFFD97706), true)),
        const SizedBox(width: 12),
        Expanded(child: _badgeItem('Core\nExplorer', Icons.fitness_center_rounded, AppColors.textMuted, false)),
      ],
    );
  }

  Widget _badgeItem(String title, IconData icon, Color color, bool unlocked) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: unlocked ? color.withValues(alpha: 0.5) : AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: unlocked ? color.withValues(alpha: 0.1) : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (unlocked) const Icon(Icons.check_rounded, size: 10, color: _primaryTeal),
              if (unlocked) const SizedBox(width: 2),
              Text(
                unlocked ? 'Unlocked' : '1 session left',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: unlocked ? _primaryTeal : AppColors.textSecondary,
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
