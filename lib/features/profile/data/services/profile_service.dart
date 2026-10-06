import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/profile_model.dart';

/// Service responsible for persisting and retrieving the user's fitness profile.
/// Uses Firestore when Firebase is initialized; maintains an in-memory cache as fallback.
class ProfileService {
  ProfileService._();

  static const String _collection = 'user_profiles';
  static ProfileModel? _cachedProfile;

  /// Gets the current profile (from cache or initial fallback).
  static ProfileModel get currentProfile => _cachedProfile ?? ProfileModel.initial();

  /// Saves the profile to Firestore under an anonymous/guest document ID and updates cache.
  static Future<void> saveProfile(ProfileModel profile, {String docId = 'guest'}) async {
    _cachedProfile = profile;

    if (!FirebaseService.isInitialized) {
      developer.log(
        'Firebase not initialized. Profile saved in cache: ${profile.toMap()}',
        name: 'ProfileService',
      );
      // Simulate network latency for natural UX feel
      await Future<void>.delayed(const Duration(milliseconds: 600));
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

  /// Loads profile from Firestore if available, otherwise returns cached.
  static Future<ProfileModel> getProfile({String docId = 'guest'}) async {
    if (!FirebaseService.isInitialized) {
      return currentProfile;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection(_collection).doc(docId).get();
      if (doc.exists && doc.data() != null) {
        _cachedProfile = ProfileModel.fromMap(doc.data()!);
        return _cachedProfile!;
      }
    } catch (e) {
      developer.log('Failed to fetch profile: $e', name: 'ProfileService');
    }
    return currentProfile;
  }
}
