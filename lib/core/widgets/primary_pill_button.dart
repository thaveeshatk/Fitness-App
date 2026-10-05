import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Reusable full-width pill button matching the wireframe designs:
/// - Dark teal rounded stadium shape
/// - White text with right-pointing arrow
/// - Smooth elevation and subtle glow shadow
class PrimaryPillButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool showArrow;
  final double height;

  const PrimaryPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.showArrow = true,
    this.height = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.buttonGlowColor,
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: AppColors.primaryTeal,
        borderRadius: BorderRadius.circular(height / 2),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(height / 2),
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhite,
                    letterSpacing: -0.2,
                  ),
                ),
                if (showArrow) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.textWhite,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
