import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/visual_style.dart';
import '../core/theme/app_palette.dart';
import '../core/theme/app_theme.dart';
import '../models/breath_pattern.dart';
import '../providers/reminders_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/breathing/pattern_preview.dart';
import '../widgets/common/aurora_background.dart';
import '../widgets/common/logo_mark.dart';
import 'home_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;
  bool _finishing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish({bool askPermissions = false}) async {
    if (_finishing) return;
    _finishing = true;
    if (askPermissions) {
      await context.read<RemindersProvider>().requestPermissions();
    }
    if (!mounted) return;
    await context.read<SettingsProvider>().setOnboardingComplete(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondary) => FadeTransition(
          opacity: animation,
          child: const HomeShell(),
        ),
      ),
    );
  }

  void _next() {
    if (_index == 2) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.byId(context.watch<SettingsProvider>().paletteId);
    final darkTheme = AppTheme.build(palette, Brightness.dark);
    return Theme(
      data: darkTheme,
      child: Scaffold(
        body: AuroraBackground(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
                  child: Row(
                    children: [
                      const LogoMark(size: 30),
                      const SizedBox(width: 10),
                      const Text(
                        'BoxCalm',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _finish(),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF8FA6B2),
                        ),
                        child: const Text('Skip'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _index = i),
                    children: [
                      _Page(
                        illustration: _RingsIllustration(palette: palette),
                        eyebrow: 'WELCOME',
                        title: 'Give your breath\na shape',
                        body:
                            'Box breathing is four equal sides: inhale, hold, exhale, hold. '
                            'The steady rhythm is used by athletes, pilots and meditators to settle the nervous system.',
                      ),
                      _Page(
                        illustration: SizedBox(
                          width: 250,
                          height: 250,
                          child: PatternPreview(
                            pattern: BreathPattern.box,
                            style: VisualStyle.box,
                            palette: palette,
                          ),
                        ),
                        eyebrow: 'THE PRACTICE',
                        title: 'No screen\nrequired',
                        body:
                            'Close your eyes. Soft haptics and a calm voice guide every phase, '
                            'so you can follow the breath without watching the clock.',
                      ),
                      _Page(
                        illustration: _ReminderIllustration(palette: palette),
                        eyebrow: 'A SMALL RITUAL',
                        title: 'A gentle nudge,\nnot a nag',
                        body:
                            'Choose a time or two and BoxCalm will offer a quiet reminder. '
                            'Everything stays on your device — no account, no ads, no cloud.',
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < 3; i++)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 260),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: i == _index ? 24 : 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: i == _index
                                    ? palette.accent
                                    : Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      if (_index < 2)
                        GradientButton(
                          label: 'Continue',
                          onPressed: _next,
                          icon: Icons.arrow_forward_rounded,
                        )
                      else ...[
                        GradientButton(
                          label: 'Enable gentle reminders',
                          icon: Icons.notifications_none_rounded,
                          onPressed: () => _finish(askPermissions: true),
                        ),
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: () => _finish(),
                          child: const Text('Not now — start breathing'),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({
    required this.illustration,
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  final Widget illustration;
  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 10, 28, 0),
      child: Column(
        children: [
          const Spacer(flex: 2),
          SizedBox(height: 270, child: Center(child: illustration)),
          const Spacer(flex: 2),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              eyebrow,
              style: const TextStyle(
                fontSize: 10.5,
                letterSpacing: 2.2,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5EEAD4),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 38,
                height: 1.05,
                letterSpacing: -1.2,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              body,
              style: const TextStyle(
                fontSize: 14,
                height: 1.55,
                color: Color(0xFF9BB0BB),
              ),
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

class _RingsIllustration extends StatelessWidget {
  const _RingsIllustration({required this.palette});
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 4; i >= 1; i--)
            Container(
              width: 80.0 + i * 36,
              height: 80.0 + i * 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: palette.accent.withValues(alpha: 0.05 + i * 0.025),
                ),
              ),
            ),
          Container(
            width: 106,
            height: 106,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  palette.accent.withValues(alpha: 0.22),
                  palette.accent.withValues(alpha: 0.02),
                ],
              ),
            ),
            child: const Center(child: LogoMark(size: 58, stroke: 4)),
          ),
          Positioned(
            right: 8,
            top: 34,
            child: _TinyLabel(label: '4', color: palette.accent),
          ),
          Positioned(
            left: 4,
            bottom: 52,
            child: _TinyLabel(label: '4', color: palette.accent),
          ),
          Positioned(
            right: 24,
            bottom: 18,
            child: _TinyLabel(label: '4', color: palette.secondary),
          ),
        ],
      ),
    );
  }
}

class _TinyLabel extends StatelessWidget {
  const _TinyLabel({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0B1925),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Outfit',
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ReminderIllustration extends StatelessWidget {
  const _ReminderIllustration({required this.palette});
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: palette.accent.withValues(alpha: 0.12),
              ),
            ),
          ),
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  palette.accent.withValues(alpha: 0.22),
                  palette.secondary.withValues(alpha: 0.10),
                ],
              ),
              border: Border.all(
                color: palette.accent.withValues(alpha: 0.25),
              ),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: palette.accent,
              size: 52,
            ),
          ),
          Positioned(
            right: 10,
            top: 44,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0C1B28),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
              child: const Text(
                '20:30  ·  Breathe',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFCFE0E6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

