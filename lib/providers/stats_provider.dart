import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../core/constants/achievements.dart';
import '../models/session_record.dart';
import '../services/stats_service.dart';
import '../services/storage_service.dart';

class StatsProvider extends ChangeNotifier {
  StatsProvider({required StorageService storage}) : _storage = storage {
    _sessions = storage.loadSessions();
    _unlocked = storage.loadAchievements();
    _snapshot = StatsService.compute(_sessions, DateTime.now());
    _evaluateAndStore(notify: false);
  }

  final StorageService _storage;
  late List<SessionRecord> _sessions;
  late StatsSnapshot _snapshot;
  late Map<String, int> _unlocked;
  List<AchievementDef> _newUnlocks = [];

  List<SessionRecord> get sessions => List.unmodifiable(_sessions);
  StatsSnapshot get snapshot => _snapshot;
  Map<String, int> get unlocked => Map.unmodifiable(_unlocked);
  List<AchievementDef> get newUnlocks => List.unmodifiable(_newUnlocks);

  List<AchievementDef> get unlockedAchievements => achievements
      .where((a) => _unlocked.containsKey(a.id))
      .toList()
    ..sort((a, b) => (_unlocked[b.id] ?? 0).compareTo(_unlocked[a.id] ?? 0));

  List<AchievementDef> takeNewUnlocks() {
    final list = _newUnlocks;
    _newUnlocks = [];
    return list;
  }

  Future<List<AchievementDef>> addSession(SessionRecord session) async {
    _sessions = [session, ..._sessions]
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    _snapshot = StatsService.compute(_sessions, DateTime.now());
    final fresh = _evaluateAndStore(notify: false);
    _newUnlocks = fresh;
    notifyListeners();
    await _storage.saveSession(session);
    return fresh;
  }

  Future<void> updateMood(String sessionId, int mood) async {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index < 0) return;
    _sessions[index].moodAfter = mood;
    _snapshot = StatsService.compute(_sessions, DateTime.now());
    _evaluateAndStore(notify: false);
    notifyListeners();
    await _storage.saveSession(_sessions[index]);
  }

  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((s) => s.id == id);
    _snapshot = StatsService.compute(_sessions, DateTime.now());
    notifyListeners();
    await _storage.deleteSession(id);
  }

  Future<void> clearHistory() async {
    _sessions = [];
    _unlocked = {};
    _newUnlocks = [];
    _snapshot = StatsService.compute(_sessions, DateTime.now());
    notifyListeners();
    await _storage.clearSessions();
    await _storage.saveAchievements({});
  }

  List<AchievementDef> _evaluateAndStore({required bool notify}) {
    final earned = evaluateAchievements(_snapshot.achievementStats);
    final now = DateTime.now().millisecondsSinceEpoch;
    final fresh = <AchievementDef>[];
    for (final id in earned) {
      if (!_unlocked.containsKey(id)) {
        _unlocked[id] = now;
        final def = achievementById(id);
        if (def != null) fresh.add(def);
      }
    }
    if (fresh.isNotEmpty) {
      _storage.saveAchievements(_unlocked);
      if (notify) notifyListeners();
    }
    return fresh;
  }

  void refresh() {
    _snapshot = StatsService.compute(_sessions, DateTime.now());
    notifyListeners();
  }

  String exportJson() {
    final payload = {
      'app': 'BoxCalm',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'sessions': _sessions.map((s) => s.toJson()).toList(),
      'achievements': _unlocked,
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  String exportCsv() {
    final buffer = StringBuffer(
      'date,preset,duration_seconds,cycles,completed,mood,pattern\n',
    );
    for (final s in _sessions) {
      buffer.writeln([
        s.startedAt.toIso8601String(),
        _csv(s.presetName),
        s.durationSec,
        s.cyclesDone,
        s.completed,
        s.moodAfter ?? '',
        _csv(s.patternLabel),
      ].join(','));
    }
    return buffer.toString();
  }

  String _csv(String value) =>
      value.contains(',') ? '"${value.replaceAll('"', '""')}"' : value;
}
