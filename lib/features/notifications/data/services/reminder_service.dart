import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:fitness_app/features/notifications/data/services/notification_service.dart';

class ReminderService {
  ReminderService._();

  static Timer? _reminderTimer;
  static DateTime? _lastTriggeredDate;

  static void initialize() {
    _startReminderCheck();
  }

  static void _startReminderCheck() {
    // In a real app, this would use android_alarm_manager_plus or workmanager
    // Since we don't have those dependencies, we simulate background checks
    // by running a periodic timer while the app is active.
    _reminderTimer?.cancel();
    _reminderTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAndTriggerReminders();
    });
    
    // Do an initial check
    _checkAndTriggerReminders();
  }

  static void _checkAndTriggerReminders() {
    final prefs = NotificationService.preferences;
    if (!prefs.workoutRemindersEnabled && !prefs.scheduledWorkoutRemindersEnabled) return;

    final now = DateTime.now();
    
    // Check if we already triggered today to prevent spam
    if (_lastTriggeredDate != null && 
        _lastTriggeredDate!.year == now.year &&
        _lastTriggeredDate!.month == now.month &&
        _lastTriggeredDate!.day == now.day) {
      return;
    }

    final currentDay = now.weekday; // 1 (Mon) to 7 (Sun)
    if (!prefs.selectedReminderDays.contains(currentDay)) return;

    if (_isQuietHours(now, prefs.quietHoursStart, prefs.quietHoursEnd)) {
      developer.log('Reminder skipped: Currently in quiet hours.', name: 'ReminderService');
      return;
    }

    final reminderTime = prefs.preferredReminderTime;
    
    // We trigger if the current time is at or slightly after the reminder time
    if (now.hour > reminderTime.hour || 
        (now.hour == reminderTime.hour && now.minute >= reminderTime.minute)) {
      
      NotificationService.addNotification(
        title: 'Time for your Workout!',
        message: "Your scheduled workout session is ready. Let's get moving!",
        category: 'workout_reminder',
      );

      _lastTriggeredDate = now;
      developer.log('Workout reminder triggered for today.', name: 'ReminderService');
    }
  }

  static bool _isQuietHours(DateTime now, TimeOfDay start, TimeOfDay end) {
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (startMinutes <= endMinutes) {
      // Quiet hours are within the same day (e.g. 10:00 to 18:00)
      return nowMinutes >= startMinutes && nowMinutes < endMinutes;
    } else {
      // Quiet hours cross midnight (e.g. 22:00 to 07:00)
      return nowMinutes >= startMinutes || nowMinutes < endMinutes;
    }
  }
}
