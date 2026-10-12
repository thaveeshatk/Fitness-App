import 'package:flutter/material.dart';
import 'core/constants/app_strings.dart';
import 'core/routes/app_routes.dart';
import 'core/services/theme_service.dart';
import 'core/theme/app_theme.dart';

/// Main Application Widget
class FitOnApp extends StatelessWidget {
  const FitOnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
    );
  }
}
