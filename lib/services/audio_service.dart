import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../providers/settings_provider.dart';

class AudioService {
  AudioService(this._settings);

  final SettingsProvider _settings;
  final AudioPlayer _chimeA = AudioPlayer(playerId: 'boxcalm_chime_a');
  final AudioPlayer _chimeB = AudioPlayer(playerId: 'boxcalm_chime_b');

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await _chimeA.setReleaseMode(ReleaseMode.release);
      await _chimeB.setReleaseMode(ReleaseMode.release);
    } catch (e) {
      debugPrint('Audio init: $e');
    }
  }

  Future<void> playChime(String name) async {
    if (!_settings.chimeEnabled) return;
    try {
      final player = name == 'chime_inhale' || name == 'chime_complete'
          ? _chimeA
          : _chimeB;
      await player.stop();
      await player.setVolume(_settings.chimeVolume.clamp(0.0, 1.0));
      await player.play(AssetSource('audio/$name.mp3'));
    } catch (e) {
      debugPrint('Chime: $e');
    }
  }

  Future<void> stopAll() async {
    try {
      await _chimeA.stop();
      await _chimeB.stop();
    } catch (_) {}
  }

  Future<void> dispose() async {
    await stopAll();
    await _chimeA.dispose();
    await _chimeB.dispose();
  }
}
