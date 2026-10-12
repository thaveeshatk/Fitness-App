import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Hero Progress Card: "YOUR WEEKLY PLAN"
/// Replicates the wireframe hero card with progress bar, streak flame chip,
/// completion fraction, and motivational subtitle.
class PlanHeroProgressCard extends StatelessWidget {
  final int completedSessions;
  final int totalSessions;
  final String motivationalSubtitle;

  const PlanHeroProgressCard({
    super.key,
    required this.completedSessions,
    required this.totalSessions,
    this.motivationalSubtitle = "You're on track! Keep up the great work.",
  });

  @override
  Widget build(BuildContext context) {
    final fraction = totalSessions > 0
        ? (completedSessions / totalSessions).clamp(0.0, 1.0)
        : 0.0;
    final percentInt = (fraction * 100).round();
    final remaining = (totalSessions - completedSessions).clamp(0, totalSessions);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF4FA),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: "YOUR WEEKLY PLAN" + Flame Icon Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'YOUR WEEKLY PLAN',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F3E37) : const Color(0xFFC4F2E4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF005953),
                  size: 22,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Main Heading: "3 of 5 completed"
          Text(
            '$completedSessions of $totalSessions completed',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 4),

          // Subtitle: "You're on track! Keep up the great work."
          Text(
            motivationalSubtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
            ),
          ),

          const SizedBox(height: 18),

          // Rounded Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 9,
              width: double.infinity,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: fraction,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF005953),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Bottom Stats Row: "60% completed" and "2 sessions to go"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$percentInt% completed',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                ),
              ),
              Text(
                '$remaining sessions to go',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF005953),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
