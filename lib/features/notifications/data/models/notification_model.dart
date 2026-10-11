import 'package:flutter/material.dart';

/// Supported categories for application notifications
enum NotificationType {
  workout,
  schedule,
  goal,
  progress,
  adaptivePlan,
  system;

  static NotificationType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'workout':
        return NotificationType.workout;
      case 'schedule':
        return NotificationType.schedule;
      case 'goal':
        return NotificationType.goal;
      case 'progress':
        return NotificationType.progress;
      case 'adaptiveplan':
      case 'adaptive_plan':
      case 'plan':
        return NotificationType.adaptivePlan;
      case 'system':
      default:
        return NotificationType.system;
    }
  }

  String get displayName {
    switch (this) {
      case NotificationType.workout:
        return 'Workout';
      case NotificationType.schedule:
        return 'Schedule';
      case NotificationType.goal:
        return 'Goal & Milestone';
      case NotificationType.progress:
        return 'Progress';
      case NotificationType.adaptivePlan:
        return 'Adaptive Plan';
      case NotificationType.system:
        return 'System & Account';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.workout:
        return Icons.fitness_center_rounded;
      case NotificationType.schedule:
        return Icons.calendar_today_rounded;
      case NotificationType.goal:
        return Icons.emoji_events_rounded;
      case NotificationType.progress:
        return Icons.trending_up_rounded;
      case NotificationType.adaptivePlan:
        return Icons.auto_awesome_rounded;
      case NotificationType.system:
        return Icons.notifications_rounded;
    }
  }

  Color get iconColor {
    switch (this) {
      case NotificationType.workout:
        return const Color(0xFF00635A); // Teal
      case NotificationType.schedule:
        return const Color(0xFF0284C7); // Sky Blue
      case NotificationType.goal:
        return const Color(0xFFD97706); // Amber / Gold
      case NotificationType.progress:
        return const Color(0xFF7C3AED); // Purple
      case NotificationType.adaptivePlan:
        return const Color(0xFF059669); // Emerald
      case NotificationType.system:
        return const Color(0xFF475569); // Slate
    }
  }

  Color get iconBackgroundColor {
    switch (this) {
      case NotificationType.workout:
        return const Color(0xFFE6FAF3);
      case NotificationType.schedule:
        return const Color(0xFFE0F2FE);
      case NotificationType.goal:
        return const Color(0xFFFEF3C7);
      case NotificationType.progress:
        return const Color(0xFFEDE9FE);
      case NotificationType.adaptivePlan:
        return const Color(0xFFD1FAE5);
      case NotificationType.system:
        return const Color(0xFFF1F5F9);
    }
  }
}

/// Represents an individual notification in the application
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final String? eventKey;
  final String? actionRoute;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    this.eventKey,
    this.actionRoute,
    required this.createdAt,
    this.metadata,
  });

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    bool? isRead,
    String? eventKey,
    String? actionRoute,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      eventKey: eventKey ?? this.eventKey,
      actionRoute: actionRoute ?? this.actionRoute,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.name,
      'isRead': isRead,
      if (eventKey != null) 'eventKey': eventKey,
      if (actionRoute != null) 'actionRoute': actionRoute,
      'createdAt': createdAt.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    if (map['createdAt'] is String) {
      parsedDate = DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return NotificationModel(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      type: NotificationType.fromString(map['type']?.toString()),
      isRead: map['isRead'] == true,
      eventKey: map['eventKey']?.toString(),
      actionRoute: map['actionRoute']?.toString(),
      createdAt: parsedDate,
      metadata: map['metadata'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(map['metadata'] as Map)
          : null,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '$mins ${mins == 1 ? "min" : "mins"} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? "hour" : "hours"} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? "day" : "days"} ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}
