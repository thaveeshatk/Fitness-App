import 'package:fitness_app/features/workouts/data/models/workout_model.dart';

enum PlanItemStatus {
  completed,
  todayReady,
  upcoming,
}

/// Data model representing an individual workout session in the user's weekly plan.
/// Linked directly to a full [WorkoutModel] for seamless navigation to Workout Details.
class PlanScheduleItem {
  final String id;
  final String dayLabel; // e.g. 'MON', 'WED', 'FRI', 'SUN'
  final int dayNumber; // e.g. 13, 15, 17, 19
  final String dateRangeLabel; // e.g. 'Nov 13 – 19'
  final PlanItemStatus status;
  final String title;
  final int durationMinutes;
  final String category;
  final String? subtitleDetail; // e.g. 'Equipment Free', 'Strength'
  final String? adviceHighlight; // e.g. 'Gentle on knees • High calorie burn'
  final String? readyBadgeText; // e.g. 'READY'
  final String imageUrl;
  final WorkoutModel workout;

  const PlanScheduleItem({
    required this.id,
    required this.dayLabel,
    required this.dayNumber,
    this.dateRangeLabel = 'Nov 13 – 19',
    required this.status,
    required this.title,
    required this.durationMinutes,
    required this.category,
    this.subtitleDetail,
    this.adviceHighlight,
    this.readyBadgeText,
    required this.imageUrl,
    required this.workout,
  });

  bool get isCompleted => status == PlanItemStatus.completed;
  bool get isTodayReady => status == PlanItemStatus.todayReady;
  bool get isUpcoming => status == PlanItemStatus.upcoming;

  String get metaText {
    final buffer = StringBuffer('$durationMinutes min • $category');
    if (subtitleDetail != null && subtitleDetail!.isNotEmpty) {
      buffer.write(' • $subtitleDetail');
    }
    return buffer.toString();
  }

  PlanScheduleItem copyWith({
    String? id,
    String? dayLabel,
    int? dayNumber,
    String? dateRangeLabel,
    PlanItemStatus? status,
    String? title,
    int? durationMinutes,
    String? category,
    String? subtitleDetail,
    String? adviceHighlight,
    String? readyBadgeText,
    String? imageUrl,
    WorkoutModel? workout,
  }) {
    return PlanScheduleItem(
      id: id ?? this.id,
      dayLabel: dayLabel ?? this.dayLabel,
      dayNumber: dayNumber ?? this.dayNumber,
      dateRangeLabel: dateRangeLabel ?? this.dateRangeLabel,
      status: status ?? this.status,
      title: title ?? this.title,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      category: category ?? this.category,
      subtitleDetail: subtitleDetail ?? this.subtitleDetail,
      adviceHighlight: adviceHighlight ?? this.adviceHighlight,
      readyBadgeText: readyBadgeText ?? this.readyBadgeText,
      imageUrl: imageUrl ?? this.imageUrl,
      workout: workout ?? this.workout,
    );
  }
}
