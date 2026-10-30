import '../core/constants/achievements.dart';
import '../core/utils/format.dart';
import '../models/session_record.dart';

class DayStat {
  const DayStat({
    required this.date,
    required this.minutes,
    required this.sessions,
  });

  final DateTime date;
  final int minutes;
  final int sessions;
}

class StatsSnapshot {
  const StatsSnapshot({
    required this.totalSessions,
    required this.completedSessions,
    required this.totalMinutes,
    required this.totalCycles,
    required this.totalBreaths,
    required this.todayMinutes,
    required this.weekMinutes,
    required this.monthMinutes,
    required this.currentStreak,
    required this.longestStreak,
    required this.week,
    required this.heatmap,
    required this.hasEarlySession,
    required this.hasLateSession,
    required this.hasDeepSession,
    required this.moodsLogged,
    required this.boxSessions,
    required this.hadComeback,
    required this.moodAverage,
  });

  final int totalSessions;
  final int completedSessions;
  final int totalMinutes;
  final int totalCycles;
  final int totalBreaths;
  final double todayMinutes;
  final int weekMinutes;
  final int monthMinutes;
  final int currentStreak;
  final int longestStreak;
  final List<DayStat> week;
  final Map<String, int> heatmap;
  final bool hasEarlySession;
  final bool hasLateSession;
  final bool hasDeepSession;
  final int moodsLogged;
  final int boxSessions;
  final bool hadComeback;
  final double? moodAverage;

  AchievementStats get achievementStats => AchievementStats(
        totalSessions: totalSessions,
        totalCycles: totalCycles,
        totalMinutes: totalMinutes,
        longestStreak: longestStreak,
        hasEarlySession: hasEarlySession,
        hasLateSession: hasLateSession,
        hasDeepSession: hasDeepSession,
        moodsLogged: moodsLogged,
        boxSessions: boxSessions,
        hadComeback: hadComeback,
      );
}

class StatsService {
  static StatsSnapshot compute(List<SessionRecord> sessions, DateTime now) {
    final today = dayOnly(now);
    final dayMinutes = <String, int>{};
    final daySeconds = <String, int>{};
    final daySessions = <String, int>{};
    final activeDays = <String>{};

    var totalSec = 0;
    var totalCycles = 0;
    var completed = 0;
    var early = false;
    var late = false;
    var deep = false;
    var box = 0;
    var moods = 0;
    var moodSum = 0;
    var hadComeback = false;

    final sortedAsc = [...sessions]..sort((a, b) => a.startedAt.compareTo(b.startedAt));
    DateTime? previousDay;

    for (final s in sortedAsc) {
      final day = dayOnly(s.startedAt);
      final key = dayKey(day);

      if (previousDay != null &&
          day.difference(previousDay).inDays >= 7 &&
          sessions.length > 1) {
        hadComeback = true;
      }
      previousDay = day;

      totalSec += s.durationSec;
      totalCycles += s.cyclesDone;
      if (s.completed) completed++;
      if (s.startedAt.hour < 8) early = true;
      if (s.startedAt.hour >= 22) late = true;
      if (s.durationSec >= 600) deep = true;
      if (s.presetId == 'builtin_box_4444') box++;
      if (s.moodAfter != null) {
        moods++;
        moodSum += s.moodAfter!;
      }

      if (s.durationSec > 0) {
        activeDays.add(key);
        daySeconds[key] = (daySeconds[key] ?? 0) + s.durationSec;
        dayMinutes[key] = (dayMinutes[key] ?? 0) + (s.durationSec / 60).round();
        daySessions[key] = (daySessions[key] ?? 0) + 1;
      }
    }

    // Current streak: consecutive days, allowing today to be a fresh start.
    var currentStreak = 0;
    var cursor = activeDays.contains(dayKey(today))
        ? today
        : today.subtract(const Duration(days: 1));
    while (activeDays.contains(dayKey(cursor))) {
      currentStreak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    // Longest streak.
    var longestStreak = 0;
    var running = 0;
    DateTime? prev;
    final sortedDays = activeDays
        .map((k) => DateTime.parse(k))
        .toList()
      ..sort();
    for (final d in sortedDays) {
      if (prev != null && d.difference(prev).inDays == 1) {
        running++;
      } else {
        running = 1;
      }
      if (running > longestStreak) longestStreak = running;
      prev = d;
    }

    final week = <DayStat>[
      for (var i = 6; i >= 0; i--)
        () {
          final d = today.subtract(Duration(days: i));
          return DayStat(
            date: d,
            minutes: dayMinutes[dayKey(d)] ?? 0,
            sessions: daySessions[dayKey(d)] ?? 0,
          );
        }(),
    ];

    final heatmap = <String, int>{
      for (final entry in dayMinutes.entries) entry.key: entry.value,
    };

    final monthStart = DateTime(today.year, today.month, 1);
    var monthMinutes = 0;
    for (final entry in dayMinutes.entries) {
      final date = DateTime.parse(entry.key);
      if (!date.isBefore(monthStart) && !date.isAfter(today)) {
        monthMinutes += entry.value;
      }
    }

    var weekMinutes = 0;
    for (final d in week) {
      weekMinutes += d.minutes;
    }

    return StatsSnapshot(
      totalSessions: sessions.length,
      completedSessions: completed,
      totalMinutes: (totalSec / 60).round(),
      totalCycles: totalCycles,
      totalBreaths: totalCycles * 4,
      todayMinutes: (daySeconds[dayKey(today)] ?? 0) / 60.0,
      weekMinutes: weekMinutes,
      monthMinutes: monthMinutes,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      week: week,
      heatmap: heatmap,
      hasEarlySession: early,
      hasLateSession: late,
      hasDeepSession: deep,
      moodsLogged: moods,
      boxSessions: box,
      hadComeback: hadComeback,
      moodAverage: moods == 0 ? null : moodSum / moods,
    );
  }
}
