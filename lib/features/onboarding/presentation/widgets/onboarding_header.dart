import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/fiton_logo.dart';

/// Top header bar for the Welcome Onboarding screen:
/// - FitOn logo & app name on the left
/// - "Newbie Friendly" status pill badge on the right
class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Brand logo and name
        const FitOnBrandHeader(iconSize: 36),

        // "Newbie Friendly" pill badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBadgeBgBlue : AppColors.badgeBgBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Green active dot
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.onlineGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                AppStrings.newbieFriendlyBadge,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkBadgeTextBlue : AppColors.badgeTextBlue,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
