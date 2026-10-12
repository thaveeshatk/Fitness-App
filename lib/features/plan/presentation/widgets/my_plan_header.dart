import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/core/widgets/fiton_logo.dart';
import 'package:fitness_app/core/widgets/user_avatar.dart';
import 'package:fitness_app/features/notifications/presentation/widgets/notification_bell.dart';

/// Top App Bar / Brand Header for the "My Plan" screen.
/// Matches the wireframe header:
/// - FitOn orange-red brand square logo badge ("F.")
/// - "My Plan" bold title
/// - Notification bell with badge dot
/// - User profile circular avatar with interactive navigation connection
class MyPlanHeader extends StatelessWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;

  const MyPlanHeader({
    super.key,
    this.onProfileTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: FitOn Brand Logo Badge + "My Plan"
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FitOnLogoBadge(
                  size: 34,
                  borderRadius: 10,
                  showAccentMark: false,
                ),
                const SizedBox(width: 12),
                Text(
                  'My Plan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),

            // Right: Notification Bell + User Profile Avatar
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Notification Bell with badge dot
                NotificationBell(
                  size: 36,
                  iconSize: 24,
                  onTap: onNotificationTap,
                ),

                const SizedBox(width: 8),

                // User Profile Avatar
                UserAvatar(
                  radius: 16,
                  onTap: onProfileTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
