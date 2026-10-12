import 'dart:js_interop';

@JS('eval')
external JSAny? _jsEval(String code);

class WorkoutAudioServiceImpl {
  static void playCountdownBeep(String theme) {
    try {
      _jsEval('''
        (function(theme) {
          try {
            var AudioCtx = window.AudioContext || window.webkitAudioContext;
            if (!AudioCtx) return;
            window._fitonAudioCtx = window._fitonAudioCtx || new AudioCtx();
            var ctx = window._fitonAudioCtx;
            if (ctx.state === 'suspended') ctx.resume();

            var t = ctx.currentTime;
            var osc = ctx.createOscillator();
            var gain = ctx.createGain();
            var filter = ctx.createBiquadFilter();

            if (theme === 'warmMarimba') {
              filter.type = 'lowpass';
              filter.frequency.setValueAtTime(1400, t);
              osc.type = 'sine';
              osc.frequency.setValueAtTime(440, t);
              osc.frequency.exponentialRampToValueAtTime(360, t + 0.05);

              gain.gain.setValueAtTime(0.0001, t);
              gain.gain.linearRampToValueAtTime(0.20, t + 0.008);
              gain.gain.exponentialRampToValueAtTime(0.0001, t + 0.09);
            } else if (theme === 'athleticStudio') {
              filter.type = 'lowpass';
              filter.frequency.setValueAtTime(2800, t);
              osc.type = 'triangle';
              osc.frequency.setValueAtTime(750, t);

              gain.gain.setValueAtTime(0.0001, t);
              gain.gain.linearRampToValueAtTime(0.18, t + 0.005);
              gain.gain.exponentialRampToValueAtTime(0.0001, t + 0.08);
            } else {
              // Crystal Bell (Modern rounded studio pop - default)
              filter.type = 'lowpass';
              filter.frequency.setValueAtTime(2200, t);
              osc.type = 'sine';
              osc.frequency.setValueAtTime(620, t);
              osc.frequency.exponentialRampToValueAtTime(480, t + 0.05);

              gain.gain.setValueAtTime(0.0001, t);
              gain.gain.linearRampToValueAtTime(0.17, t + 0.008);
              gain.gain.exponentialRampToValueAtTime(0.0001, t + 0.10);
            }

            osc.connect(gain);
            gain.connect(filter);
            filter.connect(ctx.destination);

            osc.start(t);
            osc.stop(t + 0.11);
          } catch(e) {}
        })('$theme');
      ''');
    } catch (_) {}
  }

  static void playFinishChime(String theme) {
    try {
      _jsEval('''
        (function(theme) {
          try {
            var AudioCtx = window.AudioContext || window.webkitAudioContext;
            if (!AudioCtx) return;
            window._fitonAudioCtx = window._fitonAudioCtx || new AudioCtx();
            var ctx = window._fitonAudioCtx;
            if (ctx.state === 'suspended') ctx.resume();

            function playNote(freq, startTime, duration, gainVal, overtoneRatio, filterFreq, oscType) {
              var osc1 = ctx.createOscillator();
              var gain1 = ctx.createGain();
              var filter = ctx.createBiquadFilter();

              filter.type = 'lowpass';
              filter.frequency.setValueAtTime(filterFreq || 3400, startTime);

              osc1.type = oscType || 'sine';
              osc1.frequency.setValueAtTime(freq, startTime);

              gain1.gain.setValueAtTime(0.0001, startTime);
              gain1.gain.linearRampToValueAtTime(gainVal, startTime + 0.012);
              gain1.gain.exponentialRampToValueAtTime(0.0001, startTime + duration);

              osc1.connect(gain1);
              gain1.connect(filter);
              filter.connect(ctx.destination);

              osc1.start(startTime);
              osc1.stop(startTime + duration);

              if (overtoneRatio) {
                var osc2 = ctx.createOscillator();
                var gain2 = ctx.createGain();
                osc2.type = 'sine';
                osc2.frequency.setValueAtTime(freq * overtoneRatio, startTime);

                gain2.gain.setValueAtTime(0.0001, startTime);
                gain2.gain.linearRampToValueAtTime(gainVal * 0.22, startTime + 0.008);
                gain2.gain.exponentialRampToValueAtTime(0.0001, startTime + Math.min(duration, 0.28));

                osc2.connect(gain2);
                gain2.connect(filter);
                osc2.start(startTime);
                osc2.stop(startTime + Math.min(duration, 0.28));
              }
            }

            var t = ctx.currentTime;
            if (theme === 'warmMarimba') {
              // Warm 3-tone Marimba chord: D5 (587.33), F#5 (739.99), A5 (880.0)
              playNote(587.33, t, 0.45, 0.20, 2.0, 1800);
              playNote(739.99, t + 0.07, 0.55, 0.22, 2.0, 2000);
              playNote(880.0, t + 0.14, 0.90, 0.25, 2.0, 2200);
            } else if (theme === 'athleticStudio') {
              // Bold athletic stadium double-chime: E5 (659.25), E6 (1318.5)
              playNote(659.25, t, 0.35, 0.25, 1.5, 3000, 'triangle');
              playNote(1318.51, t + 0.09, 0.70, 0.30, 2.0, 3600, 'sine');
            } else {
              // Crystal Bell (Apple style - default): C5 -> E5 -> G5 -> C6 shimmering chord
              playNote(523.25, t, 0.55, 0.18, 2.76, 3600);
              playNote(659.25, t + 0.07, 0.65, 0.20, 2.76, 3600);
              playNote(783.99, t + 0.14, 0.75, 0.22, 2.76, 3800);
              playNote(1046.5, t + 0.21, 1.30, 0.26, 2.76, 4200);
            }
          } catch(e) {}
        })('$theme');
      ''');
    } catch (_) {}
  }

  static void playStartWhistle(String theme) {
    try {
      _jsEval('''
        (function(theme) {
          try {
            var AudioCtx = window.AudioContext || window.webkitAudioContext;
            if (!AudioCtx) return;
            window._fitonAudioCtx = window._fitonAudioCtx || new AudioCtx();
            var ctx = window._fitonAudioCtx;
            if (ctx.state === 'suspended') ctx.resume();

            function playNote(freq, startTime, duration, gainVal, filterFreq) {
              var osc = ctx.createOscillator();
              var gain = ctx.createGain();
              var filter = ctx.createBiquadFilter();

              filter.type = 'lowpass';
              filter.frequency.setValueAtTime(filterFreq || 3000, startTime);
              osc.type = 'sine';
              osc.frequency.setValueAtTime(freq, startTime);

              gain.gain.setValueAtTime(0.0001, startTime);
              gain.gain.linearRampToValueAtTime(gainVal, startTime + 0.01);
              gain.gain.exponentialRampToValueAtTime(0.0001, startTime + duration);

              osc.connect(gain);
              gain.connect(filter);
              filter.connect(ctx.destination);

              osc.start(startTime);
              osc.stop(startTime + duration);
            }

            var t = ctx.currentTime;
            if (theme === 'warmMarimba') {
              // Warm marimba ascending hit: G5 -> C6
              playNote(783.99, t, 0.14, 0.22, 2200);
              playNote(1046.5, t + 0.10, 0.40, 0.26, 2400);
            } else if (theme === 'athleticStudio') {
              // High-energy start tone: punchy double chirp
              playNote(880.0, t, 0.12, 0.26, 3400);
              playNote(1318.51, t + 0.08, 0.35, 0.30, 3800);
            } else {
              // Crystal Bell (Upbeat go fanfare - default): G5 -> C6
              playNote(783.99, t, 0.15, 0.22, 3400);
              playNote(1046.5, t + 0.11, 0.45, 0.28, 3800);
            }
          } catch(e) {}
        })('$theme');
      ''');
    } catch (_) {}
  }
}
