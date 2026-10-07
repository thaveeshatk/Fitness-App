import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/features/plan/data/models/plan_schedule_item.dart';

/// Modal bottom sheet showing the complete weekly calendar & schedule overview.
/// Triggered when the user taps "View Weekly Schedule".
class WeeklyScheduleSheet extends StatelessWidget {
  final List<PlanScheduleItem> items;
  final Function(PlanScheduleItem) onSelectWorkout;

  const WeeklyScheduleSheet({
    super.key,
    required this.items,
    required this.onSelectWorkout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 28, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Schedule',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Nov 13 – Nov 19 • 5 Days Active',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Days Breakdown List
            ...items.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: item.isTodayReady
                      ? const Color(0xFFF0FDF8)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: item.isTodayReady
                        ? const Color(0xFF005953).withValues(alpha: 0.3)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    // Day Circle Badge
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: item.isTodayReady
                            ? const Color(0xFF005953)
                            : (item.isCompleted
                                ? const Color(0xFFC6F6D5)
                                : const Color(0xFFE2E8F0)),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: item.isCompleted
                            ? const Icon(Icons.check_rounded, color: Color(0xFF047857), size: 18)
                            : Text(
                                item.dayLabel.substring(0, 1),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: item.isTodayReady
                                      ? Colors.white
                                      : const Color(0xFF334155),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.dayLabel} ${item.dayNumber} • ${item.title}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.metaText,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status Pill
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        backgroundColor: const Color(0xFF005953).withValues(alpha: 0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onSelectWorkout(item);
                      },
                      child: Text(
                        'View',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF005953),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
