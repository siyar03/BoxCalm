import 'package:flutter/material.dart';

class AchievementDef {
  const AchievementDef({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.color,
  });

  final String id;
  final String title;
  final String description;
  final String emoji;
  final Color color;
}

const achievements = <AchievementDef>[
  AchievementDef(
    id: 'first_session',
    title: 'First Breath',
    description: 'Complete your first session',
    emoji: '🌱',
    color: Color(0xFF5EEAD4),
  ),
  AchievementDef(
    id: 'sessions_10',
    title: 'Showing Up',
    description: 'Complete 10 sessions',
    emoji: '🌿',
    color: Color(0xFF6EE7B7),
  ),
  AchievementDef(
    id: 'sessions_50',
    title: 'Steady Practice',
    description: 'Complete 50 sessions',
    emoji: '🌳',
    color: Color(0xFF34D399),
  ),
  AchievementDef(
    id: 'sessions_100',
    title: 'Century',
    description: 'Complete 100 sessions',
    emoji: '💯',
    color: Color(0xFF38BDF8),
  ),
  AchievementDef(
    id: 'streak_3',
    title: 'Three in a Row',
    description: 'Breathe 3 days in a row',
    emoji: '🔥',
    color: Color(0xFFFDBA74),
  ),
  AchievementDef(
    id: 'streak_7',
    title: 'Seven Days',
    description: 'Breathe 7 days in a row',
    emoji: '⭐',
    color: Color(0xFFFDE68A),
  ),
  AchievementDef(
    id: 'streak_30',
    title: 'A Month of Calm',
    description: 'Breathe 30 days in a row',
    emoji: '🏆',
    color: Color(0xFFFCD34D),
  ),
  AchievementDef(
    id: 'cycles_100',
    title: '100 Cycles',
    description: 'Complete 100 breathing cycles',
    emoji: '🌀',
    color: Color(0xFF93C5FD),
  ),
  AchievementDef(
    id: 'cycles_500',
    title: '500 Cycles',
    description: 'Complete 500 breathing cycles',
    emoji: '🌊',
    color: Color(0xFF60A5FA),
  ),
  AchievementDef(
    id: 'cycles_1000',
    title: '1,000 Cycles',
    description: 'Complete 1,000 breathing cycles',
    emoji: '🌌',
    color: Color(0xFF818CF8),
  ),
  AchievementDef(
    id: 'minutes_60',
    title: 'One Hour',
    description: 'Breathe for 60 total minutes',
    emoji: '⏳',
    color: Color(0xFFC4B5FD),
  ),
  AchievementDef(
    id: 'minutes_300',
    title: 'Five Hours',
    description: 'Breathe for 300 total minutes',
    emoji: '🕰️',
    color: Color(0xFFA78BFA),
  ),
  AchievementDef(
    id: 'early_bird',
    title: 'Early Bird',
    description: 'Finish a session before 8 AM',
    emoji: '🌅',
    color: Color(0xFFFDBA74),
  ),
  AchievementDef(
    id: 'night_owl',
    title: 'Night Owl',
    description: 'Finish a session after 10 PM',
    emoji: '🌙',
    color: Color(0xFFA5B4FC),
  ),
  AchievementDef(
    id: 'deep_session',
    title: 'Deep Dive',
    description: 'Complete a 10+ minute session',
    emoji: '🧘',
    color: Color(0xFF5EEAD4),
  ),
  AchievementDef(
    id: 'mood_reflection',
    title: 'Noticing',
    description: 'Log how you feel after 10 sessions',
    emoji: '💭',
    color: Color(0xFFF9A8D4),
  ),
  AchievementDef(
    id: 'box_master',
    title: 'Box Master',
    description: 'Finish 25 box-breathing sessions',
    emoji: '📦',
    color: Color(0xFF67E8F9),
  ),
  AchievementDef(
    id: 'comeback',
    title: 'Return to the Mat',
    description: 'Breathe again after a 7-day pause',
    emoji: '🫶',
    color: Color(0xFFFDA4AF),
  ),
];

AchievementDef? achievementById(String id) {
  for (final a in achievements) {
    if (a.id == id) return a;
  }
  return null;
}

class AchievementStats {
  const AchievementStats({
    required this.totalSessions,
    required this.totalCycles,
    required this.totalMinutes,
    required this.longestStreak,
    required this.hasEarlySession,
    required this.hasLateSession,
    required this.hasDeepSession,
    required this.moodsLogged,
    required this.boxSessions,
    required this.hadComeback,
  });

  final int totalSessions;
  final int totalCycles;
  final int totalMinutes;
  final int longestStreak;
  final bool hasEarlySession;
  final bool hasLateSession;
  final bool hasDeepSession;
  final int moodsLogged;
  final int boxSessions;
  final bool hadComeback;
}

/// Pure evaluation so the rules are easy to unit-test.
List<String> evaluateAchievements(AchievementStats s) {
  final unlocked = <String>[];
  if (s.totalSessions >= 1) unlocked.add('first_session');
  if (s.totalSessions >= 10) unlocked.add('sessions_10');
  if (s.totalSessions >= 50) unlocked.add('sessions_50');
  if (s.totalSessions >= 100) unlocked.add('sessions_100');
  if (s.longestStreak >= 3) unlocked.add('streak_3');
  if (s.longestStreak >= 7) unlocked.add('streak_7');
  if (s.longestStreak >= 30) unlocked.add('streak_30');
  if (s.totalCycles >= 100) unlocked.add('cycles_100');
  if (s.totalCycles >= 500) unlocked.add('cycles_500');
  if (s.totalCycles >= 1000) unlocked.add('cycles_1000');
  if (s.totalMinutes >= 60) unlocked.add('minutes_60');
  if (s.totalMinutes >= 300) unlocked.add('minutes_300');
  if (s.hasEarlySession) unlocked.add('early_bird');
  if (s.hasLateSession) unlocked.add('night_owl');
  if (s.hasDeepSession) unlocked.add('deep_session');
  if (s.moodsLogged >= 10) unlocked.add('mood_reflection');
  if (s.boxSessions >= 25) unlocked.add('box_master');
  if (s.hadComeback) unlocked.add('comeback');
  return unlocked;
}
