/// Data model representing the user's fitness profile and preferences.
class ProfileModel {
  final String fitnessLevel;
  final String previousExperience;
  final List<String> goals;
  final int workoutMinutes;
  final List<String> equipment;
  final List<String> weeklyRoutineDays;
  final List<String> preferredStyles;

  const ProfileModel({
    required this.fitnessLevel,
    this.previousExperience = 'No previous experience',
    required this.goals,
    required this.workoutMinutes,
    required this.equipment,
    this.weeklyRoutineDays = const ['M1', 'W', 'F'],
    this.preferredStyles = const ['HIIT', 'Yoga', 'Stretching'],
  });

  /// Factory constructor for creating a default profile matching the wireframe state
  factory ProfileModel.initial() {
    return const ProfileModel(
      fitnessLevel: 'Beginner',
      previousExperience: 'No previous experience',
      goals: ['Weight Loss'],
      workoutMinutes: 20,
      weeklyRoutineDays: ['M1', 'W', 'F'],
      preferredStyles: ['HIIT', 'Yoga', 'Stretching'],
      equipment: ['Bodyweight Only', 'Yoga / Exercise Mat'],
    );
  }

  /// Converts the profile to a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'fitnessLevel': fitnessLevel,
      'previousExperience': previousExperience,
      'goals': goals,
      'workoutMinutes': workoutMinutes,
      'equipment': equipment,
      'weeklyRoutineDays': weeklyRoutineDays,
      'preferredStyles': preferredStyles,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Factory constructor for reconstructing from a map.
  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    final rawDays = (map['weeklyRoutineDays'] as List<dynamic>?)?.map((e) => e.toString()).toList();
    final normalizedDays = rawDays?.map((d) => d == 'M' ? 'M1' : d).toList() ?? ['M1', 'W', 'F'];
    return ProfileModel(
      fitnessLevel: map['fitnessLevel'] as String? ?? 'Beginner',
      previousExperience: map['previousExperience'] as String? ?? 'No previous experience',
      goals: (map['goals'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['Weight Loss'],
      workoutMinutes: map['workoutMinutes'] as int? ?? 20,
      equipment: (map['equipment'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          ['Bodyweight Only', 'Yoga / Exercise Mat'],
      weeklyRoutineDays: normalizedDays,
      preferredStyles: (map['preferredStyles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          ['HIIT', 'Yoga', 'Stretching'],
    );
  }

  ProfileModel copyWith({
    String? fitnessLevel,
    String? previousExperience,
    List<String>? goals,
    int? workoutMinutes,
    List<String>? equipment,
    List<String>? weeklyRoutineDays,
    List<String>? preferredStyles,
  }) {
    return ProfileModel(
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      previousExperience: previousExperience ?? this.previousExperience,
      goals: goals ?? this.goals,
      workoutMinutes: workoutMinutes ?? this.workoutMinutes,
      equipment: equipment ?? this.equipment,
      weeklyRoutineDays: weeklyRoutineDays ?? this.weeklyRoutineDays,
      preferredStyles: preferredStyles ?? this.preferredStyles,
    );
  }

  @override
  String toString() =>
      'ProfileModel(fitnessLevel: $fitnessLevel, experience: $previousExperience, '
      'goals: $goals, workoutMinutes: $workoutMinutes, equipment: $equipment, '
      'weeklyRoutineDays: $weeklyRoutineDays, preferredStyles: $preferredStyles)';
}
