import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/features/notifications/data/models/notification_model.dart';
import 'package:fitness_app/features/notifications/data/models/notification_preferences.dart';
import 'package:fitness_app/features/notifications/data/services/notification_service.dart';
import 'package:fitness_app/features/notifications/presentation/widgets/notification_bell.dart';
import 'package:fitness_app/features/notifications/presentation/screens/notification_settings_screen.dart';
import 'package:fitness_app/features/notifications/presentation/screens/notification_center_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Notification Models & Serialization Tests', () {
    test('NotificationModel serializes toMap and fromMap correctly', () {
      final notif = NotificationModel(
        id: 'test_123',
        userId: 'user_abc',
        title: 'Workout Finished',
        message: 'Completed Full Body',
        type: NotificationType.workout,
        isRead: false,
        eventKey: 'event_key_1',
        actionRoute: '/progress',
        createdAt: DateTime(2026, 10, 11, 10, 30),
      );

      final map = notif.toMap();
      expect(map['id'], 'test_123');
      expect(map['userId'], 'user_abc');
      expect(map['title'], 'Workout Finished');
      expect(map['type'], 'workout');
      expect(map['isRead'], false);
      expect(map['eventKey'], 'event_key_1');
      expect(map['actionRoute'], '/progress');

      final reconstructed = NotificationModel.fromMap(map);
      expect(reconstructed.id, notif.id);
      expect(reconstructed.userId, notif.userId);
      expect(reconstructed.title, notif.title);
      expect(reconstructed.type, NotificationType.workout);
      expect(reconstructed.isRead, false);
      expect(reconstructed.actionRoute, '/progress');
    });

    test('NotificationPreferences defaults and serialization work properly', () {
      final prefs = NotificationPreferences.defaults();
      expect(prefs.enabled, true);
      expect(prefs.workoutReminders, true);
      expect(prefs.scheduleReminders, true);
      expect(prefs.goalNotifications, true);
      expect(prefs.progressUpdates, true);
      expect(prefs.adaptivePlanUpdates, true);
      expect(prefs.reminderTime, '18:00');
      expect(prefs.reminderDays, contains('Monday'));

      final modified = prefs.copyWith(
        enabled: false,
        workoutReminders: false,
        reminderTime: '07:30',
        reminderDays: ['Tuesday', 'Thursday'],
      );

      final map = modified.toMap();
      final restored = NotificationPreferences.fromMap(map);

      expect(restored.enabled, false);
      expect(restored.workoutReminders, false);
      expect(restored.reminderTime, '07:30');
      expect(restored.reminderDays, ['Tuesday', 'Thursday']);
    });
  });

  group('NotificationService Core & Logic Tests', () {
    const testUserA = 'user_test_a';
    const testUserB = 'user_test_b';

    setUp(() async {
      await NotificationService.clearAllNotifications(uid: testUserA);
      await NotificationService.clearAllNotifications(uid: testUserB);
      await NotificationService.updatePreferences(
        NotificationPreferences.defaults(),
        uid: testUserA,
      );
      await NotificationService.updatePreferences(
        NotificationPreferences.defaults(),
        uid: testUserB,
      );
    });

    test('Creates and retrieves notifications in reverse chronological order', () async {
      final n1 = await NotificationService.createNotification(
        title: 'First Notification',
        message: 'Message 1',
        type: NotificationType.system,
        uid: testUserA,
      );
      expect(n1, isNotNull);

      // Short delay to ensure distinct timestamp
      await Future.delayed(const Duration(milliseconds: 10));

      final n2 = await NotificationService.createNotification(
        title: 'Second Notification',
        message: 'Message 2',
        type: NotificationType.workout,
        uid: testUserA,
      );
      expect(n2, isNotNull);

      final list = await NotificationService.loadNotifications(uid: testUserA);
      expect(list.length, 2);
      expect(list.first.title, 'Second Notification');
      expect(list.last.title, 'First Notification');
    });

    test('Unread count updates correctly when notifications arrive, are read, and deleted', () async {
      final notif = await NotificationService.createNotification(
        title: 'Unread Alert',
        message: 'Please check your schedule',
        type: NotificationType.schedule,
        uid: testUserA,
      );
      expect(notif, isNotNull);

      var list = await NotificationService.loadNotifications(uid: testUserA);
      var unread = list.where((n) => !n.isRead).length;
      expect(unread, 1);

      // Mark as read
      await NotificationService.markAsRead(notif!.id, uid: testUserA);
      list = await NotificationService.loadNotifications(uid: testUserA);
      unread = list.where((n) => !n.isRead).length;
      expect(unread, 0);

      // Mark all as read
      await NotificationService.createNotification(
        title: 'Alert 2',
        message: 'Message',
        type: NotificationType.goal,
        uid: testUserA,
      );
      await NotificationService.markAllAsRead(uid: testUserA);
      list = await NotificationService.loadNotifications(uid: testUserA);
      unread = list.where((n) => !n.isRead).length;
      expect(unread, 0);

      // Delete notification
      await NotificationService.deleteNotification(notif.id, uid: testUserA);
      list = await NotificationService.loadNotifications(uid: testUserA);
      expect(list.any((n) => n.id == notif.id), false);
    });

    test('Master toggle prevents optional notifications when disabled', () async {
      await NotificationService.updatePreferences(
        const NotificationPreferences(enabled: false),
        uid: testUserA,
      );

      final created = await NotificationService.createNotification(
        title: 'Workout Reminder',
        message: 'Should be suppressed',
        type: NotificationType.workout,
        uid: testUserA,
      );

      expect(created, isNull);
      final list = await NotificationService.loadNotifications(uid: testUserA);
      expect(list.isEmpty, true);
    });

    test('Category toggle prevents notifications of that specific category', () async {
      await NotificationService.updatePreferences(
        NotificationPreferences.defaults().copyWith(workoutReminders: false),
        uid: testUserA,
      );

      // Workout category disabled
      final workoutNotif = await NotificationService.createNotification(
        title: 'Workout Reminder',
        message: 'Blocked',
        type: NotificationType.workout,
        uid: testUserA,
      );
      expect(workoutNotif, isNull);

      // Goal category still enabled
      final goalNotif = await NotificationService.createNotification(
        title: 'Goal Achieved',
        message: 'Allowed',
        type: NotificationType.goal,
        uid: testUserA,
      );
      expect(goalNotif, isNotNull);
      expect(goalNotif!.title, 'Goal Achieved');
    });

    test('Deduplication prevents repeated notifications with the same eventKey', () async {
      const eventKey = 'daily_reminder_2026-10-11';

      final first = await NotificationService.createNotification(
        title: 'Workout Reminder',
        message: 'First attempt',
        type: NotificationType.workout,
        eventKey: eventKey,
        uid: testUserA,
      );
      expect(first, isNotNull);

      final duplicate = await NotificationService.createNotification(
        title: 'Workout Reminder',
        message: 'Duplicate attempt',
        type: NotificationType.workout,
        eventKey: eventKey,
        uid: testUserA,
      );
      expect(duplicate, isNull);

      final list = await NotificationService.loadNotifications(uid: testUserA);
      expect(list.length, 1);
    });

    test('User isolation: notifications for user A do not leak to user B', () async {
      await NotificationService.createNotification(
        title: 'User A Secret Alert',
        message: 'Private for A',
        type: NotificationType.system,
        uid: testUserA,
      );

      final listA = await NotificationService.loadNotifications(uid: testUserA);
      final listB = await NotificationService.loadNotifications(uid: testUserB);

      expect(listA.length, 1);
      expect(listA.first.title, 'User A Secret Alert');
      expect(listB.any((n) => n.title == 'User A Secret Alert'), false);
    });

    test('Preferences persist per user across loads', () async {
      final customPrefs = const NotificationPreferences(
        enabled: true,
        workoutReminders: false,
        scheduleReminders: true,
        reminderTime: '20:15',
        reminderDays: ['Saturday', 'Sunday'],
      );

      await NotificationService.updatePreferences(customPrefs, uid: testUserA);
      final loaded = await NotificationService.loadPreferences(uid: testUserA);

      expect(loaded.workoutReminders, false);
      expect(loaded.reminderTime, '20:15');
      expect(loaded.reminderDays, ['Saturday', 'Sunday']);
    });
  });

  group('Widget Tests: Notification Components & Screens', () {
    testWidgets('NotificationBell renders with unread count badge reactively', (tester) async {
      NotificationService.unreadCountNotifier.value = 0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: NotificationBell(),
            ),
          ),
        ),
      );

      expect(find.byType(NotificationBell), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
      expect(find.text('3'), findsNothing);

      // Now simulate 3 new unread notifications
      NotificationService.unreadCountNotifier.value = 3;
      await tester.pump();

      expect(find.byIcon(Icons.notifications_rounded), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('NotificationSettingsScreen displays master and category toggles and allows interaction', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NotificationSettingsScreen(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Enable Notifications'), findsOneWidget);
      expect(find.text('Workout Reminders'), findsOneWidget);
      expect(find.text('Schedule Reminders'), findsOneWidget);
      expect(find.text('Goal Notifications'), findsOneWidget);
      expect(find.text('Progress Updates'), findsOneWidget);
      expect(find.text('Adaptive Plan Updates'), findsOneWidget);
      expect(find.text('Motivational Notifications'), findsOneWidget);
      expect(find.text('Reminder Time'), findsOneWidget);
      expect(find.text('Reminder Days'), findsOneWidget);
      expect(find.text('Reset to Default Preferences'), findsOneWidget);
    });

    testWidgets('NotificationCenterScreen renders tabs, empty state, and controls', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NotificationCenterScreen(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Notification Center'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'All'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Unread'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Workouts'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Schedule'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Goals'), findsOneWidget);
      
      // Scroll horizontal filter chips to view 'System'
      await tester.scrollUntilVisible(
        find.widgetWithText(ChoiceChip, 'System'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.widgetWithText(ChoiceChip, 'System'), findsOneWidget);
    });

    testWidgets('NotificationCenterScreen and NotificationSettingsScreen render cleanly in Dark Theme', (tester) async {
      final darkTheme = ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      );

      // 1. Center in Dark Mode
      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: const NotificationCenterScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Notification Center'), findsOneWidget);

      // 2. Settings in Dark Mode
      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: const NotificationSettingsScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Enable Notifications'), findsOneWidget);
    });
  });
}
