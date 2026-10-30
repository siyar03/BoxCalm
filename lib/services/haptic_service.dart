import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

import '../providers/settings_provider.dart';
import 'breathing_engine.dart';

class HapticService {
  HapticService(this._settings);

  final SettingsProvider _settings;
  bool? _hasVibrator;

  Future<bool> _canVibrate() async {
    if (kIsWeb) return false;
    if (_hasVibrator != null) return _hasVibrator!;
    try {
      _hasVibrator = await Vibration.hasVibrator();
    } catch (_) {
      _hasVibrator = false;
    }
    return _hasVibrator!;
  }

  int get _amplitude =>
      (50 + (_settings.hapticIntensity.clamp(0.0, 1.0) * 205)).round();

  Future<void> phaseCue(BreathPhase phase) async {
    if (!_settings.hapticsEnabled) return;
    switch (phase) {
      case BreathPhase.preparing:
        await _tap(duration: 18, strength: 0.5);
        break;
      case BreathPhase.inhale:
        await _tap(duration: 30, strength: 0.7);
        break;
      case BreathPhase.hold1:
      case BreathPhase.hold2:
        await _pattern([0, 22, 70, 22]);
        break;
      case BreathPhase.exhale:
        await _tap(duration: 140, strength: 1.0);
        break;
      case BreathPhase.complete:
        await _pattern([0, 40, 70, 40, 70, 180]);
        break;
      case BreathPhase.idle:
        break;
    }
  }

  Future<void> tick() => _tap(duration: 12, strength: 0.35);

  Future<void> success() => _pattern([0, 30, 50, 30, 50, 120]);

  Future<void> _tap({required int duration, required double strength}) async {
    if (!_settings.hapticsEnabled) return;
    if (await _canVibrate()) {
      try {
        await Vibration.vibrate(
          duration: duration,
          amplitude: ((_amplitude * strength).round()).clamp(1, 255),
        );
        return;
      } catch (_) {}
    }
    try {
      if (strength >= 0.8) {
        await HapticFeedback.mediumImpact();
      } else {
        await HapticFeedback.selectionClick();
      }
    } catch (_) {}
  }

  Future<void> _pattern(List<int> pattern) async {
    if (!_settings.hapticsEnabled) return;
    if (await _canVibrate()) {
      try {
        await Vibration.vibrate(
          pattern: pattern,
          intensities: [
            0,
            for (var i = 1; i < pattern.length; i++)
              i.isEven ? _amplitude : (_amplitude * 0.6).round(),
          ],
        );
        return;
      } catch (_) {}
    }
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }
}
