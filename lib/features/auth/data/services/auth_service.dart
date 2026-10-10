import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/auth_user.dart';

import 'package:flutter/foundation.dart';

/// Central authentication service providing user sign in, account creation,
/// and session persistence. Operates with Firebase Auth when configured,
/// and provides an in-memory session fallback for local operation.
class AuthService {
  AuthService._();

  static AuthUser? _currentUser = AuthUser.mockDefault();
  static final ValueNotifier<AuthUser?> userNotifier = ValueNotifier<AuthUser?>(_currentUser);

  static bool get isLoggedIn => _currentUser != null;

  static AuthUser get currentUser {
    if (FirebaseService.isInitialized && FirebaseAuth.instance.currentUser != null) {
      final fb = FirebaseAuth.instance.currentUser!;
      if (_currentUser == null || _currentUser!.uid != fb.uid) {
        _currentUser = _mapFirebaseUser(fb);
      }
    }
    return _currentUser ?? AuthUser.mockDefault();
  }

  /// Initializes auth state listener when Firebase is available
  static void initializeAuth() {
    if (!FirebaseService.isInitialized) return;

    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser != null) {
      _currentUser = _mapFirebaseUser(fbUser);
      userNotifier.value = _currentUser;
    }

    FirebaseAuth.instance.authStateChanges().listen((fbUser) {
      if (fbUser != null) {
        _currentUser = _mapFirebaseUser(fbUser);
      } else {
        _currentUser = null;
      }
      userNotifier.value = _currentUser;
    });
  }

  static AuthUser _mapFirebaseUser(User fbUser) {
    return AuthUser(
      uid: fbUser.uid,
      name: (fbUser.displayName != null && fbUser.displayName!.isNotEmpty)
          ? fbUser.displayName!
          : (fbUser.email?.split('@').first ?? 'Alex'),
      email: fbUser.email ?? '',
      photoUrl: fbUser.photoURL ??
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150&auto=format&fit=crop',
    );
  }

  /// Preset profile avatars for quick selection
  static const List<String> presetAvatars = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=250&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=250&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=250&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=250&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=250&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=250&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=250&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?q=80&w=250&auto=format&fit=crop',
  ];

  /// Updates profile picture URL across the app and notifies all listeners
  static Future<void> updateProfilePhoto(String? newPhotoUrl) async {
    final current = _currentUser ?? AuthUser.mockDefault();
    _currentUser = current.copyWith(photoUrl: newPhotoUrl);
    userNotifier.value = _currentUser;

    developer.log('Updated profile photo to: $newPhotoUrl', name: 'AuthService');

    if (FirebaseService.isInitialized) {
      try {
        final fbUser = FirebaseAuth.instance.currentUser;
        if (fbUser != null) {
          await fbUser.updatePhotoURL(newPhotoUrl);
          await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).set({
            'photoUrl': newPhotoUrl,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      } catch (e) {
        developer.log('Failed updating Firebase user photo: $e', name: 'AuthService');
      }
    }
  }

  /// Updates profile information including name, email, and optionally photo.
  static Future<void> updateProfileInfo({
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    final current = _currentUser ?? AuthUser.mockDefault();
    _currentUser = AuthUser(
      uid: current.uid,
      name: name,
      email: email,
      photoUrl: photoUrl ?? current.photoUrl,
    );
    userNotifier.value = _currentUser;

    developer.log('Updated profile info: $name, $email', name: 'AuthService');

    if (FirebaseService.isInitialized) {
      try {
        final fbUser = FirebaseAuth.instance.currentUser;
        if (fbUser != null) {
          if (name != fbUser.displayName) {
            await fbUser.updateDisplayName(name);
          }
          if (photoUrl != null && photoUrl != fbUser.photoURL) {
            await fbUser.updatePhotoURL(photoUrl);
          }
          if (email != fbUser.email) {
            await fbUser.verifyBeforeUpdateEmail(email); // Firebase recommended way
          }
          await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).set({
            'name': name,
            'email': email,
            if (photoUrl != null) 'photoUrl': photoUrl,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      } catch (e) {
        developer.log('Failed updating Firebase user info: $e', name: 'AuthService');
      }
    }

    // Simulate network delay for local usage
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Sign in with Email and Password
  static Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    developer.log('Attempting sign in for: $email', name: 'AuthService');

    if (FirebaseService.isInitialized) {
      try {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final fbUser = credential.user;
        _currentUser = AuthUser(
          uid: fbUser?.uid ?? 'uid_${DateTime.now().millisecondsSinceEpoch}',
          name: (fbUser?.displayName != null && fbUser!.displayName!.isNotEmpty)
              ? fbUser.displayName!
              : (email.split('@').first.isNotEmpty ? email.split('@').first : 'Alex'),
          email: fbUser?.email ?? email,
          photoUrl: fbUser?.photoURL ??
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150&auto=format&fit=crop',
        );
        userNotifier.value = _currentUser;

        // Sync user document in Firestore
        if (fbUser != null) {
          try {
            await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).set({
              'uid': fbUser.uid,
              'name': _currentUser!.name,
              'email': fbUser.email ?? email.trim(),
              'lastLoginAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          } catch (e) {
            developer.log('Failed syncing user doc in Firestore: $e', name: 'AuthService');
          }
        }

        return _currentUser!;
      } catch (e) {
        developer.log('Firebase signIn failed: $e', name: 'AuthService');
        rethrow;
      }
    }

    // Graceful fallback for local development
    await Future.delayed(const Duration(milliseconds: 650));
    final resolvedName = email.split('@').first;
    final capitalized = resolvedName.isNotEmpty
        ? '${resolvedName[0].toUpperCase()}${resolvedName.substring(1)}'
        : 'Alex';

    _currentUser = AuthUser(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: capitalized.isNotEmpty ? capitalized : 'Alex',
      email: email.trim(),
      photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150&auto=format&fit=crop',
    );
    userNotifier.value = _currentUser;
    return _currentUser!;
  }

  /// Register / Create a new account with Name, Email, and Password
  static Future<AuthUser> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    developer.log('Attempting sign up for: $email ($name)', name: 'AuthService');

    if (FirebaseService.isInitialized) {
      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final fbUser = credential.user;
        if (fbUser != null && name.trim().isNotEmpty) {
          await fbUser.updateDisplayName(name.trim());
        }
        _currentUser = AuthUser(
          uid: fbUser?.uid ?? 'uid_${DateTime.now().millisecondsSinceEpoch}',
          name: name.trim().isNotEmpty ? name.trim() : 'Alex',
          email: fbUser?.email ?? email,
          photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150&auto=format&fit=crop',
        );
        userNotifier.value = _currentUser;

        // Persist new user in Firestore users collection
        if (fbUser != null) {
          try {
            await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).set({
              'uid': fbUser.uid,
              'name': _currentUser!.name,
              'email': fbUser.email ?? email.trim(),
              'createdAt': FieldValue.serverTimestamp(),
              'lastLoginAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
            developer.log('User document created in Firestore: ${fbUser.uid}', name: 'AuthService');
          } catch (e) {
            developer.log('Failed saving user doc to Firestore: $e', name: 'AuthService');
          }
        }

        return _currentUser!;
      } catch (e) {
        developer.log('Firebase signUp failed: $e', name: 'AuthService');
        rethrow;
      }
    }

    // Graceful fallback for local development
    await Future.delayed(const Duration(milliseconds: 700));
    _currentUser = AuthUser(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isNotEmpty ? name.trim() : 'Alex',
      email: email.trim(),
      photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150&auto=format&fit=crop',
    );
    userNotifier.value = _currentUser;
    return _currentUser!;
  }

  /// Social Login: Google
  static Future<AuthUser> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 600));
    _currentUser = const AuthUser(
      uid: 'google_user_01',
      name: 'Alex',
      email: 'alex.fitness@gmail.com',
      photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150&auto=format&fit=crop',
    );
    userNotifier.value = _currentUser;
    return _currentUser!;
  }

  /// Social Login: Apple
  static Future<AuthUser> signInWithApple() async {
    await Future.delayed(const Duration(milliseconds: 600));
    _currentUser = const AuthUser(
      uid: 'apple_user_01',
      name: 'Alex',
      email: 'alex@icloud.com',
      photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150&auto=format&fit=crop',
    );
    userNotifier.value = _currentUser;
    return _currentUser!;
  }

  /// Sign out
  static Future<void> signOut() async {
    if (FirebaseService.isInitialized) {
      await FirebaseAuth.instance.signOut();
    }
    _currentUser = null;
    userNotifier.value = null;
  }
}

