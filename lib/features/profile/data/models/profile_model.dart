/// Data model representing the user's fitness profile collected during setup.
class ProfileModel {
  final String fitnessLevel;
  final String previousExperience;
  final List<String> goals;
  final int workoutMinutes;
  final List<String> equipment;

  const ProfileModel({
    required this.fitnessLevel,
    required this.previousExperience,
    required this.goals,
    required this.workoutMinutes,
    required this.equipment,
  });

  /// Converts the profile to a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'fitnessLevel': fitnessLevel,
      'previousExperience': previousExperience,
      'goals': goals,
      'workoutMinutes': workoutMinutes,
      'equipment': equipment,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  @override
  String toString() =>
      'ProfileModel(fitnessLevel: $fitnessLevel, experience: $previousExperience, '
      'goals: $goals, workoutMinutes: $workoutMinutes, equipment: $equipment)';
}
