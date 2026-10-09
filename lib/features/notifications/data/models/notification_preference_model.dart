import 'package:flutter/material.dart';

class NotificationPreferenceModel {
  final bool workoutRemindersEnabled;
  final bool scheduledWorkoutRemindersEnabled;
  final bool dailyRemindersEnabled;
  final bool weeklyReportsEnabled;
  final bool goalAchievementsEnabled;
  final bool adaptivePlanUpdatesEnabled;
  final bool workoutCompletionEnabled;
  final bool inactivityRemindersEnabled;
  final bool generalNotificationsEnabled;
  
  final TimeOfDay preferredReminderTime;
  final List<int> selectedReminderDays; // 1 (Mon) to 7 (Sun)
  final TimeOfDay quietHoursStart;
  final TimeOfDay quietHoursEnd;
  
  final bool inAppNotificationsEnabled;
  final bool pushNotificationsEnabled;

  const NotificationPreferenceModel({
    this.workoutRemindersEnabled = true,
    this.scheduledWorkoutRemindersEnabled = true,
    this.dailyRemindersEnabled = false,
    this.weeklyReportsEnabled = true,
    this.goalAchievementsEnabled = true,
    this.adaptivePlanUpdatesEnabled = true,
    this.workoutCompletionEnabled = true,
    this.inactivityRemindersEnabled = true,
    this.generalNotificationsEnabled = true,
    this.preferredReminderTime = const TimeOfDay(hour: 8, minute: 0),
    this.selectedReminderDays = const [1, 2, 3, 4, 5],
    this.quietHoursStart = const TimeOfDay(hour: 22, minute: 0),
    this.quietHoursEnd = const TimeOfDay(hour: 7, minute: 0),
    this.inAppNotificationsEnabled = true,
    this.pushNotificationsEnabled = false,
  });

  NotificationPreferenceModel copyWith({
    bool? workoutRemindersEnabled,
    bool? scheduledWorkoutRemindersEnabled,
    bool? dailyRemindersEnabled,
    bool? weeklyReportsEnabled,
    bool? goalAchievementsEnabled,
    bool? adaptivePlanUpdatesEnabled,
    bool? workoutCompletionEnabled,
    bool? inactivityRemindersEnabled,
    bool? generalNotificationsEnabled,
    TimeOfDay? preferredReminderTime,
    List<int>? selectedReminderDays,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
    bool? inAppNotificationsEnabled,
    bool? pushNotificationsEnabled,
  }) {
    return NotificationPreferenceModel(
      workoutRemindersEnabled: workoutRemindersEnabled ?? this.workoutRemindersEnabled,
      scheduledWorkoutRemindersEnabled: scheduledWorkoutRemindersEnabled ?? this.scheduledWorkoutRemindersEnabled,
      dailyRemindersEnabled: dailyRemindersEnabled ?? this.dailyRemindersEnabled,
      weeklyReportsEnabled: weeklyReportsEnabled ?? this.weeklyReportsEnabled,
      goalAchievementsEnabled: goalAchievementsEnabled ?? this.goalAchievementsEnabled,
      adaptivePlanUpdatesEnabled: adaptivePlanUpdatesEnabled ?? this.adaptivePlanUpdatesEnabled,
      workoutCompletionEnabled: workoutCompletionEnabled ?? this.workoutCompletionEnabled,
      inactivityRemindersEnabled: inactivityRemindersEnabled ?? this.inactivityRemindersEnabled,
      generalNotificationsEnabled: generalNotificationsEnabled ?? this.generalNotificationsEnabled,
      preferredReminderTime: preferredReminderTime ?? this.preferredReminderTime,
      selectedReminderDays: selectedReminderDays ?? this.selectedReminderDays,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      inAppNotificationsEnabled: inAppNotificationsEnabled ?? this.inAppNotificationsEnabled,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workoutRemindersEnabled': workoutRemindersEnabled,
      'scheduledWorkoutRemindersEnabled': scheduledWorkoutRemindersEnabled,
      'dailyRemindersEnabled': dailyRemindersEnabled,
      'weeklyReportsEnabled': weeklyReportsEnabled,
      'goalAchievementsEnabled': goalAchievementsEnabled,
      'adaptivePlanUpdatesEnabled': adaptivePlanUpdatesEnabled,
      'workoutCompletionEnabled': workoutCompletionEnabled,
      'inactivityRemindersEnabled': inactivityRemindersEnabled,
      'generalNotificationsEnabled': generalNotificationsEnabled,
      'preferredReminderTime': '${preferredReminderTime.hour}:${preferredReminderTime.minute}',
      'selectedReminderDays': selectedReminderDays,
      'quietHoursStart': '${quietHoursStart.hour}:${quietHoursStart.minute}',
      'quietHoursEnd': '${quietHoursEnd.hour}:${quietHoursEnd.minute}',
      'inAppNotificationsEnabled': inAppNotificationsEnabled,
      'pushNotificationsEnabled': pushNotificationsEnabled,
    };
  }

  factory NotificationPreferenceModel.fromMap(Map<String, dynamic> map) {
    TimeOfDay parseTime(String? timeStr) {
      if (timeStr == null) return const TimeOfDay(hour: 8, minute: 0);
      final parts = timeStr.split(':');
      if (parts.length != 2) return const TimeOfDay(hour: 8, minute: 0);
      return TimeOfDay(hour: int.tryParse(parts[0]) ?? 8, minute: int.tryParse(parts[1]) ?? 0);
    }

    return NotificationPreferenceModel(
      workoutRemindersEnabled: map['workoutRemindersEnabled'] ?? true,
      scheduledWorkoutRemindersEnabled: map['scheduledWorkoutRemindersEnabled'] ?? true,
      dailyRemindersEnabled: map['dailyRemindersEnabled'] ?? false,
      weeklyReportsEnabled: map['weeklyReportsEnabled'] ?? true,
      goalAchievementsEnabled: map['goalAchievementsEnabled'] ?? true,
      adaptivePlanUpdatesEnabled: map['adaptivePlanUpdatesEnabled'] ?? true,
      workoutCompletionEnabled: map['workoutCompletionEnabled'] ?? true,
      inactivityRemindersEnabled: map['inactivityRemindersEnabled'] ?? true,
      generalNotificationsEnabled: map['generalNotificationsEnabled'] ?? true,
      preferredReminderTime: parseTime(map['preferredReminderTime']),
      selectedReminderDays: (map['selectedReminderDays'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [1, 2, 3, 4, 5],
      quietHoursStart: parseTime(map['quietHoursStart'] ?? '22:0'),
      quietHoursEnd: parseTime(map['quietHoursEnd'] ?? '7:0'),
      inAppNotificationsEnabled: map['inAppNotificationsEnabled'] ?? true,
      pushNotificationsEnabled: map['pushNotificationsEnabled'] ?? false,
    );
  }
}
