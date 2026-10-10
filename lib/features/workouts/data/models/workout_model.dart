class ExerciseItem {
  final String id;
  final String name;
  final String phase; // e.g. 'PHASE: PREP', 'PHASE: LOWER', 'PHASE: UPPER PUSH'
  final String subtitle; // e.g. 'Dynamic movement', 'Primary compound'
  final String badge; // e.g. '3 min', '3 sets × 12 reps'
  final String imageUrl;

  final String? target;
  final List<String>? steps;
  final String? techniquePoints;
  final String? safetyTips;
  final String? videoThumbnail;
  final String? videoUrl;
  final String? videoAsset;

  const ExerciseItem({
    required this.id,
    required this.name,
    required this.phase,
    required this.subtitle,
    required this.badge,
    required this.imageUrl,
    this.target,
    this.steps,
    this.techniquePoints,
    this.safetyTips,
    this.videoThumbnail,
    this.videoUrl,
    this.videoAsset,
  });

  bool get hasVideo => false;

  String get displayPhase {
    if (phase == 'PHASE: LOWER') return 'PHASE: LOWER BODY';
    if (phase == 'PHASE: UPPER PUSH') return 'PHASE: UPPER BODY';
    if (phase == 'PHASE: UPPER PULL') return 'PHASE: UPPER BODY';
    if (phase == 'PHASE: PREP') return 'PHASE: WARM-UP';
    if (phase == 'PHASE: CORE') return 'PHASE: CORE STABILITY';
    if (phase == 'PHASE: RECOVERY') return 'PHASE: COOLDOWN';
    return phase;
  }

  String get targetMuscles {
    if (target != null && target!.isNotEmpty) return target!;
    final lowerName = name.toLowerCase();
    if (lowerName.contains('squat') || lowerName.contains('lunge') || lowerName.contains('leg')) {
      return 'Target: Quads & Glutes';
    } else if (lowerName.contains('push-up') || lowerName.contains('chest') || lowerName.contains('press')) {
      return 'Target: Chest & Triceps';
    } else if (lowerName.contains('row') || lowerName.contains('pull')) {
      return 'Target: Lats & Upper Back';
    } else if (lowerName.contains('plank') || lowerName.contains('core') || lowerName.contains('crunch')) {
      return 'Target: Core & Abdominals';
    } else if (lowerName.contains('jump') || lowerName.contains('burpee') || lowerName.contains('jack')) {
      return 'Target: Full Body & Cardio';
    } else if (lowerName.contains('stretch') || lowerName.contains('mobility') || lowerName.contains('yoga')) {
      return 'Target: Full Body Mobility';
    }
    return 'Target: Quads & Glutes';
  }

  List<String> get executionSteps {
    if (steps != null && steps!.isNotEmpty) return steps!;
    final lowerName = name.toLowerCase();
    if (lowerName.contains('squat')) {
      return const [
        'Stand with feet shoulder-width apart holding dumbbells at shoulder level.',
        'Lower your hips back and down as if sitting into a chair.',
        'Keep chest upright and knees tracking over toes.',
        'Drive through midfoot and heels to return to starting position.',
      ];
    } else if (lowerName.contains('push-up')) {
      return const [
        'Place hands shoulder-width apart on the floor with body straight.',
        'Engage your core and lower your chest until hovering above the floor.',
        'Keep elbows angled back at 45 degrees relative to your ribs.',
        'Press firmly through palms to return to full arm extension.',
      ];
    } else if (lowerName.contains('row')) {
      return const [
        'Hinge forward at hips keeping back flat and spine neutral.',
        'Hold weights hanging naturally in front with palms facing inward.',
        'Pull elbows straight back squeezing shoulder blades together.',
        'Lower weights under control back to starting extended position.',
      ];
    } else if (lowerName.contains('plank')) {
      return const [
        'Place forearms on the floor with elbows directly under shoulders.',
        'Extend legs straight back with toes tucked under firmly.',
        'Form a straight line from heels to crown of head without sagging.',
        'Breathe rhythmically while actively bracing abdominal wall.',
      ];
    } else if (lowerName.contains('jack') || lowerName.contains('jump')) {
      return const [
        'Stand upright with feet together and arms relaxed by your sides.',
        'Jump feet outward while sweeping arms upward in an arc overhead.',
        'Land softly on balls of feet with knees slightly bent.',
        'Quickly reverse movement to return to original standing stance.',
      ];
    } else if (lowerName.contains('stretch')) {
      return const [
        'Begin in a tall, relaxed posture and initiate slow diaphragmatic breaths.',
        'Gently lengthen target muscle group until feeling mild tension.',
        'Hold stretch statically without bouncing or straining.',
        'Exhale slowly to release tension and return smoothly.',
      ];
    }
    return const [
      'Assume a balanced starting stance with core braced and posture tall.',
      'Initiate controlled movement through full active range of motion.',
      'Maintain steady breathing cadence and focus on muscle tension.',
      'Return smoothly to the initial position ready for the next repetition.',
    ];
  }

  String get techniqueCue {
    if (techniquePoints != null && techniquePoints!.isNotEmpty) return techniquePoints!;
    final lowerName = name.toLowerCase();
    if (lowerName.contains('squat')) {
      return 'Core braced, knees outward, spine neutral throughout movement.';
    } else if (lowerName.contains('push-up')) {
      return 'Core braced, neck neutral, elbows tucked at 45-degree angle.';
    } else if (lowerName.contains('row')) {
      return 'Retract scapulae first, pull to lower ribs, maintain neutral spine.';
    } else if (lowerName.contains('plank')) {
      return 'Squeeze glutes tight, push floor away through forearms, brace core.';
    } else if (lowerName.contains('stretch')) {
      return 'Deep diaphragmatic breathing, release muscular tension gradually.';
    }
    return 'Core braced, knees outward, spine neutral throughout movement.';
  }

  String get safetyCue {
    if (safetyTips != null && safetyTips!.isNotEmpty) return safetyTips!;
    final lowerName = name.toLowerCase();
    if (lowerName.contains('squat')) {
      return 'Do not let knees cave inward. Avoid rounding the lower back under load.';
    } else if (lowerName.contains('push-up')) {
      return 'Avoid letting hips sag or flare elbows out 90 degrees to protect shoulders.';
    } else if (lowerName.contains('row')) {
      return 'Do not jerk weights using lumbar hyperextension or cervical strain.';
    } else if (lowerName.contains('plank')) {
      return 'Stop immediately if lower back pinches or arches excessively.';
    } else if (lowerName.contains('stretch')) {
      return 'Never force past mild discomfort. Avoid ballistic bouncing.';
    }
    return 'Do not let knees cave inward. Avoid rounding the lower back under load.';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phase': phase,
      'subtitle': subtitle,
      'badge': badge,
      'imageUrl': imageUrl,
      if (target != null) 'target': target,
      if (steps != null) 'steps': steps,
      if (techniquePoints != null) 'techniquePoints': techniquePoints,
      if (safetyTips != null) 'safetyTips': safetyTips,
    };
  }

  factory ExerciseItem.fromMap(Map<String, dynamic> map) {
    return ExerciseItem(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      phase: map['phase']?.toString() ?? 'PHASE: MAIN',
      subtitle: map['subtitle']?.toString() ?? 'Dynamic movement',
      badge: map['badge']?.toString() ?? '3 sets',
      imageUrl: map['imageUrl']?.toString() ?? 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=1200&auto=format&fit=crop',
      target: map['target']?.toString(),
      steps: map['steps'] != null ? List<String>.from(map['steps'] as List) : null,
      techniquePoints: map['techniquePoints']?.toString(),
      safetyTips: map['safetyTips']?.toString(),
    );
  }

  ExerciseItem copyWith({
    String? id,
    String? name,
    String? phase,
    String? subtitle,
    String? badge,
    String? imageUrl,
    String? target,
    List<String>? steps,
    String? techniquePoints,
    String? safetyTips,
  }) {
    return ExerciseItem(
      id: id ?? this.id,
      name: name ?? this.name,
      phase: phase ?? this.phase,
      subtitle: subtitle ?? this.subtitle,
      badge: badge ?? this.badge,
      imageUrl: imageUrl ?? this.imageUrl,
      target: target ?? this.target,
      steps: steps ?? this.steps,
      techniquePoints: techniquePoints ?? this.techniquePoints,
      safetyTips: safetyTips ?? this.safetyTips,
    );
  }
}

class WorkoutModel {
  final String id;
  final String title;
  final String specificationSubtitle;
  final String coach;
  final String coachRole;
  final String coachAvatar;
  final double rating;
  final int durationMinutes;
  final int calories;
  final String category; // 'Cardio', 'Strength', 'HIIT', 'Yoga', 'Mobility'
  final String subCategory; // e.g. 'STRENGTH & HYPERTROPHY'
  final String difficulty; // 'Beginner', 'Intermediate', 'Advanced'
  final List<String> equipment;
  final List<String> tags;
  final String imageUrl;
  final String overview;
  final String safetyInfo;
  final List<ExerciseItem> exercises;
  final String? userId;
  final bool isCustom;

  const WorkoutModel({
    required this.id,
    this.userId,
    required this.title,
    this.specificationSubtitle = 'Architectural wireframe specification • Version 2.0 layout evaluation',
    required this.coach,
    this.coachRole = 'Lead Fitness Coach',
    required this.coachAvatar,
    required this.rating,
    required this.durationMinutes,
    required this.calories,
    required this.category,
    required this.subCategory,
    required this.difficulty,
    required this.equipment,
    required this.tags,
    required this.imageUrl,
    required this.overview,
    this.safetyInfo = 'Warm up thoroughly before starting. Maintain a neutral spine during squats and rows. Stop immediately if you feel sharp joint pain.',
    required this.exercises,
    this.isCustom = false,
  });

  WorkoutModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? specificationSubtitle,
    String? coach,
    String? coachRole,
    String? coachAvatar,
    double? rating,
    int? durationMinutes,
    int? calories,
    String? category,
    String? subCategory,
    String? difficulty,
    List<String>? equipment,
    List<String>? tags,
    String? imageUrl,
    String? overview,
    String? safetyInfo,
    List<ExerciseItem>? exercises,
    bool? isCustom,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      specificationSubtitle: specificationSubtitle ?? this.specificationSubtitle,
      coach: coach ?? this.coach,
      coachRole: coachRole ?? this.coachRole,
      coachAvatar: coachAvatar ?? this.coachAvatar,
      rating: rating ?? this.rating,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      calories: calories ?? this.calories,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      difficulty: difficulty ?? this.difficulty,
      equipment: equipment ?? this.equipment,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      overview: overview ?? this.overview,
      safetyInfo: safetyInfo ?? this.safetyInfo,
      exercises: exercises ?? this.exercises,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      if (userId != null) 'userId': userId,
      'title': title,
      'specificationSubtitle': specificationSubtitle,
      'coach': coach,
      'coachRole': coachRole,
      'coachAvatar': coachAvatar,
      'rating': rating,
      'durationMinutes': durationMinutes,
      'calories': calories,
      'category': category,
      'subCategory': subCategory,
      'difficulty': difficulty,
      'equipment': equipment,
      'tags': tags,
      'imageUrl': imageUrl,
      'overview': overview,
      'safetyInfo': safetyInfo,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'isCustom': isCustom,
    };
  }

  factory WorkoutModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return WorkoutModel(
      id: docId ?? map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? map['ownerId']?.toString(),
      title: map['title']?.toString() ?? 'Custom Workout',
      specificationSubtitle: map['specificationSubtitle']?.toString() ?? 'Custom Routine • Personalized Training',
      coach: map['coach']?.toString() ?? 'You (Custom)',
      coachRole: map['coachRole']?.toString() ?? 'Personal Workout',
      coachAvatar: map['coachAvatar']?.toString() ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150&auto=format&fit=crop',
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 25,
      calories: (map['calories'] as num?)?.toInt() ?? 200,
      category: map['category']?.toString() ?? 'Cardio',
      subCategory: map['subCategory']?.toString() ?? 'CUSTOM ROUTINE',
      difficulty: map['difficulty']?.toString() ?? 'Intermediate',
      equipment: map['equipment'] != null
          ? List<String>.from(map['equipment'] as List)
          : ['None / Bodyweight'],
      tags: map['tags'] != null
          ? List<String>.from(map['tags'] as List)
          : ['CUSTOM', 'MY ROUTINE'],
      imageUrl: map['imageUrl']?.toString() ?? 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=600&auto=format&fit=crop',
      overview: map['overview']?.toString() ?? 'Personalized circuit routine crafted for optimal progression.',
      safetyInfo: map['safetyInfo']?.toString() ?? 'Warm up thoroughly before starting. Maintain proper form.',
      exercises: map['exercises'] != null
          ? (map['exercises'] as List)
              .map((e) => ExerciseItem.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList()
          : [],
      isCustom: map['isCustom'] as bool? ?? true,
    );
  }
}
