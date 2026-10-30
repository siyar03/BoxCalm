import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/reminder.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  bool get supported => !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> init() async {
    if (!supported) return;
    try {
      tzdata.initializeTimeZones();
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('Timezone: $e');
    }

    const android = AndroidInitializationSettings('ic_stat_boxcalm');
    const settings = InitializationSettings(android: android);
    try {
      await _plugin.initialize(settings);
      _ready = true;
      await _createChannel();
    } catch (e) {
      debugPrint('Notifications init: $e');
      _ready = false;
    }
  }

  Future<void> _createChannel() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        'boxcalm_reminders',
        'Breathing reminders',
        description: 'Gentle nudges for your daily breathing practice',
        importance: Importance.high,
        playSound: true,
      ),
    );
  }

  Future<bool> requestPermissions() async {
    if (!supported || !_ready) return false;
    var granted = true;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final notifications = await android?.requestNotificationsPermission();
      final exact = await android?.requestExactAlarmsPermission();
      granted = (notifications ?? true) && (exact ?? true);
    } catch (e) {
      debugPrint('Permission: $e');
      granted = false;
    }
    return granted;
  }

  Future<bool> notificationsEnabled() async {
    if (!supported || !_ready) return false;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.areNotificationsEnabled() ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> scheduleReminder(Reminder reminder) async {
    if (!_ready || !reminder.enabled) return;
    await cancelReminder(reminder);
    for (final weekday in reminder.weekdays) {
      final id = reminder.notificationIds[
          reminder.weekdays.indexOf(weekday)];
      final next = _nextInstance(weekday, reminder.hour, reminder.minute);
      try {
        await _plugin.zonedSchedule(
          id,
          reminder.label,
          reminder.message,
          next,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'boxcalm_reminders',
              'Breathing reminders',
              channelDescription:
                  'Gentle nudges for your daily breathing practice',
              importance: Importance.high,
              priority: Priority.high,
              icon: 'ic_stat_boxcalm',
              color: const Color(0xFF5EEAD4),
              category: AndroidNotificationCategory.reminder,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: 'reminder:${reminder.id}',
        );
      } catch (e) {
        debugPrint('Schedule $weekday: $e');
        try {
          await _plugin.zonedSchedule(
            id,
            reminder.label,
            reminder.message,
            next,
            NotificationDetails(
              android: AndroidNotificationDetails(
                'boxcalm_reminders',
                'Breathing reminders',
                importance: Importance.high,
                priority: Priority.high,
                icon: 'ic_stat_boxcalm',
                color: const Color(0xFF5EEAD4),
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            payload: 'reminder:${reminder.id}',
          );
        } catch (inner) {
          debugPrint('Fallback schedule: $inner');
        }
      }
    }
  }

  tz.TZDateTime _nextInstance(int weekdayIndex, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    // Our week starts on Monday (0); DateTime uses Monday=1 ... Sunday=7.
    final target = (weekdayIndex + 1) % 7;
    var date = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    while (date.weekday % 7 != target || !date.isAfter(now)) {
      date = date.add(const Duration(days: 1));
      date = tz.TZDateTime(
        tz.local,
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );
    }
    return date;
  }

  Future<void> cancelReminder(Reminder reminder) async {
    if (!_ready) return;
    for (final id in reminder.notificationIds) {
      try {
        await _plugin.cancel(id);
      } catch (_) {}
    }
  }

  Future<void> cancelAll() async {
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  Future<void> showTestNotification() async {
    if (!supported || !_ready) return;
    try {
      await _plugin.show(
        9911,
        'A calm moment is waiting',
        'Tap to open BoxCalm and take five slow breaths.',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'boxcalm_reminders',
            'Breathing reminders',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'ic_stat_boxcalm',
            color: const Color(0xFF5EEAD4),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Test notification: $e');
    }
  }
}
