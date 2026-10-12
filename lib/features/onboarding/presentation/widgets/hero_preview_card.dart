import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/asset_paths.dart';

/// Hero workout preview card with bottom floating community social proof banner.
/// Conforms precisely to Wireframe 2.
class HeroPreviewCard extends StatelessWidget {
  const HeroPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Hero Image
            Image.asset(
              AssetPaths.heroWorkout,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Graceful fallback container with soft home gym tones if asset is loading
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE2D9D2), Color(0xFFC7B8AA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.fitness_center_rounded,
                      size: 48,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                );
              },
            ),

            // Bottom Floating Community Pill
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF3F4F6))
                      .withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Overlapping Avatar Circles
                    const _OverlappingAvatars(),

                    const SizedBox(width: 10),

                    // Community Stat Copy
                    Expanded(
                      child: Text(
                        AppStrings.communityStat,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : AppColors.textPrimary,
                          height: 1.25,
                        ),
                      ),
                    ),

                    // Teal Heart Icon
                    const Icon(
                      Icons.favorite_rounded,
                      color: AppColors.primaryTeal,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Three overlapping user avatars: JD (Red), MK (Teal), SL (Beige)
class _OverlappingAvatars extends StatelessWidget {
  const _OverlappingAvatars();

  @override
  Widget build(BuildContext context) {
    const avatarSize = 30.0;
    const overlapOffset = 20.0;

    return const SizedBox(
      width: overlapOffset * 2 + avatarSize,
      height: avatarSize,
      child: Stack(
        children: [
          // Avatar 1: JD (Red)
          Positioned(
            left: 0,
            child: _AvatarCircle(
              text: 'JD',
              bgColor: AppColors.avatarRed,
              textColor: AppColors.textWhite,
              size: avatarSize,
            ),
          ),
          // Avatar 2: MK (Teal)
          Positioned(
            left: overlapOffset,
            child: _AvatarCircle(
              text: 'MK',
              bgColor: AppColors.avatarTeal,
              textColor: AppColors.textWhite,
              size: avatarSize,
            ),
          ),
          // Avatar 3: SL (Beige/Sand)
          Positioned(
            left: overlapOffset * 2,
            child: _AvatarCircle(
              text: 'SL',
              bgColor: AppColors.avatarSand,
              textColor: AppColors.avatarSandText,
              size: avatarSize,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;
  final double size;

  const _AvatarCircle({
    required this.text,
    required this.bgColor,
    required this.textColor,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E293B)
              : Colors.white,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
