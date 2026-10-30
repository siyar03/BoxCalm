import 'package:flutter/foundation.dart';

import '../models/reminder.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class RemindersProvider extends ChangeNotifier {
  RemindersProvider({
    required StorageService storage,
    required NotificationService notifications,
  })  : _storage = storage,
        _notifications = notifications {
    _reminders = storage.loadReminders();
    _scheduleAll();
  }

  final StorageService _storage;
  final NotificationService _notifications;
  late List<Reminder> _reminders;

  List<Reminder> get reminders => List.unmodifiable(_reminders);
  bool get supported => _notifications.supported;

  Reminder? get nextReminder {
    final enabled = _reminders.where((r) => r.enabled).toList();
    if (enabled.isEmpty) return null;
    final now = DateTime.now();
    Reminder? best;
    var bestDelta = const Duration(days: 8);
    for (final r in enabled) {
      for (final day in r.weekdays) {
        final targetWeekday = day + 1;
        var diff = (targetWeekday - now.weekday) % 7;
        if (diff == 0) {
          final today = DateTime(now.year, now.month, now.day, r.hour, r.minute);
          if (!today.isAfter(now)) diff = 7;
        }
        final candidate = DateTime(now.year, now.month, now.day, r.hour, r.minute)
            .add(Duration(days: diff));
        final delta = candidate.difference(now);
        if (delta < bestDelta) {
          bestDelta = delta;
          best = r;
        }
      }
    }
    return best;
  }

  Future<void> _scheduleAll() async {
    for (final reminder in _reminders) {
      if (reminder.enabled) {
        await _notifications.scheduleReminder(reminder);
      }
    }
  }

  Future<void> add(Reminder reminder) async {
    _reminders.add(reminder);
    _sort();
    notifyListeners();
    await _storage.saveReminder(reminder);
    await _notifications.scheduleReminder(reminder);
  }

  Future<void> update(Reminder reminder) async {
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index < 0) return;
    _reminders[index] = reminder;
    _sort();
    notifyListeners();
    await _storage.saveReminder(reminder);
    await _notifications.scheduleReminder(reminder);
  }

  Future<void> toggle(Reminder reminder, bool enabled) async {
    final updated = reminder.copyWith(enabled: enabled);
    await update(updated);
    if (!enabled) {
      await _notifications.cancelReminder(reminder);
    }
  }

  Future<void> delete(Reminder reminder) async {
    _reminders.removeWhere((r) => r.id == reminder.id);
    notifyListeners();
    await _storage.deleteReminder(reminder.id);
    await _notifications.cancelReminder(reminder);
  }

  Future<bool> requestPermissions() => _notifications.requestPermissions();

  Future<bool> notificationsEnabled() => _notifications.notificationsEnabled();

  Future<void> testNotification() => _notifications.showTestNotification();

  Future<void> rescheduleAll() async {
    await _notifications.cancelAll();
    await _scheduleAll();
  }

  void _sort() {
    _reminders.sort((a, b) => (a.hour * 60 + a.minute)
        .compareTo(b.hour * 60 + b.minute));
  }
}
