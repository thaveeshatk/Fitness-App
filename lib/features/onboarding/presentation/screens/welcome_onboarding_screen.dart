import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/primary_pill_button.dart';
import '../widgets/hero_preview_card.dart';
import '../widgets/onboarding_feature_card.dart';
import '../widgets/onboarding_header.dart';

/// Screen 2: Welcome Onboarding Screen
/// Faithfully converts Wireframe 2 into a clean, modern Flutter implementation:
/// - Brand header with "Newbie Friendly" badge
/// - Cozy home workout hero image with community social proof banner
/// - Headlines: "Start Your Fitness Journey"
/// - 3 Feature value proposition cards
/// - "Get Started ->" bottom pill CTA
/// - Quick setup time indicator footer
class WelcomeOnboardingScreen extends StatelessWidget {
  const WelcomeOnboardingScreen({super.key});

  void _onGetStartedPressed(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.auth, arguments: true);
  }

  void _onLogInPressed(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.auth, arguments: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top App Bar / Brand Header
              const OnboardingHeader(),

              const SizedBox(height: 18),

              // Hero Preview Card with Floating Community Stat
              const HeroPreviewCard(),

              const SizedBox(height: 22),

              // Main Headlines
              Text(
                AppStrings.onboardingTitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.15,
                  letterSpacing: -0.8,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                AppStrings.onboardingSubtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  letterSpacing: -0.2,
                ),
              ),

              const SizedBox(height: 20),

              // Feature Card 1: Personalized workouts
              const OnboardingFeatureCard(
                icon: Icons.tune_rounded,
                iconBgColor: AppColors.featureTealBg,
                iconColor: AppColors.featureTealIcon,
                title: AppStrings.feature1Title,
                subtitle: AppStrings.feature1Subtitle,
              ),

              const SizedBox(height: 12),

              // Feature Card 2: Beginner-friendly exercises
              const OnboardingFeatureCard(
                icon: Icons.self_improvement_rounded,
                iconBgColor: AppColors.featureGreenBg,
                iconColor: AppColors.featureGreenIcon,
                title: AppStrings.feature2Title,
                subtitle: AppStrings.feature2Subtitle,
              ),

              const SizedBox(height: 12),

              // Feature Card 3: Simple fitness planning
              const OnboardingFeatureCard(
                icon: Icons.calendar_month_rounded,
                iconBgColor: AppColors.featurePeachBg,
                iconColor: AppColors.featurePeachIcon,
                title: AppStrings.feature3Title,
                subtitle: AppStrings.feature3Subtitle,
              ),

              const SizedBox(height: 24),

              // Action CTA: Get Started ->
              PrimaryPillButton(
                label: AppStrings.getStartedButton,
                onPressed: () => _onGetStartedPressed(context),
              ),

              const SizedBox(height: 12),

              // Alternative: Already have an account? Log In
              Center(
                child: TextButton(
                  onPressed: () => _onLogInPressed(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: 'Log In',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Footer Note: Setup in less than a minute
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: AppColors.primaryTeal,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppStrings.timeCommitmentFooter,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
