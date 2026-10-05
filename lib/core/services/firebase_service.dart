import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

/// Firebase initialization service abstraction.
/// Gracefully handles initialization so UI works both with and without
/// active google-services configuration during this initial UI phase.
class FirebaseService {
  FirebaseService._();

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    try {
      // If Firebase options are configured, initialize Firebase
      await Firebase.initializeApp();
      _isInitialized = true;
      developer.log('Firebase initialized successfully', name: 'FirebaseService');
    } catch (e) {
      // In early UI phases before google-services.json is linked, fail gracefully
      if (kDebugMode) {
        developer.log(
          'Firebase initialization skipped or pending project config: $e',
          name: 'FirebaseService',
        );
      }
    }
  }
}
