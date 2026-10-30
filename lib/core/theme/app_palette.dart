import 'package:flutter/material.dart';

/// A calm, curated colour story. Every palette works in dark and light mode.
class AppPalette {
  const AppPalette({
    required this.id,
    required this.name,
    required this.darkStart,
    required this.darkMid,
    required this.darkEnd,
    required this.accent,
    required this.secondary,
    required this.lightStart,
    required this.lightEnd,
    required this.lightAccent,
    required this.lightSecondary,
  });

  final String id;
  final String name;

  final Color darkStart;
  final Color darkMid;
  final Color darkEnd;
  final Color accent;
  final Color secondary;

  final Color lightStart;
  final Color lightEnd;
  final Color lightAccent;
  final Color lightSecondary;

  List<Color> darkGradient() => [darkStart, darkMid, darkEnd];
  List<Color> lightGradient() => [lightStart, lightEnd];

  Color get primary => accent;
  Color get onPrimary => const Color(0xFF06131B);
  Color get secondaryColor => secondary;

  Color surface(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0xFF0A1420)
      : const Color(0xFFF7FAF9);

  Color card(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0xFF101D2B)
      : Colors.white;

  Color ink(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0xFFEAF4F5)
      : const Color(0xFF10242D);

  Color muted(Brightness brightness) => brightness == Brightness.dark
      ? const Color(0xFF91A7B2)
      : const Color(0xFF5E737C);

  static const ocean = AppPalette(
    id: 'ocean',
    name: 'Ocean',
    darkStart: Color(0xFF06121F),
    darkMid: Color(0xFF0A2A3A),
    darkEnd: Color(0xFF111B3B),
    accent: Color(0xFF5EEAD4),
    secondary: Color(0xFF60A5FA),
    lightStart: Color(0xFFEFF9F8),
    lightEnd: Color(0xFFE2EEF8),
    lightAccent: Color(0xFF0F766E),
    lightSecondary: Color(0xFF2563EB),
  );

  static const forest = AppPalette(
    id: 'forest',
    name: 'Forest',
    darkStart: Color(0xFF07160F),
    darkMid: Color(0xFF103326),
    darkEnd: Color(0xFF1D2A16),
    accent: Color(0xFF6EE7B7),
    secondary: Color(0xFFBEF264),
    lightStart: Color(0xFFF1F9F2),
    lightEnd: Color(0xFFE8F4E6),
    lightAccent: Color(0xFF166534),
    lightSecondary: Color(0xFF4D7C0F),
  );

  static const sunset = AppPalette(
    id: 'sunset',
    name: 'Sunset',
    darkStart: Color(0xFF1B0C17),
    darkMid: Color(0xFF431B2B),
    darkEnd: Color(0xFF3B1C10),
    accent: Color(0xFFFDBA74),
    secondary: Color(0xFFFB7185),
    lightStart: Color(0xFFFFF7F2),
    lightEnd: Color(0xFFFFECEF),
    lightAccent: Color(0xFFC2410C),
    lightSecondary: Color(0xFFBE123C),
  );

  static const midnight = AppPalette(
    id: 'midnight',
    name: 'Midnight',
    darkStart: Color(0xFF05060F),
    darkMid: Color(0xFF12142B),
    darkEnd: Color(0xFF20133A),
    accent: Color(0xFFC4B5FD),
    secondary: Color(0xFF818CF8),
    lightStart: Color(0xFFF6F4FF),
    lightEnd: Color(0xFFECEAFE),
    lightAccent: Color(0xFF6D28D9),
    lightSecondary: Color(0xFF4338CA),
  );

  static const lavender = AppPalette(
    id: 'lavender',
    name: 'Lavender',
    darkStart: Color(0xFF120D1D),
    darkMid: Color(0xFF2A1B45),
    darkEnd: Color(0xFF3A2355),
    accent: Color(0xFFE9D5FF),
    secondary: Color(0xFFF0ABFC),
    lightStart: Color(0xFFFBF7FF),
    lightEnd: Color(0xFFF4ECFF),
    lightAccent: Color(0xFF7E22CE),
    lightSecondary: Color(0xFFA21CAF),
  );

  static const mono = AppPalette(
    id: 'mono',
    name: 'Mono',
    darkStart: Color(0xFF0A0B0D),
    darkMid: Color(0xFF181A1E),
    darkEnd: Color(0xFF24262B),
    accent: Color(0xFFF4F4F5),
    secondary: Color(0xFFA1A1AA),
    lightStart: Color(0xFFFAFAFA),
    lightEnd: Color(0xFFEFEFEF),
    lightAccent: Color(0xFF18181B),
    lightSecondary: Color(0xFF52525B),
  );

  static const all = [ocean, forest, sunset, midnight, lavender, mono];

  static AppPalette byId(String? id) =>
      all.firstWhere((p) => p.id == id, orElse: () => ocean);
}
