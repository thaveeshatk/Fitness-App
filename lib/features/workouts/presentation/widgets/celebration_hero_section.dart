import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

/// Reusable celebration hero header for workout completion screen.
/// Matches Figma design with peach background glow, teal check badge,
/// session finished pill, and centered header text.
class CelebrationHeroSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badgeText;

  const CelebrationHeroSection({
    super.key,
    this.title = 'Workout Complete!',
    this.subtitle = 'Great Work! Every session builds lifelong\nconsistency.',
    this.badgeText = 'SESSION FINISHED',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 6),
        // Hero Checkmark Badge with Peach Halo and Top-Right Award Star
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Soft peach outer circular halo
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.isDark ? const Color(0xFF382A24) : const Color(0xFFFBE8D8),
                shape: BoxShape.circle,
              ),
            ),
            // Primary teal circle
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.primaryTeal,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryTeal.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
            // Top-right award badge
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFFF6A65D),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // SESSION FINISHED Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.featureTealBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primaryTeal,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                badgeText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryTeal,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Main Heading
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),

        // Subtitle
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
