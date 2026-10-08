import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/data/models/auth_user.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../data/models/profile_model.dart';
import '../../data/services/profile_service.dart';
import '../widgets/profile_photo_picker_dialog.dart';
import 'settings_screen.dart';

/// Screen for viewing and updating user fitness profile & preferences.
/// Matches the provided wireframe pixel-for-pixel.
class ProfilePreferencesScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ProfilePreferencesScreen({super.key, this.onBack});

  @override
  State<ProfilePreferencesScreen> createState() => _ProfilePreferencesScreenState();
}

class _ProfilePreferencesScreenState extends State<ProfilePreferencesScreen> {
  // ── State ──────────────────────────────────────────────────────────────────
  late String _fitnessLevel;
  late String _primaryGoal;
  late int _workoutMinutes;
  late Set<String> _weeklyRoutineDays;
  late Set<String> _preferredStyles;
  late Set<String> _equipment;

  bool _isSaving = false;

  // ── Options Metadata ───────────────────────────────────────────────────────
  static const _goalCards = [
    _GoalOption(
      id: 'Weight Loss',
      title: 'Weight Loss',
      subtitle: 'Calorie burn focus',
      icon: Icons.local_fire_department_rounded,
    ),
    _GoalOption(
      id: 'Build Strength',
      title: 'Build Strength',
      subtitle: 'Tone & muscle',
      icon: Icons.open_in_full_rounded,
    ),
    _GoalOption(
      id: 'Improve Fitness',
      title: 'Improve Fitness',
      subtitle: 'Heart health & stamina',
      icon: Icons.show_chart_rounded,
    ),
    _GoalOption(
      id: 'Stay Active',
      title: 'Stay Active',
      subtitle: 'Gentle daily motion',
      icon: Icons.sentiment_satisfied_alt_rounded,
    ),
  ];

  static const _durationOptions = [10, 20, 30, 45];

  static const _dayOptions = [
    _DayItem(id: 'M1', label: 'M', dayName: 'Monday'),
    _DayItem(id: 'T1', label: 'T', dayName: 'Tuesday'),
    _DayItem(id: 'W', label: 'W', dayName: 'Wednesday'),
    _DayItem(id: 'T2', label: 'T', dayName: 'Thursday'),
    _DayItem(id: 'F', label: 'F', dayName: 'Friday'),
    _DayItem(id: 'S1', label: 'S', dayName: 'Saturday'),
    _DayItem(id: 'S2', label: 'S', dayName: 'Sunday'),
  ];

  static const _styleOptions = [
    _StyleItem(id: 'Strength', label: 'Strength', icon: Icons.fitness_center_rounded),
    _StyleItem(id: 'HIIT', label: 'HIIT', icon: Icons.bolt_rounded),
    _StyleItem(id: 'Yoga', label: 'Yoga', icon: Icons.self_improvement_rounded),
    _StyleItem(id: 'Cardio', label: 'Cardio', icon: Icons.directions_run_rounded),
    _StyleItem(id: 'Stretching', label: 'Stretching', icon: Icons.accessibility_new_rounded),
  ];

  static const _equipmentList = [
    _EquipmentItem(
      id: 'Bodyweight Only',
      title: 'Bodyweight Only',
      subtitle: 'No external gear required',
      icon: Icons.accessibility_new_rounded,
    ),
    _EquipmentItem(
      id: 'Yoga / Exercise Mat',
      title: 'Yoga / Exercise Mat',
      subtitle: 'Padded joint protection',
      icon: Icons.crop_landscape_rounded,
    ),
    _EquipmentItem(
      id: 'Resistance Bands',
      title: 'Resistance Bands',
      subtitle: 'Loop or handle tubes',
      icon: Icons.all_inclusive_rounded,
    ),
    _EquipmentItem(
      id: 'Dumbbells',
      title: 'Dumbbells',
      subtitle: 'Adjustable or fixed pairs',
      icon: Icons.fitness_center_rounded,
    ),
    _EquipmentItem(
      id: 'Other Equipment',
      title: 'Other Equipment',
      subtitle: 'Kettlebell, foam roller, pull-up bar',
      icon: Icons.more_horiz_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  void _loadCurrentProfile() {
    final profile = ProfileService.currentProfile;
    _fitnessLevel = profile.fitnessLevel;
    _primaryGoal = profile.goals.isNotEmpty ? profile.goals.first : 'Weight Loss';
    _workoutMinutes = profile.workoutMinutes;
    _weeklyRoutineDays = profile.weeklyRoutineDays.toSet();
    if (_weeklyRoutineDays.isEmpty) {
      _weeklyRoutineDays = {'M1', 'W', 'F'};
    }
    _preferredStyles = profile.preferredStyles.toSet();
    if (_preferredStyles.isEmpty) {
      _preferredStyles = {'HIIT', 'Yoga', 'Stretching'};
    }
    _equipment = profile.equipment.toSet();
    if (_equipment.isEmpty) {
      _equipment = {'Bodyweight Only', 'Yoga / Exercise Mat'};
    }
  }

  // ── Save Action ────────────────────────────────────────────────────────────
  Future<void> _onSavePreferences() async {
    setState(() => _isSaving = true);

    final updatedProfile = ProfileModel(
      fitnessLevel: _fitnessLevel,
      goals: [_primaryGoal],
      workoutMinutes: _workoutMinutes,
      weeklyRoutineDays: _weeklyRoutineDays.toList(),
      preferredStyles: _preferredStyles.toList(),
      equipment: _equipment.toList(),
    );

    try {
      await ProfileService.saveProfile(updatedProfile);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Preferences saved successfully!',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13.5),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryTeal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save preferences: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFD),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopHeader(),
              const SizedBox(height: 16),
              _buildSubHeader(),
              const SizedBox(height: 16),
              _buildUserProfilePhotoCard(),
              const SizedBox(height: 16),
              _buildRhythmBanner(),
              const SizedBox(height: 24),
              _buildPrimaryFitnessGoalSection(),
              const SizedBox(height: 24),
              _buildFitnessLevelSection(),
              const SizedBox(height: 24),
              _buildWorkoutDurationSection(),
              const SizedBox(height: 24),
              _buildWeeklyRoutineSection(),
              const SizedBox(height: 24),
              _buildPreferredStylesSection(),
              const SizedBox(height: 24),
              _buildAvailableEquipmentSection(),
              const SizedBox(height: 30),
              _buildSaveButton(),
              const SizedBox(height: 14),
              _buildLogoutButton(),
              const SizedBox(height: 14),
              _buildFooterNotice(),
              const SizedBox(height: 28),
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
        // Brand circle logo with pulse line
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Color(0xFF00635A),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.show_chart_rounded, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Profile & Preferences',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        // Settings icon
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            child: const Icon(
              Icons.settings_outlined,
              color: Color(0xFF334155),
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 4),
        // Notification bell
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: const Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF334155),
            size: 24,
          ),
        ),
        const SizedBox(width: 8),
        // User Avatar
        UserAvatar(
          radius: 17,
          onTap: () => ProfilePhotoPickerDialog.show(context),
        ),
      ],
    );
  }

  // ── 2. Sub-Header Navigation Row ───────────────────────────────────────────
  Widget _buildSubHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.mainNav, arguments: 0);
            }
          },
          child: Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2F7),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.chevron_left_rounded, color: Color(0xFF334155), size: 22),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile & Preferences',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Personalize your home workout journey',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Color(0xFFD4EAE7),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.chevron_right_rounded, color: Color(0xFF006257), size: 22),
          ),
        ),
      ],
    );
  }

  // ── User Profile Photo & Account Card ──────────────────────────────────────
  Widget _buildUserProfilePhotoCard() {
    return ValueListenableBuilder<AuthUser?>(
      valueListenable: AuthService.userNotifier,
      builder: (context, user, _) {
        final name = user?.name ?? 'Alex';
        final email = user?.email ?? 'alex@fiton.com';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              UserAvatar(
                radius: 34,
                showEditBadge: true,
                onTap: () => ProfilePhotoPickerDialog.show(context),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => ProfilePhotoPickerDialog.show(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F5F2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_a_photo_outlined, size: 14, color: Color(0xFF00635A)),
                            const SizedBox(width: 5),
                            Text(
                              'Change Profile Picture',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF00635A),
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
        );
      },
    );
  }

  // ── 3. Rhythm Highlight Banner ─────────────────────────────────────────────
  Widget _buildRhythmBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F5F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF00635A),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customized for your rhythm',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Daily sessions adapt automatically as your stamina grows.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF475569),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. Primary Fitness Goal ────────────────────────────────────────────────
  Widget _buildPrimaryFitnessGoalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.outlined_flag_rounded, color: Color(0xFF006257), size: 19),
                const SizedBox(width: 8),
                Text(
                  'Primary Fitness Goal',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            Text(
              'SELECT ONE',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF006D63),
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.25,
          ),
          itemCount: _goalCards.length,
          itemBuilder: (context, index) {
            final item = _goalCards[index];
            final isSelected = _primaryGoal == item.id;

            return GestureDetector(
              onTap: () => setState(() => _primaryGoal = item.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFDCF3EE) : const Color(0xFFF3F5FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF00635A) : Colors.transparent,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          item.icon,
                          color: isSelected ? const Color(0xFF006257) : const Color(0xFF475569),
                          size: 22,
                        ),
                        const Spacer(),
                        Text(
                          item.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    if (isSelected)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00635A),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 12),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── 5. Current Fitness Level ───────────────────────────────────────────────
  Widget _buildFitnessLevelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.speed_rounded, color: Color(0xFF006257), size: 19),
                const SizedBox(width: 8),
                Text(
                  'Current Fitness Level',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            Text(
              '$_fitnessLevel Active',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF006D63),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 3-Segment Control
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F9),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: ['Beginner', 'Intermediate', 'Advanced'].map((level) {
              final isSelected = _fitnessLevel == level;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _fitnessLevel = level),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF005953) : Colors.transparent,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF005953).withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      level,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        // Tip Callout Box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF3FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.verified_outlined, color: Color(0xFF00635A), size: 19),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF475569),
                      height: 1.35,
                    ),
                    children: [
                      TextSpan(
                        text: _getTipTitle(_fitnessLevel),
                        style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                      ),
                      TextSpan(text: _getTipBody(_fitnessLevel)),
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

  String _getTipTitle(String level) {
    switch (level) {
      case 'Intermediate':
        return 'Ideal for consistent trainers: ';
      case 'Advanced':
        return 'Designed for high performance: ';
      default:
        return 'Best for home starters: ';
    }
  }

  String _getTipBody(String level) {
    switch (level) {
      case 'Intermediate':
        return 'Progressive resistance circuits and interval training.';
      case 'Advanced':
        return 'High intensity athletic conditioning & peak stamina.';
      default:
        return 'Foundational bodyweight forms & injury prevention.';
    }
  }

  // ── 6. Target Workout Duration ─────────────────────────────────────────────
  Widget _buildWorkoutDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: Color(0xFF006257), size: 19),
                const SizedBox(width: 8),
                Text(
                  'Target Workout Duration',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            Text(
              'Typical session',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: _durationOptions.map((minutes) {
            final isSelected = _workoutMinutes == minutes;
            final label = minutes == 45 ? '45+' : '$minutes';

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => setState(() => _workoutMinutes = minutes),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF005953) : const Color(0xFFF1F4FA),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF005953).withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          'min',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white70 : const Color(0xFF64748B),
                          ),
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

  // ── 7. Weekly Routine Days ─────────────────────────────────────────────────
  Widget _buildWeeklyRoutineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: Color(0xFF006257), size: 19),
                const SizedBox(width: 8),
                Text(
                  'Weekly Routine Days',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            Text(
              '${_weeklyRoutineDays.length} days / week',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF006D63),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Select the days you prefer to exercise at home.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _dayOptions.map((day) {
            final isSelected = _weeklyRoutineDays.contains(day.id);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    if (_weeklyRoutineDays.length > 1) {
                      _weeklyRoutineDays.remove(day.id);
                    }
                  } else {
                    _weeklyRoutineDays.add(day.id);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF005953) : const Color(0xFFF1F4FA),
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF005953).withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (isSelected)
                      const Icon(Icons.check_rounded, color: Colors.white, size: 12)
                    else
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Color(0xFF94A3B8),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── 8. Preferred Styles ────────────────────────────────────────────────────
  Widget _buildPreferredStylesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.category_outlined, color: Color(0xFF006257), size: 19),
                const SizedBox(width: 8),
                Text(
                  'Preferred Styles',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            Text(
              'Multi-select',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _styleOptions.map((style) {
            final isSelected = _preferredStyles.contains(style.id);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    if (_preferredStyles.length > 1) {
                      _preferredStyles.remove(style.id);
                    }
                  } else {
                    _preferredStyles.add(style.id);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF005953) : const Color(0xFFF1F4FA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      style.icon,
                      size: 16,
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      style.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── 9. Available Equipment ─────────────────────────────────────────────────
  Widget _buildAvailableEquipmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.business_center_outlined, color: Color(0xFF006257), size: 19),
                const SizedBox(width: 8),
                Text(
                  'Available Equipment',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            Text(
              'At Home',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: _equipmentList.map((item) {
            final isSelected = _equipment.contains(item.id);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _equipment.remove(item.id);
                    } else {
                      _equipment.add(item.id);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE7F6F3) : const Color(0xFFF3F5FA),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFCEEEE6) : const Color(0xFFE2E7F0),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            item.icon,
                            color: isSelected ? const Color(0xFF00635A) : const Color(0xFF475569),
                            size: 19,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 1.5),
                            Text(
                              item.subtitle,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF005953) : const Color(0xFFD9E2EC),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── 10. Save Preferences Button ────────────────────────────────────────────
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _onSavePreferences,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF005953),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Save Preferences',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
      ),
    );
  }

  // ── Logout Button & Confirmation ───────────────────────────────────────────
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: _showLogoutConfirmationDialog,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFDC2626),
          side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          backgroundColor: const Color(0xFFFEF2F2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 18),
            const SizedBox(width: 8),
            Text(
              'Log Out',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFDC2626),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Log Out',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to log out from FitOn?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.signOut();
              if (!mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.auth,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Log Out',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 11. Footer Notice ──────────────────────────────────────────────────────
  Widget _buildFooterNotice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.info_outline_rounded, color: Color(0xFF94A3B8), size: 14),
        const SizedBox(width: 6),
        Text(
          'You can adjust these settings anytime',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

// ── Models & Helper Data ─────────────────────────────────────────────────────

class _GoalOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  const _GoalOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _DayItem {
  final String id;
  final String label;
  final String dayName;

  const _DayItem({
    required this.id,
    required this.label,
    required this.dayName,
  });
}

class _StyleItem {
  final String id;
  final String label;
  final IconData icon;

  const _StyleItem({
    required this.id,
    required this.label,
    required this.icon,
  });
}

class _EquipmentItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  const _EquipmentItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
