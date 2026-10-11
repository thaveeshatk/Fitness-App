import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import 'goals_screen.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../data/services/user_activity_service.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../profile/presentation/screens/profile_preferences_screen.dart';
import '../../../workouts/data/repositories/workout_repository.dart';

// ── Data model for a single workout history entry ────────────────────────────
class WorkoutHistoryEntry {
  final String date;
  final String title;
  final String duration;
  final String kcal;
  final String category; // 'Strength' | 'Cardio' | 'Mobility' | 'Recovery'
  final String? imageUrl;
  final bool isRest;
  final IconData? restIcon;
  final Color? restIconColor;
  final Color? restIconBg;

  const WorkoutHistoryEntry({
    required this.date,
    required this.title,
    required this.duration,
    required this.kcal,
    required this.category,
    this.imageUrl,
    this.isRest = false,
    this.restIcon,
    this.restIconColor,
    this.restIconBg,
  });
}

// ── Screen ───────────────────────────────────────────────────────────────────
class HistoryScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const HistoryScreen({super.key, this.onNavigateToTab});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const Color _primaryTeal = Color(0xFF00635A);
  static const Color _mintGreen = Color(0xFF00D18D);
  static const Color _mintGreenTint = Color(0xFFE6FAF3);
  static const Color _darkTeal = Color(0xFF0A4D4E);

  String _selectedFilter = 'All';
  List<WorkoutHistoryEntry> _userWorkouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    AuthService.userNotifier.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    AuthService.userNotifier.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) _loadHistory();
  }

  Future<void> _loadHistory() async {
    final activities = await UserActivityService.getAllActivities();
    final systemWorkouts = WorkoutRepository.getMockWorkouts();

    final entries = activities.map((act) {
      final isoDate = act['completedAt']?.toString();
      final title = act['workoutTitle']?.toString() ?? 'Workout Session';
      final workoutId = act['workoutId']?.toString();

      // Resolve matching workout image from act record or system workouts library
      String? resolvedImageUrl = act['imageUrl']?.toString();
      if (resolvedImageUrl == null || resolvedImageUrl.isEmpty) {
        final match = systemWorkouts.where(
          (w) => (workoutId != null && w.id == workoutId) || w.title.toLowerCase() == title.toLowerCase(),
        ).firstOrNull;
        resolvedImageUrl = match?.imageUrl;
      }

      return WorkoutHistoryEntry(
        date: _formatWorkoutDate(isoDate),
        title: title,
        duration: '${act['durationMinutes'] ?? 20} min',
        kcal: '${act['calories'] ?? 150} kcal',
        category: act['category']?.toString() ?? 'Strength',
        imageUrl: resolvedImageUrl,
      );
    }).toList();

    if (mounted) {
      setState(() {
        _userWorkouts = entries;
        _isLoading = false;
      });
    }
  }

  String _formatWorkoutDate(String? isoString) {
    if (isoString == null) return 'RECENT';
    final dt = DateTime.tryParse(isoString);
    if (dt == null) return 'RECENT';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDay = DateTime(dt.year, dt.month, dt.day);
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    const weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final mStr = months[dt.month - 1];
    final dStr = dt.day.toString();
    if (itemDay == today) {
      return 'TODAY, $dStr $mStr';
    } else if (itemDay == today.subtract(const Duration(days: 1))) {
      return 'YESTERDAY, $dStr $mStr';
    } else {
      final wStr = weekdays[dt.weekday - 1];
      return '$wStr, $dStr $mStr';
    }
  }

  List<WorkoutHistoryEntry> get _filteredWorkouts {
    if (_selectedFilter == 'All') return _userWorkouts;
    return _userWorkouts
        .where((w) => w.category.toLowerCase() == _selectedFilter.toLowerCase())
        .toList();
  }

  // Category → accent colour mapping
  Color _categoryColor(String category) {
    switch (category) {
      case 'Strength':
        return const Color(0xFF6366F1); // indigo
      case 'Cardio':
        return const Color(0xFFEF4444); // red-orange
      case 'Mobility':
        return const Color(0xFF10B981); // emerald
      case 'Recovery':
        return const Color(0xFF8B5CF6); // violet
      default:
        return _primaryTeal;
    }
  }

  Color _categoryBg(String category) {
    switch (category) {
      case 'Strength':
        return const Color(0xFFEEF2FF);
      case 'Cardio':
        return const Color(0xFFFEE2E2);
      case 'Mobility':
        return const Color(0xFFD1FAE5);
      case 'Recovery':
        return const Color(0xFFEDE9FE);
      default:
        return _mintGreenTint;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Strength':
        return Icons.fitness_center_rounded;
      case 'Cardio':
        return Icons.directions_run_rounded;
      case 'Mobility':
        return Icons.self_improvement_rounded;
      case 'Recovery':
        return Icons.spa_rounded;
      default:
        return Icons.sports_gymnastics_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredWorkouts;

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
                color: _primaryTeal,
                onRefresh: _loadHistory,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildBanner(context),
                      const SizedBox(height: 24),
                      _buildFilters(),
                      const SizedBox(height: 20),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: CircularProgressIndicator(color: _primaryTeal)),
                        )
                      else
                        _buildHistoryList(filtered),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'Consistency beats intensity. Every session counts!',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'History',
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
            color: Colors.white,
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
          border: Border.all(color: _mintGreen, width: 1.5),
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

  Widget _buildBanner(BuildContext context) {
    final totalMins = _userWorkouts.fold<int>(
      0,
      (s, w) => s + (int.tryParse(w.duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0),
    );
    final totalCalories = _userWorkouts.fold<int>(
      0,
      (s, w) => s + (int.tryParse(w.kcal.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0),
    );

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GoalsScreen(
              onNavigateToTab: widget.onNavigateToTab,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _mintGreenTint,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _mintGreen.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 10, color: _primaryTeal),
                        const SizedBox(width: 4),
                        Text(
                          'ACTIVE TRAINING HISTORY',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: _primaryTeal,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_userWorkouts.length} workouts completed',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _darkTeal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: _primaryTeal),
                      const SizedBox(width: 4),
                      Text(
                        '$totalMins active mins\nlogged',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _primaryTeal,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(width: 1, height: 24, color: _primaryTeal.withValues(alpha: 0.2)),
                      const SizedBox(width: 16),
                      const Icon(Icons.local_fire_department_rounded, size: 14, color: Color(0xFFEF4444)),
                      const SizedBox(width: 4),
                      Text(
                        '$totalCalories kcal\nburned',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _primaryTeal,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: _mintGreen.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.check_rounded, color: _mintGreen, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _filterPill('All', Icons.grid_view_rounded),
          const SizedBox(width: 10),
          _filterPill('Strength', Icons.fitness_center_rounded),
          const SizedBox(width: 10),
          _filterPill('Cardio', Icons.directions_run_rounded),
          const SizedBox(width: 10),
          _filterPill('Mobility', Icons.self_improvement_rounded),
        ],
      ),
    );
  }

  Widget _filterPill(String title, IconData icon) {
    final isSelected = _selectedFilter.toLowerCase() == title.toLowerCase();
    // Count matching items for the badge
    final count = title == 'All'
        ? _userWorkouts.length
        : _userWorkouts.where((w) => w.category.toLowerCase() == title.toLowerCase()).length;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedFilter = title);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _primaryTeal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? _primaryTeal : AppColors.cardBorder),
          boxShadow: isSelected
              ? [BoxShadow(color: _primaryTeal.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))]
              : [],
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(List<WorkoutHistoryEntry> items) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }
    return Column(
      children: items.asMap().entries.map((e) {
        return Padding(
          padding: EdgeInsets.only(bottom: e.key < items.length - 1 ? 12 : 0),
          child: _historyCard(e.value),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded, size: 34, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'All'
                ? 'No workouts completed yet'
                : 'No $_selectedFilter sessions yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _selectedFilter == 'All'
                ? 'Complete your first workout to see your detailed training history here.'
                : 'Complete a $_selectedFilter workout to see it logged here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(WorkoutHistoryEntry entry) {
    final accentColor = _categoryColor(entry.category);
    final accentBg = _categoryBg(entry.category);
    final icon = _categoryIcon(entry.category);

    return IntrinsicHeight(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left coloured category stripe
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            // Icon/image thumbnail
            Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: entry.isRest
                    ? Container(
                        width: 64,
                        height: 64,
                        color: accentBg,
                        child: Center(child: Icon(icon, color: accentColor, size: 28)),
                      )
                    : Stack(
                        children: [
                          _buildWorkoutThumbnail(entry, accentBg, icon, accentColor),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                              ),
                              child: Icon(icon, size: 10, color: accentColor),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            // Text content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.date,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                            letterSpacing: 0.4,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: entry.isRest ? accentBg : _mintGreenTint,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  entry.isRest ? Icons.hotel_rounded : Icons.check_circle_rounded,
                                  size: 10,
                                  color: entry.isRest ? accentColor : _primaryTeal,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  entry.isRest ? 'Rest Day' : 'Completed',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: entry.isRest ? accentColor : _primaryTeal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      entry.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            entry.category,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer_outlined, size: 12, color: AppColors.textSecondary),
                            const SizedBox(width: 3),
                            Text(entry.duration,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department_outlined, size: 12, color: AppColors.textSecondary),
                            const SizedBox(width: 3),
                            Text(entry.kcal,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Chevron
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.chevron_right_rounded, color: AppColors.cardBorder, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutThumbnail(
    WorkoutHistoryEntry entry,
    Color fallbackBg,
    IconData fallbackIcon,
    Color fallbackColor,
  ) {
    final imgUrl = entry.imageUrl;
    if (imgUrl != null && imgUrl.isNotEmpty) {
      if (imgUrl.startsWith('http')) {
        return Image.network(
          imgUrl,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 64,
            height: 64,
            color: fallbackBg,
            child: Center(child: Icon(fallbackIcon, color: fallbackColor, size: 28)),
          ),
        );
      } else {
        return Image.asset(
          imgUrl,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 64,
            height: 64,
            color: fallbackBg,
            child: Center(child: Icon(fallbackIcon, color: fallbackColor, size: 28)),
          ),
        );
      }
    }

    return Container(
      width: 64,
      height: 64,
      color: fallbackBg,
      child: Center(child: Icon(fallbackIcon, color: fallbackColor, size: 28)),
    );
  }
}
