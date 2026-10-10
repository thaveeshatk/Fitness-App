import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/constants/app_colors.dart';
import 'core/services/firebase_service.dart';
import 'features/auth/data/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive edge-to-edge system navigation & status bars
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase (safely prepared for project services)
  await FirebaseService.initialize();
  AuthService.initializeAuth();

  runApp(const FitOnApp());
}

