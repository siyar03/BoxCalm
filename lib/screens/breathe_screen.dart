import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/visual_style.dart';
import '../core/theme/app_palette.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/format.dart';
import '../models/preset.dart';
import '../providers/presets_provider.dart';
import '../providers/reminders_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/stats_provider.dart';
import '../widgets/breathing/pattern_preview.dart';
import '../widgets/common/glass_card.dart';
import '../widgets/common/progress_ring.dart';
import 'learn_screen.dart';
import 'preset_editor_screen.dart';
import 'reminders_screen.dart';
import 'session_screen.dart';

class BreatheScreen extends StatefulWidget {
  const BreatheScreen({super.key, required this.onOpenPresets});

  final VoidCallback onOpenPresets;

  @override
  State<BreatheScreen> createState() => _BreatheScreenState();
}

class _BreatheScreenState extends State<BreatheScreen> {
  int _targetMinutes = 5;
  int? _targetCycles;
  bool _useCycles = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _targetMinutes = settings.defaultMinutes;
  }

  void _start(PresetsProvider presets) {
    final selected = presets.selected;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SessionScreen(
          preset: selected,
          targetMinutes: _useCycles ? null : _targetMinutes,
          targetCycles: _useCycles ? (_targetCycles ?? selected.targetCycles ?? 8) : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final palette = AppPalette.byId(settings.paletteId);
    final stats = context.watch<StatsProvider>();
    final presets = context.watch<PresetsProvider>();
    final reminders = context.watch<RemindersProvider>();

    final selected = presets.selected;
    final snapshot = stats.snapshot;
    final goalMin = settings.dailyGoalMin;
    final todayMin = snapshot.todayMinutes;
    final goalProgress = (todayMin / (goalMin == 0 ? 10 : goalMin)).clamp(0.0, 1.0);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greetingForHour(DateTime.now().hour),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: palette.accent),
                    ),
                    const SizedBox(height: 2),
                    Text('BoxCalm', style: Theme.of(context).textTheme.headlineMedium),
                  ],
                ),
                const Spacer(),
                if (snapshot.currentStreak > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDBA74).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: const Color(0xFFFDBA74).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          '${snapshot.currentStreak} day${snapshot.currentStreak == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFDBA74),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            GlassCard(
              padding: const EdgeInsets.all(20),
              gradient: [
                palette.darkStart.withValues(alpha: 0.85),
                palette.darkMid.withValues(alpha: 0.75),
              ],
              borderColor: palette.accent.withValues(alpha: 0.22),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily practice',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: palette.accent,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${todayMin.toStringAsFixed(1)} / $goalMin min',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.currentStreak == 0
                              ? 'Take your first calm breath today.'
                              : 'Keep your streak alive. You are doing great.',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF9BB0BB),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ProgressRing(
                    progress: goalProgress,
                    size: 78,
                    stroke: 7,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(goalProgress * 100).round()}%',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Ready to breathe?',
              actionLabel: 'Change',
              onAction: widget.onOpenPresets,
            ),
            GlassCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 54,
                        height: 54,
                        child: PatternPreview(
                          pattern: selected.pattern,
                          style: settings.visualStyle,
                          palette: palette,
                          animate: false,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selected.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              selected.pattern.label,
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: palette.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => presets.toggleFavorite(selected),
                        icon: Icon(
                          selected.isFavorite
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: selected.isFavorite
                              ? const Color(0xFFFDBA74)
                              : BoxTheme.of(context).muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      selected.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final m in [3, 5, 10, 15])
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text('$m min'),
                            selected: !_useCycles && _targetMinutes == m,
                            onSelected: (val) {
                              if (val) {
                                setState(() {
                                  _useCycles = false;
                                  _targetMinutes = m;
                                });
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GradientButton(
                    label: 'Start session',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () => _start(presets),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Quick presets'),
            SizedBox(
              height: 124,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final p in presets.all.take(6))
                    _PresetCarouselCard(
                      preset: p,
                      selected: p.id == selected.id,
                      palette: palette,
                      onTap: () => presets.select(p),
                      onPlay: () {
                        presets.select(p);
                        _start(presets);
                      },
                    ),
                ],
              ),
            ),
            if (reminders.nextReminder != null) ...[
              const SizedBox(height: 16),
              GlassCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RemindersScreen()),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.notifications_active_outlined,
                        color: palette.accent),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next reminder · ${reminders.nextReminder!.formattedTime}',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            reminders.nextReminder!.daysLabel,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            GlassCard(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LearnScreen()),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('📖', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'The Science of Box Breathing',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Learn how slow holds regulate the vagus nerve.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetCarouselCard extends StatelessWidget {
  const _PresetCarouselCard({
    required this.preset,
    required this.selected,
    required this.palette,
    required this.onTap,
    required this.onPlay,
  });

  final Preset preset;
  final bool selected;
  final AppPalette palette;
  final VoidCallback onTap;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final box = BoxTheme.of(context);
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        borderColor: selected ? palette.accent : box.border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    preset.name,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: onPlay,
                  child: Icon(
                    Icons.play_circle_filled_rounded,
                    color: palette.accent,
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              preset.pattern.label,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: palette.accent,
              ),
            ),
            const Spacer(),
            Text(
              preset.category.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10.5),
            ),
          ],
        ),
      ),
    );
  }
}
