import 'package:intl/intl.dart';

String greetingForHour(int hour) {
  if (hour < 5) return 'Quiet hours';
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  if (hour < 21) return 'Good evening';
  return 'Time to unwind';
}

String formatClock(int totalSeconds) {
  final s = totalSeconds.clamp(0, 359999);
  final m = s ~/ 60;
  final sec = s % 60;
  return '$m:${sec.toString().padLeft(2, '0')}';
}

String formatMinutes(int minutes) {
  if (minutes < 60) return '$minutes min';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '${h}h' : '${h}h ${m}m';
}

String formatSessionTime(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  final diff = today.difference(day).inDays;
  final time = DateFormat.jm().format(date);
  if (diff == 0) return 'Today · $time';
  if (diff == 1) return 'Yesterday · $time';
  if (diff < 7) return '${DateFormat.EEEE().format(date)} · $time';
  return '${DateFormat.MMMd().format(date)} · $time';
}

String dayKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

DateTime dayOnly(DateTime date) => DateTime(date.year, date.month, date.day);

String weekdayInitial(int weekday) =>
    const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][weekday % 7];

String relativeDayLabel(DateTime date) {
  final now = DateTime.now();
  final diff = dayOnly(now).difference(dayOnly(date)).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  if (diff < 7) return DateFormat.EEEE().format(date);
  return DateFormat.MMMd().format(date);
}

String plural(int count, String singular, [String? pluralWord]) =>
    '$count ${count == 1 ? singular : (pluralWord ?? '${singular}s')}';
