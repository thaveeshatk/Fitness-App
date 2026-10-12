import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/features/workouts/data/services/workout_audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorkoutAudioService Tests', () {
    setUp(() {
      WorkoutAudioService.setMuted(false);
      WorkoutAudioService.setTheme(WorkoutAudioTheme.crystalBell);
    });

    test('Initial state is not muted with crystalBell theme', () {
      expect(WorkoutAudioService.isMuted, isFalse);
      expect(WorkoutAudioService.isMutedNotifier.value, isFalse);
      expect(WorkoutAudioService.currentTheme, WorkoutAudioTheme.crystalBell);
      expect(WorkoutAudioService.currentThemeNotifier.value, WorkoutAudioTheme.crystalBell);
    });

    test('toggleMute flips mute state correctly', () {
      WorkoutAudioService.toggleMute();
      expect(WorkoutAudioService.isMuted, isTrue);

      WorkoutAudioService.toggleMute();
      expect(WorkoutAudioService.isMuted, isFalse);
    });

    test('setMuted sets mute state explicitly', () {
      WorkoutAudioService.setMuted(true);
      expect(WorkoutAudioService.isMuted, isTrue);

      WorkoutAudioService.setMuted(false);
      expect(WorkoutAudioService.isMuted, isFalse);
    });

    test('setTheme changes theme correctly', () {
      WorkoutAudioService.setTheme(WorkoutAudioTheme.warmMarimba);
      expect(WorkoutAudioService.currentTheme, WorkoutAudioTheme.warmMarimba);

      WorkoutAudioService.setTheme(WorkoutAudioTheme.athleticStudio);
      expect(WorkoutAudioService.currentTheme, WorkoutAudioTheme.athleticStudio);
    });

    test('Audio cue methods execute without throwing for all themes', () {
      for (final theme in WorkoutAudioTheme.values) {
        WorkoutAudioService.setTheme(theme);
        expect(() => WorkoutAudioService.playCountdownBeep(), returnsNormally);
        expect(() => WorkoutAudioService.playFinishChime(), returnsNormally);
        expect(() => WorkoutAudioService.playStartWhistle(), returnsNormally);
        expect(() => WorkoutAudioService.playFinishChime(themeOverride: theme), returnsNormally);
        expect(() => WorkoutAudioService.playStartWhistle(themeOverride: theme), returnsNormally);
      }
    });

    test('Audio cue methods execute without throwing when muted', () {
      WorkoutAudioService.setMuted(true);
      expect(() => WorkoutAudioService.playCountdownBeep(), returnsNormally);
      expect(() => WorkoutAudioService.playFinishChime(), returnsNormally);
      expect(() => WorkoutAudioService.playStartWhistle(), returnsNormally);
    });
  });
}
