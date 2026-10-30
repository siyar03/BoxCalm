import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/theme/app_palette.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/format.dart';
import '../models/session_record.dart';
import '../providers/session_controller.dart';
import '../providers/settings_provider.dart';
import '../providers/stats_provider.dart';
import '../widgets/common/aurora_background.dart';
import '../widgets/common/glass_card.dart';
import '../widgets/common/logo_mark.dart';
import 'session_screen.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({
    super.key,
    required this.result,
    required this.record,
  });

  final SessionResult result;
  final SessionRecord record;

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  int? _mood;

  static const _moods = [
    ('😣', 'Heavy'),
    ('😕', 'Low'),
    ('😐', 'Okay'),
    ('🙂', 'Good'),
    ('😌', 'Calm'),
  ];

  @override
  void initState() {
    super.initState();
    _mood = widget.record.moodAfter;
  }

  Future<void> _selectMood(int mood) async {
    setState(() => _mood = mood);
    await context.read<StatsProvider>().updateMood(widget.record.id, mood);
  }

  Future<void> _share() async {
    final stats = context.read<StatsProvider>().snapshot;
    final text = 'I just took ${formatClock(widget.result.durationSec)} to breathe with BoxCalm. '
        '${widget.result.cycles} cycles, ${stats.currentStreak}-day streak. 🌿';
    try {
      await Share.share(text, subject: 'A calm moment with BoxCalm');
    } catch (_) {}
  }

  void _breatheAgain() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SessionScreen(preset: widget.result.preset),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.byId(context.watch<SettingsProvider>().paletteId);
    final stats = context.watch<StatsProvider>();
    final newBadge =
        stats.newUnlocks.isEmpty ? null : stats.newUnlocks.first;
    final result = widget.result;
    final avg = result.cycles == 0
        ? 0
        : (result.durationSec / result.cycles).round();

    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            child: Column(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.6, end: 1),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) =>
                      Transform.scale(scale: value, child: child),
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          palette.accent.withValues(alpha: 0.24),
                          palette.secondary.withValues(alpha: 0.10),
                        ],
                      ),
                      border: Border.all(
                        color: palette.accent.withValues(alpha: 0.25),
                      ),
                    ),
                    child: result.completed
                        ? Icon(Icons.check_rounded,
                            size: 44, color: palette.accent)
                        : const LogoMark(size: 44),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  result.completed ? 'Well done' : 'A moment counted',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  result.completed
                      ? 'You gave yourself ${formatMinutes((result.durationSec / 60).ceil())} of quiet.'
                      : 'Even a short pause is a real pause. Come back when you are ready.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: BoxTheme.of(context).muted,
                      ),
                ),
                const SizedBox(height: 28),
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryStat(
                              value: formatClock(result.durationSec),
                              label: 'Time',
                            ),
                          ),
                          _Divider(),
                          Expanded(
                            child: _SummaryStat(
                              value: '${result.cycles}',
                              label: 'Cycles',
                            ),
                          ),
                          _Divider(),
                          Expanded(
                            child: _SummaryStat(
                              value: '${result.cycles * 4}',
                              label: 'Breaths',
                            ),
                          ),
                          _Divider(),
                          Expanded(
                            child: _SummaryStat(
                              value: '${avg}s',
                              label: 'Avg',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      MiniPatternBar(segments: result.pattern.segments),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            result.preset.name,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            result.pattern.label,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: palette.accent),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (newBadge != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: newBadge.color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: newBadge.color.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(newBadge.emoji,
                            style: const TextStyle(fontSize: 26)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'New badge · ${newBadge.title}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(color: newBadge.color),
                              ),
                              Text(
                                newBadge.description,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 26),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'How do you feel now?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var i = 0; i < _moods.length; i++)
                      GestureDetector(
                        onTap: () => _selectMood(i + 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: 58,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _mood == i + 1
                                ? palette.accent.withValues(alpha: 0.14)
                                : Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: _mood == i + 1
                                  ? palette.accent.withValues(alpha: 0.5)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _moods[i].$1,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _moods[i].$2,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: _mood == i + 1
                                      ? palette.accent
                                      : BoxTheme.of(context).muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 28),
                GradientButton(
                  label: 'Save & finish',
                  icon: Icons.check_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _share,
                        icon: const Icon(Icons.ios_share_rounded, size: 18),
                        label: const Text('Share'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _breatheAgain,
                        icon: const Icon(Icons.replay_rounded, size: 18),
                        label: const Text('Again'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Streak: ${stats.snapshot.currentStreak} days · '
                  '${formatMinutes(stats.snapshot.totalMinutes)} total',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 23,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      color: BoxTheme.of(context).border,
    );
  }
}
