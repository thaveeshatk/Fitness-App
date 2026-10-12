import 'package:flutter/foundation.dart';
import 'workout_audio_service_stub.dart'
    if (dart.library.html) 'workout_audio_service_web.dart';

/// Available premium sound themes for workout acoustic cues
enum WorkoutAudioTheme {
  crystalBell(
    'Crystal Bell (Apple style)',
    'Bright, luxurious harmonic chime with warm decay',
  ),
  warmMarimba(
    'Warm Marimba (Acoustic)',
    'Soft, wooden organic resonance with gentle tone',
  ),
  athleticStudio(
    'Athletic Studio (Nike style)',
    'Punchy, high-energy gym cues with crisp clarity',
  );

  final String title;
  final String subtitle;
  const WorkoutAudioTheme(this.title, this.subtitle);
}

/// Service providing acoustic cues (countdown beeps, finish chime, and start whistle)
/// for active workout sessions. Synthesizes pristine Web Audio in browser and uses
/// system audio/haptics on mobile, requiring zero asset files or heavy dependencies.
class WorkoutAudioService {
  WorkoutAudioService._();

  static final ValueNotifier<bool> isMutedNotifier = ValueNotifier<bool>(false);
  static final ValueNotifier<WorkoutAudioTheme> currentThemeNotifier =
      ValueNotifier<WorkoutAudioTheme>(WorkoutAudioTheme.crystalBell);

  static bool get isMuted => isMutedNotifier.value;
  static WorkoutAudioTheme get currentTheme => currentThemeNotifier.value;

  static void toggleMute() {
    isMutedNotifier.value = !isMutedNotifier.value;
  }

  static void setMuted(bool muted) {
    isMutedNotifier.value = muted;
  }

  static void setTheme(WorkoutAudioTheme theme) {
    currentThemeNotifier.value = theme;
  }

  /// Plays short preparatory countdown beep (at 3, 2, 1)
  static void playCountdownBeep() {
    if (isMuted) return;
    WorkoutAudioServiceImpl.playCountdownBeep(currentTheme.name);
  }

  /// Plays rewarding, distinctive chime when active set/exercise finishes
  static void playFinishChime({WorkoutAudioTheme? themeOverride}) {
    if (isMuted && themeOverride == null) return;
    WorkoutAudioServiceImpl.playFinishChime((themeOverride ?? currentTheme).name);
  }

  /// Plays energetic start whistle/cue when rest finishes or is skipped
  static void playStartWhistle({WorkoutAudioTheme? themeOverride}) {
    if (isMuted && themeOverride == null) return;
    WorkoutAudioServiceImpl.playStartWhistle((themeOverride ?? currentTheme).name);
  }
}
