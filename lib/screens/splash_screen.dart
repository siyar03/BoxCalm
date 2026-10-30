import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_palette.dart';
import '../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../widgets/common/aurora_background.dart';
import '../widgets/common/logo_mark.dart';
import 'home_shell.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _timer = Timer(const Duration(milliseconds: 1850), _go);
  }

  void _go() {
    if (!mounted) return;
    final settings = context.read<SettingsProvider>();
    final page = settings.onboardingComplete
        ? const HomeShell()
        : const OnboardingScreen();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondary) => FadeTransition(
          opacity: animation,
          child: page,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.byId(context.watch<SettingsProvider>().paletteId);
    final theme = AppTheme.build(palette, Brightness.dark);
    return Theme(
      data: theme,
      child: Scaffold(
        body: AuroraBackground(
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = Curves.easeOutCubic.transform(_controller.value);
                return Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(0, 18 * (1 - t)),
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 118,
                    height: 118,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          palette.accent.withValues(alpha: 0.16),
                          palette.accent.withValues(alpha: 0.01),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: LogoMark(size: 72, stroke: 4.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'BoxCalm',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontSize: 40,
                      letterSpacing: -1.4,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A quieter mind, one breath at a time.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF8FA9B4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
