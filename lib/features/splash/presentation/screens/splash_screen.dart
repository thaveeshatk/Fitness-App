import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/fiton_logo.dart';
import '../../../../core/widgets/primary_pill_button.dart';

/// Screen 1: Intro / Splash Screen
/// Faithfully converts Wireframe 1 into a clean, modern Flutter implementation:
/// - Soft subtle background gradient with glow
/// - FitOn logo badge with decorative accent mark
/// - Centered brand title, headline, and subtitle
/// - Bottom "Next ->" pill action button
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _onNextPressed(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: Stack(
        children: [
          // Subtle radial glow behind the center brand element
          Positioned(
            top: size.height * 0.28,
            left: size.width * 0.1,
            right: size.width * 0.1,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    isDark
                        ? const Color(0xFF0F766E).withValues(alpha: 0.25)
                        : const Color(0xFFC8F3EA).withValues(alpha: 0.55),
                    isDark
                        ? const Color(0xFF1E293B).withValues(alpha: 0.15)
                        : const Color(0xFFE0F2FE).withValues(alpha: 0.35),
                    context.scaffoldBg.withValues(alpha: 0.0),
                  ],
                  radius: 0.85,
                ),
              ),
            ),
          ),

          // Main Screen Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Center Branding & Logo
                  const FitOnLogoBadge(
                    size: 88,
                    borderRadius: 24,
                    showAccentMark: true,
                  ),

                  const SizedBox(height: 28),

                  // App Name
                  Text(
                    AppStrings.appName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: context.textPrimary,
                      letterSpacing: -0.6,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Headline
                  Text(
                    AppStrings.splashHeadline,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  // Subtitle
                  Text(
                    AppStrings.splashSubtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w400,
                      color: context.textSecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(flex: 4),

                  // Bottom Action Button: Next ->
                  PrimaryPillButton(
                    label: AppStrings.nextButton,
                    onPressed: () => _onNextPressed(context),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
