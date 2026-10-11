/// Configuration model for user notification settings and reminder preferences
class NotificationPreferences {
  final bool enabled;
  final bool workoutReminders;
  final bool scheduleReminders;
  final bool goalNotifications;
  final bool progressUpdates;
  final bool adaptivePlanUpdates;
  final bool motivationalNotifications;
  final String reminderTime;
  final List<String> reminderDays;

  const NotificationPreferences({
    this.enabled = true,
    this.workoutReminders = true,
    this.scheduleReminders = true,
    this.goalNotifications = true,
    this.progressUpdates = true,
    this.adaptivePlanUpdates = true,
    this.motivationalNotifications = true,
    this.reminderTime = '18:00',
    this.reminderDays = const ['Monday', 'Wednesday', 'Friday'],
  });

  /// Factory for standard sensible default preferences
  factory NotificationPreferences.defaults() {
    return const NotificationPreferences(
      enabled: true,
      workoutReminders: true,
      scheduleReminders: true,
      goalNotifications: true,
      progressUpdates: true,
      adaptivePlanUpdates: true,
      motivationalNotifications: true,
      reminderTime: '18:00',
      reminderDays: ['Monday', 'Wednesday', 'Friday'],
    );
  }

  NotificationPreferences copyWith({
    bool? enabled,
    bool? workoutReminders,
    bool? scheduleReminders,
    bool? goalNotifications,
    bool? progressUpdates,
    bool? adaptivePlanUpdates,
    bool? motivationalNotifications,
    String? reminderTime,
    List<String>? reminderDays,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      workoutReminders: workoutReminders ?? this.workoutReminders,
      scheduleReminders: scheduleReminders ?? this.scheduleReminders,
      goalNotifications: goalNotifications ?? this.goalNotifications,
      progressUpdates: progressUpdates ?? this.progressUpdates,
      adaptivePlanUpdates: adaptivePlanUpdates ?? this.adaptivePlanUpdates,
      motivationalNotifications:
          motivationalNotifications ?? this.motivationalNotifications,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderDays: reminderDays ?? this.reminderDays,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'workoutReminders': workoutReminders,
      'scheduleReminders': scheduleReminders,
      'goalNotifications': goalNotifications,
      'progressUpdates': progressUpdates,
      'adaptivePlanUpdates': adaptivePlanUpdates,
      'motivationalNotifications': motivationalNotifications,
      'reminderTime': reminderTime,
      'reminderDays': reminderDays,
    };
  }

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    List<String> parsedDays;
    if (map['reminderDays'] is List) {
      parsedDays = (map['reminderDays'] as List)
          .map((e) => e.toString())
          .toList();
    } else {
      parsedDays = ['Monday', 'Wednesday', 'Friday'];
    }

    return NotificationPreferences(
      enabled: map['enabled'] ?? true,
      workoutReminders: map['workoutReminders'] ?? true,
      scheduleReminders: map['scheduleReminders'] ?? true,
      goalNotifications: map['goalNotifications'] ?? true,
      progressUpdates: map['progressUpdates'] ?? true,
      adaptivePlanUpdates: map['adaptivePlanUpdates'] ?? true,
      motivationalNotifications: map['motivationalNotifications'] ?? true,
      reminderTime: map['reminderTime']?.toString() ?? '18:00',
      reminderDays: parsedDays,
    );
  }
}
