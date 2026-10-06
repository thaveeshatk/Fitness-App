import 'package:flutter/material.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_onboarding_screen.dart';
import '../../features/profile/presentation/screens/profile_setup_screen.dart';
import '../../features/profile/presentation/screens/main_navigation_screen.dart';
import '../../features/profile/presentation/screens/profile_preferences_screen.dart';

/// App navigation routes definition and route generator
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String profileSetup = '/profile-setup';
  static const String mainNav = '/main-nav';
  static const String profilePreferences = '/profile-preferences';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case welcome:
        return PageRouteBuilder(
          pageBuilder: (_, animation, secondaryAnimation) =>
              const WelcomeOnboardingScreen(),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.06, 0),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
          settings: settings,
        );

      case profileSetup:
        return PageRouteBuilder(
          pageBuilder: (_, animation, secondaryAnimation) =>
              const ProfileSetupScreen(),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.06, 0),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
          settings: settings,
        );

      case mainNav:
        return PageRouteBuilder(
          pageBuilder: (_, animation, secondaryAnimation) =>
              const MainNavigationScreen(initialIndex: 4),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.06, 0),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
          settings: settings,
        );

      case profilePreferences:
        return MaterialPageRoute(
          builder: (_) => const ProfilePreferencesScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
    }
  }
}
