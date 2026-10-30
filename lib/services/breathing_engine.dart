import 'breath_pattern.dart';

enum BreathPhase { idle, preparing, inhale, hold1, exhale, hold2, complete }

extension BreathPhaseX on BreathPhase {
  bool get isHold => this == BreathPhase.hold1 || this == BreathPhase.hold2;
  bool get isBreath =>
      this == BreathPhase.inhale ||
      this == BreathPhase.hold1 ||
      this == BreathPhase.exhale ||
      this == BreathPhase.hold2;

  String get label {
    switch (this) {
      case BreathPhase.preparing:
        return 'Get ready';
      case BreathPhase.inhale:
        return 'Breathe in';
      case BreathPhase.hold1:
        return 'Hold';
      case BreathPhase.exhale:
        return 'Breathe out';
      case BreathPhase.hold2:
        return 'Hold';
      case BreathPhase.complete:
        return 'Well done';
      case BreathPhase.idle:
        return 'Ready';
    }
  }

  String get shortLabel {
    switch (this) {
      case BreathPhase.preparing:
        return 'Ready';
      case BreathPhase.inhale:
        return 'Inhale';
      case BreathPhase.hold1:
      case BreathPhase.hold2:
        return 'Hold';
      case BreathPhase.exhale:
        return 'Exhale';
      case BreathPhase.complete:
        return 'Complete';
      case BreathPhase.idle:
        return 'Idle';
    }
  }

  int get sideIndex {
    switch (this) {
      case BreathPhase.inhale:
        return 0;
      case BreathPhase.hold1:
        return 1;
      case BreathPhase.exhale:
        return 2;
      case BreathPhase.hold2:
        return 3;
      default:
        return 0;
    }
  }
}

/// A drift-free, widget-free breathing state machine.
///
/// Feed it elapsed milliseconds from a Ticker; it handles phase transitions,
/// cycle counting, progressive patterns and both duration/cycle targets.
class BreathingEngine {
  BreathingEngine({
    required BreathPattern pattern,
    this.prepSeconds = 3,
    this.targetCycles,
    this.targetDurationSec,
    this.progressive = false,
    this.progressiveEvery = 5,
    this.onPhaseChanged,
    this.onCycleCompleted,
    this.onCompleted,
  })  : _pattern = pattern,
        _currentPattern = pattern;

  BreathPattern _pattern;
  BreathPattern _currentPattern;
  final int prepSeconds;
  final int? targetCycles;
  final int? targetDurationSec;
  final bool progressive;
  final int progressiveEvery;

  final void Function(BreathPhase phase)? onPhaseChanged;
  final void Function(int cycles)? onCycleCompleted;
  final void Function()? onCompleted;

  BreathPhase _phase = BreathPhase.idle;
  int _phaseElapsedMs = 0;
  int _phaseDurationMs = 0;
  int _elapsedMs = 0;
  int _cycles = 0;
  bool _finished = false;

  BreathPhase get phase => _phase;
  int get cycles => _cycles;
  int get elapsedMs => _elapsedMs;
  int get elapsedSec => _elapsedMs ~/ 1000;
  bool get isFinished => _finished;
  bool get isRunning =>
      _phase != BreathPhase.idle && _phase != BreathPhase.complete;
  BreathPattern get pattern => _currentPattern;

  double get phaseProgress {
    if (_phaseDurationMs <= 0) return 1;
    return (_phaseElapsedMs / _phaseDurationMs).clamp(0.0, 1.0);
  }

  int get phaseRemainingSec {
    final remaining = _phaseDurationMs - _phaseElapsedMs;
    return (remaining / 1000).ceil().clamp(0, 3600);
  }

  int get targetRemainingSec {
    if (targetDurationSec == null) return 0;
    return (targetDurationSec! - elapsedSec).clamp(0, 86400);
  }

  int get targetTotalCycles => targetCycles ?? 0;

  void start() {
    if (_phase != BreathPhase.idle) return;
    _elapsedMs = 0;
    _cycles = 0;
    _finished = false;
    if (prepSeconds > 0) {
      _enter(BreathPhase.preparing, prepSeconds * 1000);
    } else {
      _enter(BreathPhase.inhale, _currentPattern.inhale * 1000);
    }
  }

  void finishEarly() {
    if (_phase == BreathPhase.complete) return;
    _finished = true;
    _phase = BreathPhase.complete;
    _phaseDurationMs = 0;
    _phaseElapsedMs = 0;
    onPhaseChanged?.call(_phase);
    onCompleted?.call();
  }

  /// Advance the state machine. [deltaMs] is elapsed ticker time.
  void advance(int deltaMs) {
    if (deltaMs <= 0 || !isRunning) return;
    _elapsedMs += deltaMs;
    _phaseElapsedMs += deltaMs;

    var guard = 0;
    while (_phaseElapsedMs >= _phaseDurationMs && guard < 64) {
      guard++;
      final carry = _phaseElapsedMs - _phaseDurationMs;
      final advanced = _advancePhase();
      if (!advanced || _finished) return;
      _phaseElapsedMs = carry;
      if (_phaseDurationMs <= 0) {
        continue;
      }
    }

    if (!_finished && targetDurationSec != null &&
        _elapsedMs >= targetDurationSec! * 1000) {
      _complete();
    }
  }

  bool _advancePhase() {
    switch (_phase) {
      case BreathPhase.preparing:
        _enter(BreathPhase.inhale, _currentPattern.inhale * 1000);
        return true;
      case BreathPhase.inhale:
        if (_currentPattern.hold1 > 0) {
          _enter(BreathPhase.hold1, _currentPattern.hold1 * 1000);
        } else {
          _enter(BreathPhase.exhale, _currentPattern.exhale * 1000);
        }
        return true;
      case BreathPhase.hold1:
        _enter(BreathPhase.exhale, _currentPattern.exhale * 1000);
        return true;
      case BreathPhase.exhale:
        if (_currentPattern.hold2 > 0) {
          _enter(BreathPhase.hold2, _currentPattern.hold2 * 1000);
        } else {
          return _completeCycle();
        }
        return true;
      case BreathPhase.hold2:
        return _completeCycle();
      case BreathPhase.idle:
      case BreathPhase.complete:
        return false;
    }
  }

  bool _completeCycle() {
    _cycles++;
    onCycleCompleted?.call(_cycles);

    if (progressive &&
        progressiveEvery > 0 &&
        _cycles % progressiveEvery == 0) {
      final inhale = (_currentPattern.inhale + 1).clamp(1, 20);
      final exhale = (_currentPattern.exhale + 1).clamp(1, 20);
      _currentPattern = _currentPattern.copyWith(
        inhale: inhale,
        exhale: exhale,
      );
    }

    if (targetCycles != null && _cycles >= targetCycles!) {
      _complete();
      return false;
    }
    if (targetDurationSec != null &&
        _elapsedMs >= targetDurationSec! * 1000) {
      _complete();
      return false;
    }
    _enter(BreathPhase.inhale, _currentPattern.inhale * 1000);
    return true;
  }

  void _enter(BreathPhase phase, int durationMs) {
    _phase = phase;
    _phaseDurationMs = durationMs;
    _phaseElapsedMs = 0;
    onPhaseChanged?.call(phase);
  }

  void _complete() {
    if (_finished) return;
    _finished = true;
    _phase = BreathPhase.complete;
    _phaseDurationMs = 0;
    _phaseElapsedMs = 0;
    onPhaseChanged?.call(BreathPhase.complete);
    onCompleted?.call();
  }

  void reset() {
    _pattern = _currentPattern;
    _currentPattern = _pattern;
    _phase = BreathPhase.idle;
    _phaseElapsedMs = 0;
    _phaseDurationMs = 0;
    _elapsedMs = 0;
    _cycles = 0;
    _finished = false;
  }
}
