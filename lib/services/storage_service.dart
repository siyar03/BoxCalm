import 'package:hive_flutter/hive_flutter.dart';

import '../models/breath_pattern.dart';
import '../models/preset.dart';
import '../models/reminder.dart';
import '../models/session_record.dart';

class StorageService {
  static const sessionsBoxName = 'sessions_v1';
  static const presetsBoxName = 'presets_v1';
  static const remindersBoxName = 'reminders_v1';
  static const metaBoxName = 'meta_v1';

  late Box<SessionRecord> _sessions;
  late Box<Preset> _presets;
  late Box<Reminder> _reminders;
  late Box _meta;

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(PresetAdapter());
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(BreathPatternAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(SessionRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(ReminderAdapter());

    _sessions = await Hive.openBox<SessionRecord>(sessionsBoxName);
    _presets = await Hive.openBox<Preset>(presetsBoxName);
    _reminders = await Hive.openBox<Reminder>(remindersBoxName);
    _meta = await Hive.openBox(metaBoxName);
  }

  List<SessionRecord> loadSessions() {
    final list = _sessions.values.toList();
    list.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return list;
  }

  Future<void> saveSession(SessionRecord session) =>
      _sessions.put(session.id, session);

  Future<void> deleteSession(String id) => _sessions.delete(id);

  Future<void> clearSessions() => _sessions.clear();

  List<Preset> loadCustomPresets() {
    final list = _presets.values.toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  Future<void> savePreset(Preset preset) => _presets.put(preset.id, preset);

  Future<void> deletePreset(String id) => _presets.delete(id);

  List<Reminder> loadReminders() {
    final list = _reminders.values.toList();
    list.sort((a, b) => (a.hour * 60 + a.minute)
        .compareTo(b.hour * 60 + b.minute));
    return list;
  }

  Future<void> saveReminder(Reminder reminder) =>
      _reminders.put(reminder.id, reminder);

  Future<void> deleteReminder(String id) => _reminders.delete(id);

  Set<String> loadFavoriteIds() {
    final raw = _meta.get('favorite_presets');
    if (raw is List) return raw.map((e) => e.toString()).toSet();
    return {};
  }

  Future<void> saveFavoriteIds(Set<String> ids) =>
      _meta.put('favorite_presets', ids.toList());

  Map<String, int> loadAchievements() {
    final raw = _meta.get('achievements_unlocked');
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), (value as num).toInt()));
    }
    return {};
  }

  Future<void> saveAchievements(Map<String, int> unlocked) =>
      _meta.put('achievements_unlocked', unlocked);

  String? getMetaString(String key) => _meta.get(key)?.toString();

  Future<void> setMetaString(String key, String value) =>
      _meta.put(key, value);

  Future<void> clearAllUserData() async {
    await _sessions.clear();
    await _presets.clear();
    await _reminders.clear();
    final favorites = _meta.get('favorite_presets');
    final achievements = _meta.get('achievements_unlocked');
    await _meta.clear();
    if (favorites != null) await _meta.put('favorite_presets', favorites);
    if (achievements != null) {
      await _meta.put('achievements_unlocked', achievements);
    }
  }
}
