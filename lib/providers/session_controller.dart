import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../core/constants/visual_style.dart';
import '../models/breath_pattern.dart';
import '../models/preset.dart';
import '../providers/settings_provider.dart';
import '../services/audio_service.dart';
import '../services/breathing_engine.dart';
import '../services/haptic_service.dart';

class SessionResult {
  const SessionResult({
    required this.preset,
    required this.startedAt,
    required this.durationSec,
    required this.cycles,
    required this.completed,
    required this.pattern,
    required this.targetLabel,
  });

  final Preset preset;
  final DateTime startedAt;
  final int durationSec;
  final int cycles;
  final bool completed;
  final BreathPattern pattern;
  final String targetLabel;
}

class SessionController extends ChangeNotifier {
  SessionController({
    required TickerProvider vsync,
    required this.preset,
    required this.settings,
    required this.audio,
    required this.haptics,
    this.targetMinutes,
    this.targetCycles,
    required this.onFinished,
  }) {
    _ticker = vsync.createTicker(_onTick);
  }

  final Preset preset;
  final SettingsProvider settings;
  final AudioService audio;
  final HapticService haptics;
  final int? targetMinutes;
  final int? targetCycles;
  final void Function(SessionResult result) onFinished;

  late final Ticker _ticker;
  late BreathingEngine engine;
  late final DateTime _startedAt;

  bool _paused = false;
  bool _systemPaused = false;
  bool _finished = false;
  bool _begun = false;
  Duration _lastElapsed = Duration.zero;
  int _prepTick = 0;

  bool get paused => _paused;
  bool get systemPaused => _systemPaused;
  bool get finished => _finished;
  bool get begun => _begun;
  BreathingEngine? get _safeEngine => _begun ? engine : null;
  BreathPhase get phase => _safeEngine?.phase ?? BreathPhase.idle;
  int get cycles => _safeEngine?.cycles ?? 0;
  int get elapsedSec => _safeEngine?.elapsedSec ?? 0;
  double get phaseProgress => _safeEngine?.phaseProgress ?? 0;
  int get phaseRemaining =>
      _safeEngine?.phaseRemainingSec ?? preset.pattern.inhale;
  BreathPattern get currentPattern =>
      _safeEngine?.pattern ?? preset.pattern;
  int get targetRemaining => _safeEngine?.targetRemainingSec ?? 0;
  int get targetCycleCount => targetCycles ?? preset.targetCycles ?? 0;

  String get targetLabel {
    if (targetCycles != null) return '$targetCycles cycles';
    if (targetMinutes != null) return '$targetMinutes min';
    return preset.targetLabel;
  }

  void start() {
    if (_begun) return;
    _begun = true;
    _startedAt = DateTime.now();
    engine = BreathingEngine(
      pattern: preset.pattern,
      prepSeconds: settings.prepSeconds,
      targetCycles: targetCycles ?? preset.targetCycles,
      targetDurationSec:
          targetCycles != null ? null : ((targetMinutes ?? preset.targetMinutes) * 60),
      progressive: preset.progressive,
      progressiveEvery: preset.progressiveEvery,
      onPhaseChanged: _onPhaseChanged,
      onCompleted: _onEngineComplete,
    );
    engine.start();
    _lastElapsed = Duration.zero;
    _ticker.start();
    _enableWakelock();
    notifyListeners();
  }

  void _onTick(Duration elapsed) {
    if (_paused || _finished) return;
    final delta = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    engine.advance(delta.inMilliseconds);
    if (engine.phase == BreathPhase.preparing) {
      final sec = settings.prepSeconds - engine.phaseRemainingSec;
      if (sec > _prepTick && sec < settings.prepSeconds) {
        _prepTick = sec;
        haptics.tick();
      }
    }
    notifyListeners();
  }

  void _onPhaseChanged(BreathPhase phase) {
    haptics.phaseCue(phase);
    switch (phase) {
      case BreathPhase.inhale:
        audio.playChime('chime_inhale');
        break;
      case BreathPhase.hold1:
      case BreathPhase.hold2:
        audio.playChime('chime_hold');
        break;
      case BreathPhase.exhale:
        audio.playChime('chime_exhale');
        break;
      case BreathPhase.complete:
        audio.playChime('chime_complete');
        break;
      default:
        break;
    }
    notifyListeners();
  }

  void _onEngineComplete() {
    if (_finished) return;
    _finished = true;
    _ticker.stop();
    _endSession();
    notifyListeners();
    onFinished(
      SessionResult(
        preset: preset,
        startedAt: _startedAt,
        durationSec: engine.elapsedSec,
        cycles: engine.cycles,
        completed: true,
        pattern: engine.pattern,
        targetLabel: targetLabel,
      ),
    );
  }

  void togglePause() {
    if (_finished) return;
    if (_paused) {
      _paused = false;
      _systemPaused = false;
      _lastElapsed = Duration.zero;
      _ticker.start();
      _enableWakelock();
    } else {
      _paused = true;
      _ticker.stop();
      _disableWakelock();
    }
    notifyListeners();
  }

  void pauseBySystem() {
    if (_finished || _paused) return;
    _paused = true;
    _systemPaused = true;
    _ticker.stop();
    _disableWakelock();
    notifyListeners();
  }

  void stopEarly() {
    if (_finished || !_begun) return;
    _finished = true;
    _ticker.stop();
    _endSession();
    notifyListeners();
    onFinished(
      SessionResult(
        preset: preset,
        startedAt: _startedAt,
        durationSec: engine.elapsedSec,
        cycles: engine.cycles,
        completed: false,
        pattern: engine.pattern,
        targetLabel: targetLabel,
      ),
    );
  }

  void _endSession() {
    _disableWakelock();
  }

  Future<void> _enableWakelock() async {
    if (!settings.keepAwake) return;
    try {
      await WakelockPlus.enable();
    } catch (_) {}
  }

  Future<void> _disableWakelock() async {
    try {
      await WakelockPlus.disable();
    } catch (_) {}
  }

  @override
  void dispose() {
    _ticker.dispose();
    _disableWakelock();
    super.dispose();
  }
}
