import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../profile/presentation/screens/main_navigation_screen.dart';
import '../../../progress/data/models/progress_data.dart';
import '../../../progress/data/services/progress_service.dart';
import '../widgets/celebration_hero_section.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';

/// Pixel-perfect "Workout Complete" summary screen matching Coach Maya's Figma design.
class WorkoutCompleteScreen extends StatelessWidget {
  final String workoutTitle;
  final int durationMinutes;
  final int activeMinutes;
  final int caloriesBurned;
  final int averageHeartRate;
  final String coachName;
  final String coachAvatar;

  const WorkoutCompleteScreen({
    super.key,
    this.workoutTitle = "Workout Session",
    this.durationMinutes = 25,
    this.activeMinutes = 22,
    this.caloriesBurned = 180,
    this.averageHeartRate = 124,
    this.coachName = 'Coach Maya',
    this.coachAvatar = 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&auto=format&fit=crop&q=80',
  });

  static const primaryGreen = Color(0xFF0D7A6B); // Teal green from Figma
  static const softGreenBg = Color(0xFFE6F4F1);
  static const cardBorderColor = Color(0xFFF1F5F9);

  @override
  Widget build(BuildContext context) {
    // Progress data fallback/integration
    final progressData = ProgressService.getProgressData(ProgressTimeframe.thisWeek);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: softGreenBg,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: primaryGreen,
                  size: 18,
                ),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const MainNavigationScreen(initialIndex: 2),
                    ),
                    (route) => false,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Workout Summary',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        actions: const [
          NotificationBell(
            size: 38,
            iconSize: 22,
          ),
          Padding(
            padding: EdgeInsets.only(right: 20, left: 4),
            child: UserAvatar(radius: 16),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
                  // 1. Hero Celebration Header
                  const CelebrationHeroSection(
                    title: 'Workout Complete!',
                  ),
                  const SizedBox(height: 20),

                  // 2. 4 Stat Cards Grid (2x2)
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: MediaQuery.of(context).size.width > 600 ? 1.2 : 1.65,
                    ),
                    children: [
                      _buildStatCard(
                        title: 'DURATION',
                        value: '$durationMinutes min',
                        subtitle: 'Total recorded',
                        icon: Icons.access_time_rounded,
                        iconBgColor: const Color(0xFFE0F2FE),
                        iconColor: const Color(0xFF0284C7),
                      ),
                      _buildStatCard(
                        title: 'ACTIVE TIME',
                        value: '$activeMinutes active min',
                        subtitle: 'In target zones',
                        icon: Icons.bolt_rounded,
                        iconBgColor: const Color(0xFFDCFCE7),
                        iconColor: const Color(0xFF16A34A),
                      ),
                      _buildStatCard(
                        title: 'ENERGY',
                        value: '$caloriesBurned kcal',
                        subtitle: 'Burn estimated',
                        icon: Icons.local_fire_department_rounded,
                        iconBgColor: const Color(0xFFFFEDD5),
                        iconColor: const Color(0xFFEA580C),
                      ),
                      _buildStatCard(
                        title: 'HEART RATE',
                        value: '$averageHeartRate bpm',
                        subtitle: 'Moderate intensity',
                        icon: Icons.favorite_border_rounded,
                        iconBgColor: const Color(0xFFFFE4E6),
                        iconColor: const Color(0xFFE11D48),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. Weekly Goal Card
                  _buildWeeklyGoalCard(progressData),
                  const SizedBox(height: 16),

                  // 4. Coach Maya Quote Card
                  _buildCoachMayaCard(),
                  const SizedBox(height: 22),

                  _buildActionButtons(context),
                  const SizedBox(height: 16),
                ],
              ),
            ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  /// Compact Stat Card matching Coach Maya app design
  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Title on Left, Icon on Right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.6,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 15,
                  color: iconColor,
                ),
              ),
            ],
          ),
          // Bottom Column: Value & Subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Weekly Goal Card matching Figma design
  Widget _buildWeeklyGoalCard(ProgressData progressData) {
    // Dynamic progress values with defaults matching Figma 60% (3/5)
    final completed = progressData.habitCompletedDays > 0 ? progressData.habitCompletedDays : 3;
    final total = progressData.habitScheduledDays > 0 ? progressData.habitScheduledDays : 5;
    final percent = ((completed / total) * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 2),
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
                'Weekly Goal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: softGreenBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '✓ $percent% Done',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$completed/$total workouts completed',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),

          const SizedBox(height: 16),
          Row(
            children: [
              _buildDaySegment('Mon', true),
              const SizedBox(width: 6),
              _buildDaySegment('Tue', true),
              const SizedBox(width: 6),
              _buildDaySegment('Today', true, isToday: true),
              const SizedBox(width: 6),
              _buildDaySegment('Fri', false),
              const SizedBox(width: 6),
              _buildDaySegment('Sun', false),
            ],
          ),
        ],
      ),
    );
  }

  /// Day status segment indicator
  Widget _buildDaySegment(String dayLabel, bool isCompleted, {bool isToday = false}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 4,
            decoration: BoxDecoration(
              color: isCompleted ? primaryGreen : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dayLabel,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
              color: isToday
                  ? primaryGreen
                  : (isCompleted ? const Color(0xFF334155) : const Color(0xFF94A3B8)),
            ),
          ),
        ],
      ),
    );
  }

  /// Coach Maya Card matching image design
  Widget _buildCoachMayaCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coach Maya Avatar
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF0F172A),
            ),
            child: ClipOval(
              child: Image.network(
                coachAvatar,
                width: 42,
                height: 42,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Image.asset(
                  AssetPaths.userAvatar,
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
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
                      coachName.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: primaryGreen,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF0EA5E9),
                      size: 13,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '"Great job! You showed up and stayed consistent today. Rest and hydrate well "',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF475569),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Action Buttons (Done & Return Home, View Details, Share Workout)
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Main Green Button "Done & Return Home →"
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const MainNavigationScreen(initialIndex: 0),
                ),
                (route) => false,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Done & Return Home',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Sub-buttons: View Details & Share Workout
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Showing detailed performance metrics...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.insert_chart_outlined_rounded,
                    size: 16,
                    color: Color(0xFF334155),
                  ),
                  label: Text(
                    'View Details',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 42,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Workout summary copied! Ready to share 🎉'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.share_outlined,
                    size: 16,
                    color: Color(0xFF334155),
                  ),
                  label: Text(
                    'Share Workout',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Persistent bottom navigation bar matching Figma layout
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEDF2F7), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, 'Home', Icons.home_outlined),
              _buildNavItem(context, 1, 'Plan', Icons.assignment_outlined),
              _buildNavItem(context, 2, 'Workouts', Icons.fitness_center_rounded, isActive: true),
              _buildNavItem(context, 3, 'Progress', Icons.bar_chart_outlined),
              _buildNavItem(context, 4, 'Profile', Icons.person_outline_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, String label, IconData icon, {bool isActive = false}) {
    const activeColor = primaryGreen;
    const inactiveColor = Color(0xFF94A3B8);

    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => MainNavigationScreen(initialIndex: index),
            ),
            (route) => false,
          );
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : inactiveColor,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              width: 18,
              height: 2.5,
              decoration: BoxDecoration(
                color: isActive ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
