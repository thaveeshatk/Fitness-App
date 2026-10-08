import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../workouts/data/models/workout_session.dart';
import '../../../workouts/data/services/workout_log_service.dart';
import 'goals_screen.dart';

// ── Data model for a single workout history entry ────────────────────────────
class WorkoutHistoryEntry {
  final String date;
  final String title;
  final String duration;
  final String kcal;
  final String category; // 'Strength' | 'Cardio' | 'Mobility' | 'Recovery'
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
    this.isRest = false,
    this.restIcon,
    this.restIconColor,
    this.restIconBg,
  });
}

// ── Screen ───────────────────────────────────────────────────────────────────
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const Color _primaryTeal = Color(0xFF00635A);
  static const Color _mintGreen = Color(0xFF00D18D);
  static const Color _mintGreenTint = Color(0xFFE6FAF3);
  static const Color _darkTeal = Color(0xFF0A4D4E);

  static const _days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  static const _months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];

  String _selectedFilter = 'All';

  String _formatSessionDate(DateTime dt) {
    final dayName = _days[dt.weekday - 1];
    final monthName = _months[dt.month - 1];
    return '$dayName, ${dt.day} $monthName';
  }

  bool _matchesCategory(String sessionCategory, String filter) {
    if (filter == 'All') return true;
    final cat = sessionCategory.toLowerCase();
    final f = filter.toLowerCase();
    if (f == 'cardio') {
      return cat.contains('cardio') || cat.contains('hiit') || cat.contains('run');
    }
    if (f == 'mobility') {
      return cat.contains('mobility') || cat.contains('yoga') || cat.contains('stretch') || cat.contains('flex');
    }
    if (f == 'strength') {
      return cat.contains('strength') || cat.contains('power') || cat.contains('body') || cat.contains('core');
    }
    return cat == f;
  }

  List<WorkoutHistoryEntry> _getFilteredEntries(List<WorkoutSession> sessions) {
    final filtered = sessions.where((s) => _matchesCategory(s.category, _selectedFilter));
    return filtered.map((s) {
      return WorkoutHistoryEntry(
        date: _formatSessionDate(s.endTime),
        title: s.title,
        duration: '${s.durationMinutes} min',
        kcal: '${s.calories} kcal',
        category: s.category,
      );
    }).toList();
  }

  // Category → accent colour mapping
  Color _categoryColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('strength')) return const Color(0xFF6366F1); // indigo
    if (cat.contains('cardio') || cat.contains('hiit')) return const Color(0xFFEF4444); // red-orange
    if (cat.contains('mobility') || cat.contains('yoga')) return const Color(0xFF10B981); // emerald
    if (cat.contains('recovery')) return const Color(0xFF8B5CF6); // violet
    return _primaryTeal;
  }

  Color _categoryBg(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('strength')) return const Color(0xFFEEF2FF);
    if (cat.contains('cardio') || cat.contains('hiit')) return const Color(0xFFFEE2E2);
    if (cat.contains('mobility') || cat.contains('yoga')) return const Color(0xFFD1FAE5);
    if (cat.contains('recovery')) return const Color(0xFFEDE9FE);
    return _mintGreenTint;
  }

  IconData _categoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('strength')) return Icons.fitness_center_rounded;
    if (cat.contains('cardio') || cat.contains('hiit')) return Icons.directions_run_rounded;
    if (cat.contains('mobility') || cat.contains('yoga')) return Icons.self_improvement_rounded;
    if (cat.contains('recovery')) return Icons.spa_rounded;
    return Icons.sports_gymnastics_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: WorkoutLogService.instance,
      builder: (context, _) {
        final allSessions = WorkoutLogService.instance.sessions;
        final filteredEntries = _getFilteredEntries(allSessions);

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
                        _buildBanner(context, allSessions),
                        const SizedBox(height: 24),
                        _buildFilters(allSessions),
                        const SizedBox(height: 20),
                        _buildHistoryList(filteredEntries),
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
              ],
            ),
          ),
        );
      },
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
          child: const Icon(Icons.notifications_none_rounded, size: 20, color: Color(0xFF475569)),
        ),
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

  Widget _buildBanner(BuildContext context, List<WorkoutSession> sessions) {
    final totalCount = sessions.length;
    final totalMinutes = sessions.fold(0, (sum, s) => sum + s.durationMinutes);
    final monthName = _months[DateTime.now().month - 1];

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GoalsScreen()));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _mintGreenTint,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _mintGreen.withOpacity(0.3)),
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
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 10, color: _primaryTeal),
                        const SizedBox(width: 4),
                        Text(
                          '$monthName ROUTINE',
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
                    totalCount == 1 ? '1 workout completed' : '$totalCount workouts completed',
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
                        '$totalMinutes active mins\nlogged',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _primaryTeal,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(width: 1, height: 24, color: _primaryTeal.withOpacity(0.2)),
                      const SizedBox(width: 16),
                      const Icon(Icons.trending_up_rounded, size: 14, color: _primaryTeal),
                      const SizedBox(width: 4),
                      Text(
                        totalCount > 0 ? 'Steady\nmomentum' : 'Start your\njourney',
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
                  BoxShadow(color: _mintGreen.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.check_rounded, color: _mintGreen, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(List<WorkoutSession> sessions) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _filterPill('All', Icons.grid_view_rounded, sessions),
          const SizedBox(width: 10),
          _filterPill('Strength', Icons.fitness_center_rounded, sessions),
          const SizedBox(width: 10),
          _filterPill('Cardio', Icons.directions_run_rounded, sessions),
          const SizedBox(width: 10),
          _filterPill('Mobility', Icons.self_improvement_rounded, sessions),
        ],
      ),
    );
  }

  Widget _filterPill(String title, IconData icon, List<WorkoutSession> sessions) {
    final isSelected = _selectedFilter == title;
    // Count matching items for the badge
    final count = title == 'All'
        ? sessions.length
        : sessions.where((w) => _matchesCategory(w.category, title)).length;

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
              ? [BoxShadow(color: _primaryTeal.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))]
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
                color: isSelected ? Colors.white.withOpacity(0.25) : const Color(0xFFF1F5F9),
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
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded, size: 34, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Text(
            'No $_selectedFilter sessions yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Complete a $_selectedFilter workout to\nsee it logged here.',
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
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
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
                          Image.asset(
                            AssetPaths.heroWorkout,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 64,
                              height: 64,
                              color: accentBg,
                              child: Center(child: Icon(icon, color: accentColor, size: 28)),
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
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
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(Icons.chevron_right_rounded, color: AppColors.cardBorder, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
