import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_palette.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/format.dart';
import '../models/preset.dart';
import '../models/session_record.dart';
import '../providers/session_controller.dart';
import '../providers/settings_provider.dart';
import '../providers/stats_provider.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';
import '../widgets/breathing/breathing_visual.dart';
import '../widgets/breathing/phase_readout.dart';
import '../widgets/common/aurora_background.dart';
import '../widgets/common/logo_mark.dart';
import 'summary_screen.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({
    super.key,
    required this.preset,
    this.targetMinutes,
    this.targetCycles,
  });

  final Preset preset;
  final int? targetMinutes;
  final int? targetCycles;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  SessionController? _controller;
  bool _launchingSummary = false;
  bool _showChrome = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  void _start() {
    if (!mounted || _controller != null) return;
    final settings = context.read<SettingsProvider>();
    final controller = SessionController(
      vsync: this,
      preset: widget.preset,
      settings: settings,
      audio: context.read<AudioService>(),
      haptics: context.read<HapticService>(),
      targetMinutes: widget.targetMinutes,
      targetCycles: widget.targetCycles,
      onFinished: _onFinished,
    );
    setState(() => _controller = controller);
    controller.start();
  }

  Future<void> _onFinished(SessionResult result) async {
    if (!mounted || _launchingSummary) return;
    _launchingSummary = true;
    final moodRecord = SessionRecord(
      id: 'session_${result.startedAt.millisecondsSinceEpoch}',
      startedAt: result.startedAt,
      durationSec: result.durationSec,
      cyclesDone: result.cycles,
      presetId: result.preset.id,
      presetName: result.preset.name,
      completed: result.completed,
      patternLabel: result.pattern.label.replaceAll(' · ', '-'),
    );
    if (result.durationSec >= 3) {
      try {
        await context.read<StatsProvider>().addSession(moodRecord);
      } catch (_) {}
    }
    if (!mounted) return;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondary) => FadeTransition(
          opacity: animation,
          child: SummaryScreen(
            result: result,
            record: moodRecord,
          ),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    final settings = context.read<SettingsProvider>();
    if (!settings.autoPause) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _controller?.pauseBySystem();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    super.dispose();
  }

  Future<void> _confirmStop() async {
    final shouldStop = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: const Color(0xFF0E1C29),
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'End this session?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Your progress so far will still be saved.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: const Color(0xFF9BB0BB)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Keep breathing'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Finish'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (shouldStop == true) {
      _controller?.stopEarly();
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.byId(
      context.watch<SettingsProvider>().paletteId,
    );
    final settings = context.watch<SettingsProvider>();
    final controller = _controller;
    final darkTheme = AppTheme.build(palette, Brightness.dark);

    return Theme(
      data: darkTheme,
      child: Scaffold(
        body: AuroraBackground(
          child: SafeArea(
            child: AnimatedBuilder(
              animation: controller ?? const AlwaysStoppedAnimation(0),
              builder: (context, _) {
                final phase = controller?.phase ?? BreathPhase.idle;
                final paused = controller?.paused ?? false;
                return Stack(
                  children: [
                    Column(
                      children: [
                        _TopBar(
                          preset: widget.preset,
                          elapsed: formatClock(controller?.elapsedSec ?? 0),
                          hapticsOn: settings.hapticsEnabled,
                          onClose: _confirmStop,
                          onHaptics: () => settings.setHapticsEnabled(
                            !settings.hapticsEnabled,
                          ),
                        ),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final visualSize = constraints.maxHeight < 560
                                  ? constraints.maxWidth * 0.62
                                  : constraints.maxWidth.clamp(260.0, 420.0);
                              return Column(
                                children: [
                                  const Spacer(flex: 2),
                                  SizedBox(
                                    width: visualSize,
                                    height: visualSize,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        BreathingVisual(
                                          phase: phase,
                                          progress: controller?.phaseProgress ?? 0,
                                          style: settings.visualStyle,
                                          palette: palette,
                                          reduceMotion: settings.reduceMotion,
                                          cycle: controller?.cycles ?? 0,
                                        ),
                                        if (phase == BreathPhase.idle)
                                          const LogoMark(size: 52),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  PhaseReadout(
                                    phase: phase,
                                    remaining: controller?.phaseRemaining ??
                                        widget.preset.pattern.inhale,
                                    accent: palette.accent,
                                  ),
                                  const Spacer(),
                                  _CycleSummary(
                                    preset: widget.preset,
                                    cycle: controller?.cycles ?? 0,
                                    target: controller?.targetLabel ??
                                        widget.preset.targetLabel,
                                    showDots: settings.showCycleDots,
                                    targetCycles:
                                        controller?.targetCycleCount ?? 0,
                                  ),
                                  const Spacer(),
                                  _Controls(
                                    paused: paused,
                                    onPause: () => controller?.togglePause(),
                                    onStop: _confirmStop,
                                  ),
                                  const SizedBox(height: 18),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    if (paused)
                      _PausedOverlay(
                        systemPaused: controller?.systemPaused ?? false,
                        onResume: () => controller?.togglePause(),
                        onStop: _confirmStop,
                      ),
                    if (!_showChrome)
                      const SizedBox.shrink(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.preset,
    required this.elapsed,
    required this.hapticsOn,
    required this.onClose,
    required this.onHaptics,
  });

  final Preset preset;
  final String elapsed;
  final bool hapticsOn;
  final VoidCallback onClose;
  final VoidCallback onHaptics;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, color: Colors.white70),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  preset.name,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  elapsed,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF8EA4AF),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onHaptics,
            icon: Icon(
              hapticsOn
                  ? Icons.vibration_rounded
                  : Icons.phonelink_erase_rounded,
              color: hapticsOn ? Colors.white : Colors.white38,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }
}

class _CycleSummary extends StatelessWidget {
  const _CycleSummary({
    required this.preset,
    required this.cycle,
    required this.target,
    required this.showDots,
    required this.targetCycles,
  });

  final Preset preset;
  final int cycle;
  final String target;
  final bool showDots;
  final int targetCycles;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showDots && targetCycles > 0 && targetCycles <= 24) ...[
          Wrap(
            spacing: 5,
            runSpacing: 5,
            alignment: WrapAlignment.center,
            children: [
              for (var i = 0; i < targetCycles; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < cycle
                        ? const Color(0xFF5EEAD4)
                        : Colors.white.withValues(alpha: 0.16),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        Text(
          cycle == 0 ? 'Settle in' : 'Cycle $cycle',
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFFB4C5CE),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          target,
          style: const TextStyle(
            fontSize: 11.5,
            color: Color(0xFF78909C),
          ),
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.paused,
    required this.onPause,
    required this.onStop,
  });

  final bool paused;
  final VoidCallback onPause;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: onStop,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white54,
            minimumSize: const Size(72, 48),
          ),
          child: const Text('End'),
        ),
        const SizedBox(width: 28),
        GestureDetector(
          onTap: onPause,
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: paused
                    ? [const Color(0xFF5EEAD4), const Color(0xFF38BDF8)]
                    : [
                        Colors.white.withValues(alpha: 0.14),
                        Colors.white.withValues(alpha: 0.07),
                      ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.16),
              ),
              boxShadow: paused
                  ? [
                      BoxShadow(
                        color: const Color(0xFF5EEAD4).withValues(alpha: 0.28),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              color: paused ? const Color(0xFF06131B) : Colors.white,
              size: 36,
            ),
          ),
        ),
        const SizedBox(width: 28),
        const SizedBox(width: 72),
      ],
    );
  }
}

class _PausedOverlay extends StatelessWidget {
  const _PausedOverlay({
    required this.systemPaused,
    required this.onResume,
    required this.onStop,
  });

  final bool systemPaused;
  final VoidCallback onResume;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0xFF04101A).withValues(alpha: 0.82),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pause_circle_outline_rounded,
                  color: Color(0xFF5EEAD4), size: 46),
              const SizedBox(height: 16),
              Text(
                systemPaused ? 'Paused for you' : 'Paused',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                systemPaused
                    ? 'Your session waits until you are ready.'
                    : 'Take your time. The breath will wait.',
                style: const TextStyle(color: Color(0xFF93A9B5), fontSize: 13),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: onResume,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Resume'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: onStop,
                child: const Text('End session'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
