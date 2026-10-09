class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String category;
  final bool isRead;
  final DateTime createdAt;
  final String? relatedEntityType;
  final String? relatedEntityId;
  final String? actionUrl;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    this.isRead = false,
    required this.createdAt,
    this.relatedEntityType,
    this.relatedEntityId,
    this.actionUrl,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? category,
    bool? isRead,
    DateTime? createdAt,
    String? relatedEntityType,
    String? relatedEntityId,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'category': category,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'relatedEntityType': relatedEntityType,
      'relatedEntityId': relatedEntityId,
      'actionUrl': actionUrl,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    return NotificationModel(
      id: docId,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      category: map['category'] ?? 'general',
      isRead: map['isRead'] ?? false,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      relatedEntityType: map['relatedEntityType'],
      relatedEntityId: map['relatedEntityId'],
      actionUrl: map['actionUrl'],
    );
  }
}
