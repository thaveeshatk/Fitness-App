import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/auth_user.dart';

/// Central authentication service providing user sign in, account creation,
/// and session persistence. Operates with Firebase Auth when configured,
/// and provides an in-memory session fallback for local operation.
class AuthService {
  AuthService._();

  static AuthUser? _currentUser = AuthUser.mockDefault();
  static bool get isLoggedIn => _currentUser != null;
  static AuthUser get currentUser => _currentUser ?? AuthUser.mockDefault();

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
    return _currentUser!;
  }

  /// Sign out
  static Future<void> signOut() async {
    if (FirebaseService.isInitialized) {
      await FirebaseAuth.instance.signOut();
    }
    _currentUser = null;
  }
}
