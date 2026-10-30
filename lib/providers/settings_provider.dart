import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/visual_style.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider._(this._prefs, Map<String, dynamic> data) {
    _darkMode = data['darkMode'] as bool? ?? true;
    _themeMode = data['themeMode'] as String? ?? 'dark';
    _paletteId = data['paletteId'] as String? ?? 'ocean';
    _visualStyle = data['visualStyle'] as String? ?? 'box';
    _reduceMotion = data['reduceMotion'] as bool? ?? false;
    _soundEnabled = data['soundEnabled'] as bool? ?? true;
    _chimeEnabled = data['chimeEnabled'] as bool? ?? true;
    _hapticsEnabled = data['hapticsEnabled'] as bool? ?? true;
    _hapticIntensity = (data['hapticIntensity'] as num?)?.toDouble() ?? 0.75;
    _chimeVolume = (data['chimeVolume'] as num?)?.toDouble() ?? 0.65;
    _prepSeconds = (data['prepSeconds'] as num?)?.toInt() ?? 3;
    _keepAwake = data['keepAwake'] as bool? ?? true;
    _dailyGoalMin = (data['dailyGoalMin'] as num?)?.toInt() ?? 10;
    _defaultMinutes = (data['defaultMinutes'] as num?)?.toInt() ?? 5;
    _defaultTargetType = data['defaultTargetType'] as String? ?? 'minutes';
    _silentMode = data['silentMode'] as bool? ?? false;
    _onboardingComplete = data['onboardingComplete'] as bool? ?? false;
    _lastPresetId =
        data['lastPresetId'] as String? ?? 'builtin_box_4444';
    _showCycleDots = data['showCycleDots'] as bool? ?? true;
    _autoPause = data['autoPause'] as bool? ?? true;
  }

  static const _key = 'boxcalm_settings_v1';

  static Future<SettingsProvider> load() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> data = {};
    try {
      final raw = prefs.getString(_key);
      if (raw != null) data = jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      data = {};
    }
    return SettingsProvider._(prefs, data);
  }

  final SharedPreferences _prefs;

  late bool _darkMode;
  late String _themeMode;
  late String _paletteId;
  late String _visualStyle;
  late bool _reduceMotion;
  late bool _soundEnabled;
  late bool _chimeEnabled;
  late bool _hapticsEnabled;
  late double _hapticIntensity;
  late double _chimeVolume;
  late int _prepSeconds;
  late bool _keepAwake;
  late int _dailyGoalMin;
  late int _defaultMinutes;
  late String _defaultTargetType;
  late bool _silentMode;
  late bool _onboardingComplete;
  late String _lastPresetId;
  late bool _showCycleDots;
  late bool _autoPause;

  bool get darkMode => _darkMode;
  ThemeMode get themeMode {
    switch (_themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  String get themeModeId => _themeMode;
  String get paletteId => _paletteId;
  VisualStyle get visualStyle => VisualStyle.fromId(_visualStyle);
  bool get reduceMotion => _reduceMotion;
  bool get soundEnabled => _soundEnabled;
  bool get chimeEnabled => _chimeEnabled && _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled && !_silentMode;
  double get hapticIntensity => _hapticIntensity;
  double get chimeVolume => _chimeVolume;
  int get prepSeconds => _prepSeconds;
  bool get keepAwake => _keepAwake;
  int get dailyGoalMin => _dailyGoalMin;
  int get defaultMinutes => _defaultMinutes;
  String get defaultTargetType => _defaultTargetType;
  bool get silentMode => _silentMode;
  bool get onboardingComplete => _onboardingComplete;
  String get lastPresetId => _lastPresetId;
  bool get showCycleDots => _showCycleDots;
  bool get autoPause => _autoPause;

  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    _darkMode = mode != 'light';
    await _persist();
  }

  Future<void> setPalette(String id) async {
    _paletteId = id;
    await _persist();
  }

  Future<void> setVisualStyle(VisualStyle style) async {
    _visualStyle = style.name;
    await _persist();
  }

  Future<void> setReduceMotion(bool value) async {
    _reduceMotion = value;
    await _persist();
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    await _persist();
  }

  Future<void> setChimeEnabled(bool value) async {
    _chimeEnabled = value;
    await _persist();
  }

  Future<void> setHapticsEnabled(bool value) async {
    _hapticsEnabled = value;
    await _persist();
  }

  Future<void> setHapticIntensity(double value) async {
    _hapticIntensity = value;
    await _persist();
  }

  Future<void> setChimeVolume(double value) async {
    _chimeVolume = value;
    await _persist();
  }

  Future<void> setPrepSeconds(int value) async {
    _prepSeconds = value;
    await _persist();
  }

  Future<void> setKeepAwake(bool value) async {
    _keepAwake = value;
    await _persist();
  }

  Future<void> setDailyGoal(int minutes) async {
    _dailyGoalMin = minutes;
    await _persist();
  }

  Future<void> setDefaultMinutes(int minutes) async {
    _defaultMinutes = minutes;
    await _persist();
  }

  Future<void> setDefaultTargetType(String type) async {
    _defaultTargetType = type;
    await _persist();
  }

  Future<void> setSilentMode(bool value) async {
    _silentMode = value;
    await _persist();
  }

  Future<void> setOnboardingComplete(bool value) async {
    _onboardingComplete = value;
    await _persist();
  }

  Future<void> setLastPreset(String id) async {
    if (_lastPresetId == id) return;
    _lastPresetId = id;
    await _persist();
  }

  Future<void> setShowCycleDots(bool value) async {
    _showCycleDots = value;
    await _persist();
  }

  Future<void> setAutoPause(bool value) async {
    _autoPause = value;
    await _persist();
  }

  Future<void> _persist() async {
    notifyListeners();
    final data = {
      'darkMode': _darkMode,
      'themeMode': _themeMode,
      'paletteId': _paletteId,
      'visualStyle': _visualStyle,
      'reduceMotion': _reduceMotion,
      'soundEnabled': _soundEnabled,
      'chimeEnabled': _chimeEnabled,
      'hapticsEnabled': _hapticsEnabled,
      'hapticIntensity': _hapticIntensity,
      'chimeVolume': _chimeVolume,
      'prepSeconds': _prepSeconds,
      'keepAwake': _keepAwake,
      'dailyGoalMin': _dailyGoalMin,
      'defaultMinutes': _defaultMinutes,
      'defaultTargetType': _defaultTargetType,
      'silentMode': _silentMode,
      'onboardingComplete': _onboardingComplete,
      'lastPresetId': _lastPresetId,
      'showCycleDots': _showCycleDots,
      'autoPause': _autoPause,
    };
    await _prefs.setString(_key, jsonEncode(data));
  }
}
