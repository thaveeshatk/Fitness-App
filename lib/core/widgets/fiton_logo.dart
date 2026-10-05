import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

/// Custom FitOn Logo Badge conforming to the wireframe branding:
/// - Rounded orange-red container
/// - Crisp stylized "F." typography
/// - Optional top-right teal accent mark
class FitOnLogoBadge extends StatelessWidget {
  final double size;
  final double borderRadius;
  final bool showAccentMark;

  const FitOnLogoBadge({
    super.key,
    this.size = 80.0,
    this.borderRadius = 22.0,
    this.showAccentMark = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.logoOrange,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.logoOrange.withValues(alpha: 0.28),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: Center(
        child: RichText(
          text: TextSpan(
            text: 'F',
            style: GoogleFonts.outfit(
              fontSize: size * 0.52,
              fontWeight: FontWeight.w800,
              color: AppColors.textWhite,
              letterSpacing: -1,
            ),
            children: [
              TextSpan(
                text: '.',
                style: GoogleFonts.outfit(
                  fontSize: size * 0.52,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!showAccentMark) {
      return iconWidget;
    }

    // When showAccentMark is true (Splash screen wireframe detail)
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Outer soft halo/card background container
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius + 8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: const Color(0xFF5EEAD4).withValues(alpha: 0.18),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: iconWidget,
        ),
        // Decorative tiny teal chevron mark at top-right
        Positioned(
          top: 6,
          right: -10,
          child: Transform.rotate(
            angle: -0.2,
            child: const Icon(
              Icons.chevron_left_rounded,
              color: AppColors.primaryTeal,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

/// Logo + Brand Text row for app bars / headers
class FitOnBrandHeader extends StatelessWidget {
  final double iconSize;

  const FitOnBrandHeader({
    super.key,
    this.iconSize = 34.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FitOnLogoBadge(
          size: iconSize,
          borderRadius: 10.0,
          showAccentMark: false,
        ),
        const SizedBox(width: 10),
        Text(
          AppStrings.appName,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}
