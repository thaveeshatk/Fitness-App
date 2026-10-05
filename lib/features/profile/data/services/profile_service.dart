import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/profile_model.dart';

/// Service responsible for persisting the user's fitness profile.
/// Uses Firestore when Firebase is initialized; gracefully degrades otherwise.
class ProfileService {
  ProfileService._();

  static const String _collection = 'user_profiles';

  /// Saves the profile to Firestore under an anonymous/guest document ID.
  /// When auth is wired up, replace [docId] with the actual UID.
  static Future<void> saveProfile(ProfileModel profile, {String docId = 'guest'}) async {
    if (!FirebaseService.isInitialized) {
      developer.log(
        'Firebase not initialized. Profile would be saved: ${profile.toMap()}',
        name: 'ProfileService',
      );
      // Simulate a short delay so loading state is visible even without Firebase.
      await Future<void>.delayed(const Duration(milliseconds: 800));
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(docId)
          .set(profile.toMap(), SetOptions(merge: true));

      developer.log('Profile saved successfully for doc: $docId', name: 'ProfileService');
    } catch (e, stack) {
      developer.log('Failed to save profile: $e', name: 'ProfileService', error: e, stackTrace: stack);
      rethrow;
    }
  }
}
