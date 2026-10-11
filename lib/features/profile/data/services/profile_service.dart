import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../auth/data/services/auth_service.dart';
import '../models/profile_model.dart';
import '../../../notifications/data/services/notification_service.dart';

/// Service responsible for persisting and retrieving the user's fitness profile.
/// Uses Firestore when Firebase is initialized; maintains an in-memory cache keyed by UID.
class ProfileService {
  ProfileService._();

  static const String _collection = 'user_profiles';
  static final Map<String, ProfileModel> _cache = {};

  /// Global notifier that broadcasts when the user's profile is updated or saved.
  static final ValueNotifier<ProfileModel?> profileNotifier = ValueNotifier<ProfileModel?>(null);

  /// Gets the current profile for the authenticated user (from cache or initial fallback).
  static ProfileModel get currentProfile {
    final uid = AuthService.currentUser.uid;
    return _cache[uid] ?? ProfileModel.initial();
  }

  /// Clears the local in-memory profile cache
  static void clearCache() {
    _cache.clear();
    profileNotifier.value = null;
  }

  /// Saves the profile to Firestore under the signed-in user's own document and updates cache.
  /// Defaults to the current user's uid so each user's profile is kept separate.
  static Future<void> saveProfile(ProfileModel profile, {String? docId}) async {
    final resolvedDocId = docId ?? AuthService.currentUser.uid;
    _cache[resolvedDocId] = profile;
    profileNotifier.value = profile;

    // Trigger system notification for profile update
    await NotificationService.onProfileUpdated(
      detail: 'Your fitness preferences (${profile.fitnessLevel}, ${profile.goals.join(", ")}) have been saved.',
    );

    if (!FirebaseService.isInitialized) {
      developer.log(
        'Firebase not initialized. Profile saved in cache: ${profile.toMap()}',
        name: 'ProfileService',
      );
      // Simulate network latency for natural UX feel
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection(_collection)
          .doc(resolvedDocId)
          .set(profile.toMap(), SetOptions(merge: true));

      developer.log('Profile saved successfully for doc: $resolvedDocId', name: 'ProfileService');
    } catch (e, stack) {
      developer.log('Failed to save profile: $e', name: 'ProfileService', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Loads profile from Firestore if available, otherwise returns cached or initial profile.
  /// Defaults to the current user's uid so each user gets their own profile back.
  static Future<ProfileModel> getProfile({String? docId, bool forceRefresh = false}) async {
    final resolvedDocId = docId ?? AuthService.currentUser.uid;

    if (!forceRefresh && _cache.containsKey(resolvedDocId)) {
      return _cache[resolvedDocId]!;
    }

    if (!FirebaseService.isInitialized) {
      return _cache[resolvedDocId] ?? ProfileModel.initial();
    }

    try {
      final doc = await FirebaseFirestore.instance.collection(_collection).doc(resolvedDocId).get();
      if (doc.exists && doc.data() != null) {
        final profile = ProfileModel.fromMap(doc.data()!);
        _cache[resolvedDocId] = profile;
        return profile;
      }
    } catch (e) {
      developer.log('Failed to fetch profile: $e', name: 'ProfileService');
    }
    return _cache[resolvedDocId] ?? ProfileModel.initial();
  }
}

