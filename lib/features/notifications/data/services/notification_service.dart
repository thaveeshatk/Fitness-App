import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../auth/data/services/auth_service.dart';
import '../models/notification_model.dart';
import '../models/notification_preferences.dart';

/// Centralized notification service managing state, persistence, event handling,
/// preferences, and reactive streams across the application.
class NotificationService {
  NotificationService._();

  static const String _notificationsCollection = 'user_notifications';
  static const String _preferencesCollection = 'notification_preferences';

  // Per-user caches
  static final Map<String, List<NotificationModel>> _notificationsCache = {};
  static final Map<String, NotificationPreferences> _preferencesCache = {};

  // Reactive notifiers for real-time UI synchronization
  static final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<List<NotificationModel>> notificationsNotifier =
      ValueNotifier<List<NotificationModel>>([]);
  static final ValueNotifier<NotificationPreferences> preferencesNotifier =
      ValueNotifier<NotificationPreferences>(NotificationPreferences.defaults());

  static bool _initialized = false;

  /// Initializes the notification service and syncs with auth state changes
  static void initialize() {
    if (_initialized) return;
    _initialized = true;

    // Listen to authentication changes to reload user-specific notifications
    AuthService.userNotifier.addListener(() {
      final currentUid = AuthService.currentUser.uid;
      loadPreferences(uid: currentUid);
      loadNotifications(uid: currentUid);
    });

    final currentUid = AuthService.currentUser.uid;
    loadPreferences(uid: currentUid);
    loadNotifications(uid: currentUid);
  }

  /// Loads notification preferences for the specified user or current user
  static Future<NotificationPreferences> loadPreferences({
    String? uid,
    bool forceRefresh = false,
  }) async {
    final currentUid = uid ?? AuthService.currentUser.uid;

    if (!forceRefresh && _preferencesCache.containsKey(currentUid)) {
      final cached = _preferencesCache[currentUid]!;
      preferencesNotifier.value = cached;
      return cached;
    }

    if (!FirebaseService.isInitialized) {
      final defaults = _preferencesCache[currentUid] ?? NotificationPreferences.defaults();
      _preferencesCache[currentUid] = defaults;
      preferencesNotifier.value = defaults;
      return defaults;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection(_preferencesCollection)
          .doc(currentUid)
          .get();

      if (doc.exists && doc.data() != null) {
        final prefs = NotificationPreferences.fromMap(doc.data()!);
        _preferencesCache[currentUid] = prefs;
        preferencesNotifier.value = prefs;
        return prefs;
      }
    } catch (e) {
      developer.log('Error loading notification preferences: $e', name: 'NotificationService');
    }

    final fallback = NotificationPreferences.defaults();
    _preferencesCache[currentUid] = fallback;
    preferencesNotifier.value = fallback;
    return fallback;
  }

  /// Updates and persists notification preferences
  static Future<void> updatePreferences(
    NotificationPreferences newPrefs, {
    String? uid,
  }) async {
    final currentUid = uid ?? AuthService.currentUser.uid;
    _preferencesCache[currentUid] = newPrefs;
    preferencesNotifier.value = newPrefs;

    developer.log('Updated notification preferences for $currentUid', name: 'NotificationService');

    if (FirebaseService.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection(_preferencesCollection)
            .doc(currentUid)
            .set(newPrefs.toMap(), SetOptions(merge: true));
      } catch (e) {
        developer.log('Failed to persist preferences to Firestore: $e', name: 'NotificationService');
      }
    }
  }

  /// Loads all notifications for the user in reverse chronological order
  static Future<List<NotificationModel>> loadNotifications({
    String? uid,
    bool forceRefresh = false,
  }) async {
    final currentUid = uid ?? AuthService.currentUser.uid;

    if (!forceRefresh && _notificationsCache.containsKey(currentUid)) {
      final list = _notificationsCache[currentUid]!;
      _updateNotifiers(list);
      return list;
    }

    if (!FirebaseService.isInitialized) {
      final list = _notificationsCache[currentUid] ?? _getSeedNotifications(currentUid);
      _notificationsCache[currentUid] = list;
      _updateNotifiers(list);
      return list;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_notificationsCollection)
          .where('userId', isEqualTo: currentUid)
          .get();

      final list = snapshot.docs.map((d) => NotificationModel.fromMap(d.data())).toList();
      // Sort reverse chronological
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (list.isEmpty) {
        // Seed default starter notifications if first time
        final seeds = _getSeedNotifications(currentUid);
        for (final seed in seeds) {
          await FirebaseFirestore.instance
              .collection(_notificationsCollection)
              .doc(seed.id)
              .set(seed.toMap(), SetOptions(merge: true));
        }
        list.addAll(seeds);
      }

      _notificationsCache[currentUid] = list;
      _updateNotifiers(list);
      return list;
    } catch (e) {
      developer.log('Error fetching notifications from Firestore: $e', name: 'NotificationService');
      final fallback = _notificationsCache[currentUid] ?? _getSeedNotifications(currentUid);
      _notificationsCache[currentUid] = fallback;
      _updateNotifiers(fallback);
      return fallback;
    }
  }

  /// Creates and persists a new notification if user preferences permit it
  static Future<NotificationModel?> createNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? eventKey,
    String? actionRoute,
    Map<String, dynamic>? metadata,
    String? uid,
  }) async {
    final currentUid = uid ?? AuthService.currentUser.uid;
    final prefs = _preferencesCache[currentUid] ?? preferencesNotifier.value;

    // 1. Enforce Master Toggle
    if (!prefs.enabled) {
      developer.log('Notifications disabled by master toggle. Skipping: $title', name: 'NotificationService');
      return null;
    }

    // 2. Enforce Category-Specific Preferences
    switch (type) {
      case NotificationType.workout:
        if (!prefs.workoutReminders) {
          developer.log('Workout reminders disabled. Skipping: $title', name: 'NotificationService');
          return null;
        }
        break;
      case NotificationType.schedule:
        if (!prefs.scheduleReminders) {
          developer.log('Schedule reminders disabled. Skipping: $title', name: 'NotificationService');
          return null;
        }
        break;
      case NotificationType.goal:
        if (!prefs.goalNotifications) {
          developer.log('Goal notifications disabled. Skipping: $title', name: 'NotificationService');
          return null;
        }
        break;
      case NotificationType.progress:
        if (!prefs.progressUpdates) {
          developer.log('Progress updates disabled. Skipping: $title', name: 'NotificationService');
          return null;
        }
        break;
      case NotificationType.adaptivePlan:
        if (!prefs.adaptivePlanUpdates) {
          developer.log('Adaptive plan updates disabled. Skipping: $title', name: 'NotificationService');
          return null;
        }
        break;
      case NotificationType.system:
        // System and account alerts follow master toggle
        break;
    }

    final userList = _notificationsCache[currentUid] ?? [];

    // 3. Deduplication Check using eventKey
    if (eventKey != null && eventKey.isNotEmpty) {
      final exists = userList.any((n) => n.eventKey == eventKey);
      if (exists) {
        developer.log('Duplicate notification prevented for eventKey: $eventKey', name: 'NotificationService');
        return null;
      }
    }

    final newNotification = NotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}_${userList.length}',
      userId: currentUid,
      title: title,
      message: message,
      type: type,
      isRead: false,
      eventKey: eventKey,
      actionRoute: actionRoute,
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    userList.insert(0, newNotification);
    _notificationsCache[currentUid] = userList;
    _updateNotifiers(userList);

    if (FirebaseService.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection(_notificationsCollection)
            .doc(newNotification.id)
            .set(newNotification.toMap());
      } catch (e) {
        developer.log('Failed saving notification to Firestore: $e', name: 'NotificationService');
      }
    }

    return newNotification;
  }

  /// Marks an individual notification as read
  static Future<void> markAsRead(String notificationId, {String? uid}) async {
    final currentUid = uid ?? AuthService.currentUser.uid;
    final list = _notificationsCache[currentUid] ?? [];

    final index = list.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      list[index] = list[index].copyWith(isRead: true);
      _notificationsCache[currentUid] = list;
      _updateNotifiers(list);

      if (FirebaseService.isInitialized) {
        try {
          await FirebaseFirestore.instance
              .collection(_notificationsCollection)
              .doc(notificationId)
              .update({'isRead': true});
        } catch (e) {
          developer.log('Error marking notification as read: $e', name: 'NotificationService');
        }
      }
    }
  }

  /// Marks all notifications for current user as read
  static Future<void> markAllAsRead({String? uid}) async {
    final currentUid = uid ?? AuthService.currentUser.uid;
    final list = _notificationsCache[currentUid] ?? [];

    final updated = list.map((n) => n.copyWith(isRead: true)).toList();
    _notificationsCache[currentUid] = updated;
    _updateNotifiers(updated);

    if (FirebaseService.isInitialized) {
      try {
        final batch = FirebaseFirestore.instance.batch();
        final snapshot = await FirebaseFirestore.instance
            .collection(_notificationsCollection)
            .where('userId', isEqualTo: currentUid)
            .where('isRead', isEqualTo: false)
            .get();

        for (final doc in snapshot.docs) {
          batch.update(doc.reference, {'isRead': true});
        }
        await batch.commit();
      } catch (e) {
        developer.log('Error marking all notifications as read: $e', name: 'NotificationService');
      }
    }
  }

  /// Deletes a specific notification
  static Future<void> deleteNotification(String notificationId, {String? uid}) async {
    final currentUid = uid ?? AuthService.currentUser.uid;
    final list = _notificationsCache[currentUid] ?? [];

    list.removeWhere((n) => n.id == notificationId);
    _notificationsCache[currentUid] = list;
    _updateNotifiers(list);

    if (FirebaseService.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection(_notificationsCollection)
            .doc(notificationId)
            .delete();
      } catch (e) {
        developer.log('Error deleting notification from Firestore: $e', name: 'NotificationService');
      }
    }
  }

  /// Clears all notifications for the authenticated user
  static Future<void> clearAllNotifications({String? uid}) async {
    final currentUid = uid ?? AuthService.currentUser.uid;
    _notificationsCache[currentUid] = [];
    _updateNotifiers([]);

    if (FirebaseService.isInitialized) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection(_notificationsCollection)
            .where('userId', isEqualTo: currentUid)
            .get();

        final batch = FirebaseFirestore.instance.batch();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      } catch (e) {
        developer.log('Error clearing notifications: $e', name: 'NotificationService');
      }
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Business Event Triggers
  // ───────────────────────────────────────────────────────────────────────────

  /// Triggered when a workout session finishes
  static Future<void> onWorkoutCompleted({
    required String workoutTitle,
    required int durationMinutes,
    required int calories,
    String? workoutId,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await createNotification(
      title: 'Workout Completed! 🎉',
      message: 'Great job finishing "$workoutTitle" ($durationMinutes mins, $calories kcal burned)!',
      type: NotificationType.workout,
      eventKey: 'workout_completed_${workoutId ?? workoutTitle}_$timestamp',
      actionRoute: '/progress',
      metadata: {
        'workoutTitle': workoutTitle,
        'durationMinutes': durationMinutes,
        'calories': calories,
      },
    );
  }

  /// Triggered when weekly workout schedule is saved or updated
  static Future<void> onScheduleUpdated({
    required Set<String> days,
    required String time,
    required bool isAm,
  }) async {
    final daysStr = days.join(', ');
    final amPm = isAm ? 'AM' : 'PM';
    final dateStr = DateTime.now().toIso8601String().substring(0, 10);

    await createNotification(
      title: 'Schedule Updated 📅',
      message: 'Your workouts are scheduled for $daysStr at $time $amPm.',
      type: NotificationType.schedule,
      eventKey: 'schedule_updated_$dateStr',
      actionRoute: '/my-plan',
      metadata: {
        'days': days.toList(),
        'time': time,
        'isAm': isAm,
      },
    );
  }

  /// Triggered when the adaptive plan modifies the user\'s workout
  static Future<void> onAdaptivePlanUpdated({
    required String planTitle,
    String? message,
  }) async {
    final dateStr = DateTime.now().toIso8601String().substring(0, 10);
    await createNotification(
      title: 'Adaptive Plan Updated ⚡',
      message: message ??
          'Your routine "$planTitle" has been adapted with a gentler pace to keep you consistent.',
      type: NotificationType.adaptivePlan,
      eventKey: 'adaptive_plan_updated_$dateStr',
      actionRoute: '/my-plan',
      metadata: {'planTitle': planTitle},
    );
  }

  /// Triggered when a weekly goal or milestone is achieved
  static Future<void> onGoalAchieved({
    required String goalTitle,
    String? subtitle,
  }) async {
    final dateStr = DateTime.now().toIso8601String().substring(0, 10);
    await createNotification(
      title: 'Goal Achieved! 🏆',
      message: subtitle ?? 'Congratulations! You reached your goal: $goalTitle.',
      type: NotificationType.goal,
      eventKey: 'goal_achieved_${goalTitle.toLowerCase().replaceAll(' ', '_')}_$dateStr',
      actionRoute: '/goals',
      metadata: {'goalTitle': goalTitle},
    );
  }

  /// Triggered when a progress milestone or streak occurs
  static Future<void> onMilestoneReached({
    required String milestoneTitle,
    required String details,
  }) async {
    final dateStr = DateTime.now().toIso8601String().substring(0, 10);
    await createNotification(
      title: 'Progress Milestone 📈',
      message: details,
      type: NotificationType.progress,
      eventKey: 'milestone_${milestoneTitle.toLowerCase().replaceAll(' ', '_')}_$dateStr',
      actionRoute: '/progress',
      metadata: {'milestoneTitle': milestoneTitle},
    );
  }

  /// Triggered when the profile or account settings change
  static Future<void> onProfileUpdated({
    required String detail,
  }) async {
    await createNotification(
      title: 'Profile Updated 👤',
      message: detail,
      type: NotificationType.system,
      eventKey: 'profile_updated_${DateTime.now().millisecondsSinceEpoch}',
      actionRoute: '/profile-preferences',
    );
  }

  /// Evaluates configured schedule days and sends a reminder for today if due
  static Future<void> checkScheduledReminders() async {
    final currentUid = AuthService.currentUser.uid;
    final prefs = _preferencesCache[currentUid] ?? preferencesNotifier.value;

    if (!prefs.enabled || !prefs.workoutReminders) return;

    final now = DateTime.now();
    final weekdayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final currentDayName = weekdayNames[now.weekday - 1];
    final shortDayName = currentDayName.substring(0, 3); // Mon, Tue...

    final isScheduled = prefs.reminderDays.any(
      (d) => d.toLowerCase() == currentDayName.toLowerCase() ||
          d.toLowerCase() == shortDayName.toLowerCase(),
    );

    if (isScheduled) {
      final dateKey = '${now.year}-${now.month}-${now.day}';
      await createNotification(
        title: 'Workout Reminder ⏰',
        message: 'Today ($currentDayName) is a scheduled workout day! Take 20 minutes to move your body.',
        type: NotificationType.workout,
        eventKey: 'daily_reminder_$dateKey',
        actionRoute: '/my-plan',
      );
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Internal Helpers
  // ───────────────────────────────────────────────────────────────────────────

  static void _updateNotifiers(List<NotificationModel> list) {
    notificationsNotifier.value = List.unmodifiable(list);
    final unread = list.where((n) => !n.isRead).length;
    unreadCountNotifier.value = unread;
  }

  /// Seed realistic notifications for a smooth out-of-the-box user experience
  static List<NotificationModel> _getSeedNotifications(String uid) {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: 'seed_notif_1',
        userId: uid,
        title: 'Welcome to FitOn! 🎯',
        message: 'Your personalized home workout plan is ready. Tap to view your scheduled routines.',
        type: NotificationType.system,
        isRead: false,
        eventKey: 'seed_welcome',
        actionRoute: '/my-plan',
        createdAt: now.subtract(const Duration(minutes: 15)),
      ),
      NotificationModel(
        id: 'seed_notif_2',
        userId: uid,
        title: 'Weekly Schedule Active 📅',
        message: 'Workouts set for Mon, Wed, Fri at 07:00 AM. Consistency is key!',
        type: NotificationType.schedule,
        isRead: false,
        eventKey: 'seed_schedule',
        actionRoute: '/my-plan',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: 'seed_notif_3',
        userId: uid,
        title: 'First Milestone In Sight 🏆',
        message: 'Complete your first workout to start your weekly consistency streak.',
        type: NotificationType.goal,
        isRead: true,
        eventKey: 'seed_milestone',
        actionRoute: '/goals',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  /// Clears notifications and preferences cache for a specific user upon deletion or reset
  static void clearUserCache(String uid) {
    _notificationsCache.remove(uid);
    _preferencesCache.remove(uid);
    notificationsNotifier.value = [];
    unreadCountNotifier.value = 0;
    preferencesNotifier.value = NotificationPreferences.defaults();
  }
}
