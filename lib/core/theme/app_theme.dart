import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Extra design tokens that Material's ColorScheme does not cover.
class BoxTheme extends ThemeExtension<BoxTheme> {
  const BoxTheme({
    required this.palette,
    required this.glass,
    required this.glassStrong,
    required this.border,
    required this.muted,
    required this.gradient,
  });

  final AppPalette palette;
  final Color glass;
  final Color glassStrong;
  final Color border;
  final Color muted;
  final List<Color> gradient;

  static BoxTheme of(BuildContext context) =>
      Theme.of(context).extension<BoxTheme>()!;

  @override
  BoxTheme copyWith({
    AppPalette? palette,
    Color? glass,
    Color? glassStrong,
    Color? border,
    Color? muted,
    List<Color>? gradient,
  }) {
    return BoxTheme(
      palette: palette ?? this.palette,
      glass: glass ?? this.glass,
      glassStrong: glassStrong ?? this.glassStrong,
      border: border ?? this.border,
      muted: muted ?? this.muted,
      gradient: gradient ?? this.gradient,
    );
  }

  @override
  BoxTheme lerp(ThemeExtension<BoxTheme>? other, double t) {
    if (other is! BoxTheme) return this;
    return BoxTheme(
      palette: t < 0.5 ? palette : other.palette,
      glass: Color.lerp(glass, other.glass, t)!,
      glassStrong: Color.lerp(glassStrong, other.glassStrong, t)!,
      border: Color.lerp(border, other.border, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      gradient: [
        for (var i = 0; i < gradient.length; i++)
          Color.lerp(gradient[i], other.gradient[i % other.gradient.length], t)!,
      ],
    );
  }
}

class AppTheme {
  static ThemeData build(AppPalette palette, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final accent = dark ? palette.accent : palette.lightAccent;
    final secondary = dark ? palette.secondary : palette.lightSecondary;
    final ink = palette.ink(brightness);
    final muted = palette.muted(brightness);
    final surface = palette.surface(brightness);
    final card = palette.card(brightness);

    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
    ).copyWith(
      primary: accent,
      onPrimary: dark ? palette.onPrimary : Colors.white,
      secondary: secondary,
      onSecondary: dark ? palette.onPrimary : Colors.white,
      surface: surface,
      onSurface: ink,
      surfaceContainerLowest: dark ? const Color(0xFF060D16) : Colors.white,
      surfaceContainerLow: dark ? const Color(0xFF0C1723) : const Color(0xFFF2F6F5),
      surfaceContainer: dark ? card : const Color(0xFFEAF1EF),
      surfaceContainerHigh: dark ? const Color(0xFF152333) : const Color(0xFFE3ECEA),
      surfaceContainerHighest: dark ? const Color(0xFF1B2B3C) : const Color(0xFFDCE7E5),
      onSurfaceVariant: muted,
      outline: dark ? const Color(0xFF2B3D4C) : const Color(0xFFC9D6D3),
      outlineVariant: dark ? const Color(0xFF1E2D3A) : const Color(0xFFE0E9E7),
      error: const Color(0xFFFF8A8A),
      onError: const Color(0xFF2A0A0A),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: surface,
      fontFamily: 'Inter',
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
    );

    TextStyle display(double size, FontWeight weight, {double? height}) =>
        TextStyle(
          fontFamily: 'Outfit',
          fontSize: size,
          fontWeight: weight,
          height: height ?? 1.05,
          letterSpacing: -0.7,
          color: ink,
        );

    final textTheme = TextTheme(
      displayLarge: display(54, FontWeight.w600),
      displayMedium: display(44, FontWeight.w600),
      displaySmall: display(36, FontWeight.w600),
      headlineLarge: display(30, FontWeight.w600),
      headlineMedium: display(26, FontWeight.w600),
      headlineSmall: display(22, FontWeight.w600),
      titleLarge: display(20, FontWeight.w600),
      titleMedium: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: ink,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: ink,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: ink),
      bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: ink),
      bodySmall: TextStyle(fontSize: 12.5, height: 1.4, color: muted),
      labelLarge: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: ink,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: muted,
      ),
      labelSmall: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: muted,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: ink),
      ),
      dividerTheme: DividerThemeData(
        color: dark ? const Color(0xFF1D2C39) : const Color(0xFFE1EAE8),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF11202E) : Colors.white,
        hintStyle: TextStyle(color: muted, fontSize: 14),
        labelStyle: TextStyle(color: muted, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: dark ? const Color(0xFF203344) : const Color(0xFFD7E2DF),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: dark ? const Color(0xFF203344) : const Color(0xFFD7E2DF),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        inactiveTrackColor: dark ? const Color(0xFF233444) : const Color(0xFFDDE7E4),
        thumbColor: accent,
        overlayColor: accent.withValues(alpha: 0.12),
        trackHeight: 5,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? (dark ? palette.onPrimary : Colors.white)
              : (dark ? const Color(0xFF7C8E99) : const Color(0xFF8B9C9A)),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? accent
              : (dark ? const Color(0xFF223241) : const Color(0xFFD6E2DF)),
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: accent.withValues(alpha: dark ? 0.16 : 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: 'Outfit',
            fontSize: 11.5,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? ink : muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 23,
            color: states.contains(WidgetState.selected) ? accent : muted,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: dark ? const Color(0xFF0D1A27) : Colors.white,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: dark ? const Color(0xFF0D1A27) : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        showDragHandle: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: dark ? const Color(0xFF0D1A27) : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark ? const Color(0xFF193044) : const Color(0xFF18323E),
        contentTextStyle: const TextStyle(color: Color(0xFFEAF4F5), fontSize: 13.5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: dark ? const Color(0xFF122130) : const Color(0xFFEAF1EF),
        selectedColor: accent.withValues(alpha: dark ? 0.18 : 0.16),
        side: BorderSide(
          color: dark ? const Color(0xFF223444) : const Color(0xFFD7E3E0),
        ),
        labelStyle: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: ink,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: dark ? palette.onPrimary : Colors.white,
          minimumSize: const Size(64, 54),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size(64, 52),
          side: BorderSide(
            color: dark ? const Color(0xFF2A3E50) : const Color(0xFFD4E0DD),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: ink,
          highlightColor: accent.withValues(alpha: 0.12),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: dark ? const Color(0xFF0D1A27) : Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: dark ? const Color(0xFF0D1A27) : Colors.white,
        dialBackgroundColor: dark ? const Color(0xFF142433) : const Color(0xFFF0F5F4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: dark ? const Color(0xFF203140) : const Color(0xFFDDE8E5),
      ),
      extensions: [
        BoxTheme(
          palette: palette,
          glass: dark
              ? Colors.white.withValues(alpha: 0.045)
              : Colors.white.withValues(alpha: 0.78),
          glassStrong: dark
              ? Colors.white.withValues(alpha: 0.075)
              : Colors.white,
          border: dark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE1EBE8),
          muted: muted,
          gradient: dark ? palette.darkGradient() : palette.lightGradient(),
        ),
      ],
    );
  }
}
