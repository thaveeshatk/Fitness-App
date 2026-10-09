import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../auth/data/services/auth_service.dart';
import '../models/notification_model.dart';
import '../models/notification_preference_model.dart';

class NotificationService {
  NotificationService._();

  static const String _notificationsCollection = 'notifications';
  static const String _preferencesCollection = 'notification_preferences';
  static final _uuid = const Uuid();

  static final ValueNotifier<List<NotificationModel>> notificationsNotifier = ValueNotifier([]);
  static final ValueNotifier<int> unreadCountNotifier = ValueNotifier(0);
  static NotificationPreferenceModel _currentPreferences = const NotificationPreferenceModel();

  static NotificationPreferenceModel get preferences => _currentPreferences;

  static void initialize() {
    _loadPreferences();
    _loadNotifications();
  }

  // --- PREFERENCES ---

  static Future<void> _loadPreferences() async {
    final userId = AuthService.currentUser.uid;
    if (FirebaseService.isInitialized) {
      try {
        final doc = await FirebaseFirestore.instance.collection(_preferencesCollection).doc(userId).get();
        if (doc.exists && doc.data() != null) {
          _currentPreferences = NotificationPreferenceModel.fromMap(doc.data()!);
        }
      } catch (e) {
        developer.log('Failed to fetch notification preferences: $e');
      }
    }
  }

  static Future<void> updatePreferences(NotificationPreferenceModel newPrefs) async {
    _currentPreferences = newPrefs;
    final userId = AuthService.currentUser.uid;
    
    if (FirebaseService.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection(_preferencesCollection)
            .doc(userId)
            .set(newPrefs.toMap(), SetOptions(merge: true));
      } catch (e) {
        developer.log('Failed to save notification preferences: $e');
      }
    }
  }

  // --- NOTIFICATIONS CRUD ---

  static Future<void> _loadNotifications() async {
    final userId = AuthService.currentUser.uid;
    if (FirebaseService.isInitialized) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection(_notificationsCollection)
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();
            
        final notifs = snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data(), doc.id)).toList();
        notificationsNotifier.value = notifs;
        _updateUnreadCount();
      } catch (e) {
        developer.log('Failed to load notifications: $e');
      }
    } else {
      // Load mock notifications for UI if no firebase
      notificationsNotifier.value = [
        NotificationModel(
          id: 'mock_1',
          title: 'Welcome to FitOn!',
          message: 'Ready to start your fitness journey? Check out your adaptive plan.',
          category: 'general',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: false,
        ),
      ];
      _updateUnreadCount();
    }
  }

  static void _updateUnreadCount() {
    unreadCountNotifier.value = notificationsNotifier.value.where((n) => !n.isRead).length;
  }

  static Future<void> addNotification({
    required String title,
    required String message,
    required String category,
    String? relatedEntityType,
    String? relatedEntityId,
    String? actionUrl,
  }) async {
    // Check preferences before adding
    if (!_shouldSendNotification(category)) return;

    final userId = AuthService.currentUser.uid;
    final notifId = _uuid.v4();
    final newNotif = NotificationModel(
      id: notifId,
      title: title,
      message: message,
      category: category,
      createdAt: DateTime.now(),
      relatedEntityType: relatedEntityType,
      relatedEntityId: relatedEntityId,
      actionUrl: actionUrl,
    );

    // Update local state first for instant UI response
    notificationsNotifier.value = [newNotif, ...notificationsNotifier.value];
    _updateUnreadCount();

    if (FirebaseService.isInitialized) {
      try {
        final map = newNotif.toMap();
        map['userId'] = userId;
        await FirebaseFirestore.instance.collection(_notificationsCollection).doc(notifId).set(map);
      } catch (e) {
        developer.log('Failed to add notification: $e');
      }
    }
  }

  static bool _shouldSendNotification(String category) {
    if (!_currentPreferences.inAppNotificationsEnabled) return false;
    
    switch (category) {
      case 'workout_reminder':
        return _currentPreferences.workoutRemindersEnabled;
      case 'workout_completed':
        return _currentPreferences.workoutCompletionEnabled;
      case 'goal_achievement':
        return _currentPreferences.goalAchievementsEnabled;
      case 'plan_updated':
        return _currentPreferences.adaptivePlanUpdatesEnabled;
      case 'weekly_report':
        return _currentPreferences.weeklyReportsEnabled;
      case 'inactivity':
        return _currentPreferences.inactivityRemindersEnabled;
      default:
        return _currentPreferences.generalNotificationsEnabled;
    }
  }

  static Future<void> markAsRead(String notificationId) async {
    final idx = notificationsNotifier.value.indexWhere((n) => n.id == notificationId);
    if (idx != -1) {
      final updatedList = List<NotificationModel>.from(notificationsNotifier.value);
      updatedList[idx] = updatedList[idx].copyWith(isRead: true);
      notificationsNotifier.value = updatedList;
      _updateUnreadCount();

      if (FirebaseService.isInitialized) {
        try {
          await FirebaseFirestore.instance
              .collection(_notificationsCollection)
              .doc(notificationId)
              .update({'isRead': true});
        } catch (e) {}
      }
    }
  }

  static Future<void> markAllAsRead() async {
    final updatedList = notificationsNotifier.value.map((n) => n.copyWith(isRead: true)).toList();
    notificationsNotifier.value = updatedList;
    _updateUnreadCount();

    if (FirebaseService.isInitialized) {
      try {
        final userId = AuthService.currentUser.uid;
        final batch = FirebaseFirestore.instance.batch();
        final unreadDocs = await FirebaseFirestore.instance
            .collection(_notificationsCollection)
            .where('userId', isEqualTo: userId)
            .where('isRead', isEqualTo: false)
            .get();
            
        for (var doc in unreadDocs.docs) {
          batch.update(doc.reference, {'isRead': true});
        }
        await batch.commit();
      } catch (e) {}
    }
  }

  static Future<void> deleteNotification(String notificationId) async {
    notificationsNotifier.value = notificationsNotifier.value.where((n) => n.id != notificationId).toList();
    _updateUnreadCount();

    if (FirebaseService.isInitialized) {
      try {
        await FirebaseFirestore.instance.collection(_notificationsCollection).doc(notificationId).delete();
      } catch (e) {}
    }
  }

  static Future<void> clearAll() async {
    notificationsNotifier.value = [];
    _updateUnreadCount();

    if (FirebaseService.isInitialized) {
      try {
        final userId = AuthService.currentUser.uid;
        final snapshot = await FirebaseFirestore.instance
            .collection(_notificationsCollection)
            .where('userId', isEqualTo: userId)
            .get();
            
        final batch = FirebaseFirestore.instance.batch();
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      } catch (e) {}
    }
  }
}
