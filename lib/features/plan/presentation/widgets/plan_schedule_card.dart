import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/features/plan/data/models/plan_schedule_item.dart';

/// Card representing a single session in the Weekly Schedule list.
/// Renders identically to the wireframe for:
/// - Completed sessions (Checkmark badge, MON 13, arrow button)
/// - Today • Ready sessions (Teal highlight, WED 15, play button, and bottom advice bar)
/// - Upcoming sessions (Lock badge, FRI 17, Upcoming pill)
class PlanScheduleCard extends StatelessWidget {
  final PlanScheduleItem item;
  final VoidCallback onTap;
  final VoidCallback? onPlayTap;

  const PlanScheduleCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    if (item.isTodayReady) {
      return _buildTodayCard(context);
    }
    return _buildStandardCard(context);
  }

  // ── Today • Ready Active Card ─────────────────────────────────────────────
  Widget _buildTodayCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDF2F7), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005953).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Prominent dark teal top accent border line
            Container(
              height: 4,
              width: double.infinity,
              color: const Color(0xFF005953),
            ),

            // Main Card Content
            InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Teal Date Box
                        _buildDateBox(
                          day: item.dayLabel,
                          date: item.dayNumber.toString(),
                          isHighlight: true,
                        ),

                        const SizedBox(width: 12),

                        // Thumbnail
                        _buildThumbnail(
                          imageUrl: item.imageUrl,
                          showPlayOverlay: true,
                        ),

                        const SizedBox(width: 12),

                        // Title & Metadata
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status Pill
                              _buildPill(
                                label: '• Today • Ready',
                                bgColor: const Color(0xFFB8F3DE),
                                textColor: const Color(0xFF005953),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                item.title,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 4),

                              Text(
                                item.metaText,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Large Teal Circular Play Button
                        GestureDetector(
                          onTap: onPlayTap ?? onTap,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF005953),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF005953).withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Bottom Advice Banner ("Gentle on knees • High calorie burn", "READY")
                    if (item.adviceHighlight != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F7FD),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline_rounded,
                              size: 16,
                              color: Color(0xFF006257),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.adviceHighlight!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF334155),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (item.readyBadgeText != null)
                              Text(
                                item.readyBadgeText!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF005953),
                                  letterSpacing: 0.5,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Standard Card (Completed or Upcoming) ──────────────────────────────────
  Widget _buildStandardCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDF2F7), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Date Box
                _buildDateBox(
                  day: item.dayLabel,
                  date: item.dayNumber.toString(),
                  isHighlight: false,
                ),

                const SizedBox(width: 12),

                // Thumbnail with Checkmark or clean
                _buildThumbnail(
                  imageUrl: item.imageUrl,
                  showCheckmark: item.isCompleted,
                ),

                const SizedBox(width: 12),

                // Title & Metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.isCompleted)
                        _buildPill(
                          label: 'Completed',
                          bgColor: const Color(0xFFBAF3D9),
                          textColor: const Color(0xFF047857),
                          icon: Icons.check_circle_rounded,
                        )
                      else
                        _buildPill(
                          label: 'Upcoming',
                          bgColor: const Color(0xFFE2EBF8),
                          textColor: const Color(0xFF3B679B),
                        ),

                      const SizedBox(height: 5),

                      Text(
                        item.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      Text(
                        item.metaText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Right Action Icon (Chevron or Lock)
                if (item.isCompleted)
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF475569),
                      size: 20,
                    ),
                  )
                else
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xFF94A3B8),
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Sub-components ────────────────────────────────────────────────────────

  Widget _buildDateBox({
    required String day,
    required String date,
    required bool isHighlight,
  }) {
    return Container(
      width: 54,
      height: 58,
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFF005953) : const Color(0xFFEFF5FB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isHighlight ? const Color(0xFFC4F2E4) : const Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            date,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: isHighlight ? Colors.white : const Color(0xFF0F172A),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail({
    required String imageUrl,
    bool showCheckmark = false,
    bool showPlayOverlay = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            imageUrl,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 56,
              height: 56,
              color: const Color(0xFFE2E8F0),
              child: const Icon(Icons.fitness_center_rounded, color: Color(0xFF94A3B8)),
            ),
          ),
          if (showCheckmark)
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF00875A),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          if (showPlayOverlay)
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 15,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required String label,
    required Color bgColor,
    required Color textColor,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
