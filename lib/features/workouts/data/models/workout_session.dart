import 'dart:convert';

class WorkoutSession {
  final String id;
  final String title;
  final String category;
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;
  final int calories;
  final int exercisesCompleted;
  final String coachName;
  final String coachAvatar;

  const WorkoutSession({
    required this.id,
    required this.title,
    required this.category,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    required this.calories,
    required this.exercisesCompleted,
    this.coachName = '',
    this.coachAvatar = '',
  });

  int get durationMinutes => (durationSeconds / 60).ceil();
  int get activeMinutes => (durationSeconds / 60).floor();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationSeconds': durationSeconds,
      'calories': calories,
      'exercisesCompleted': exercisesCompleted,
      'coachName': coachName,
      'coachAvatar': coachAvatar,
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Workout',
      category: map['category']?.toString() ?? 'Strength',
      startTime: DateTime.tryParse(map['startTime']?.toString() ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(map['endTime']?.toString() ?? '') ?? DateTime.now(),
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      exercisesCompleted: (map['exercisesCompleted'] as num?)?.toInt() ?? 0,
      coachName: map['coachName']?.toString() ?? '',
      coachAvatar: map['coachAvatar']?.toString() ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory WorkoutSession.fromJson(String source) =>
      WorkoutSession.fromMap(json.decode(source) as Map<String, dynamic>);
}
