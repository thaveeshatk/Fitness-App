import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/firebase_service.dart';
import 'core/services/theme_service.dart';
import 'features/auth/data/services/auth_service.dart';
import 'features/notifications/data/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ThemeService to restore user's light/dark mode preference immediately
  await ThemeService.initialize();

  // Initialize Firebase (safely prepared for project services)
  await FirebaseService.initialize();
  AuthService.initializeAuth();
  NotificationService.initialize();
  NotificationService.checkScheduledReminders();

  runApp(const FitOnApp());
}

