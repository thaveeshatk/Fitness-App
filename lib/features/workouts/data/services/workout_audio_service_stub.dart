import 'package:flutter/services.dart';

class WorkoutAudioServiceImpl {
  static void playCountdownBeep(String theme) {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.selectionClick();
  }

  static void playFinishChime(String theme) {
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.heavyImpact();
  }

  static void playStartWhistle(String theme) {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.mediumImpact();
  }
}
