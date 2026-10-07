import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/core/widgets/fiton_logo.dart';

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
      color: Colors.white,
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
                InkWell(
                  onTap: onNotificationTap ??
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'You have 1 workout scheduled for today!',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF005953),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.notifications_none_rounded,
                          color: Color(0xFF334155),
                          size: 24,
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.logoOrange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // User Profile Avatar
                GestureDetector(
                  onTap: onProfileTap,
                  child: Container(
                    padding: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFCBD5E1),
                        width: 1.5,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFFE2E8F0),
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=150&auto=format&fit=crop',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
