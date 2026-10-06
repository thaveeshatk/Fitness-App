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

  const WorkoutModel({
    required this.id,
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
  });
}
