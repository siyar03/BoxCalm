import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';

import '../core/constants/achievements.dart';
import '../core/theme/app_palette.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/format.dart';
import '../providers/settings_provider.dart';
import '../providers/stats_provider.dart';
import '../widgets/common/glass_card.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>();
    final settings = context.watch<SettingsProvider>();
    final palette = AppPalette.byId(settings.paletteId);
    final snapshot = stats.snapshot;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        actions: [
          IconButton(
            onPressed: () {
              final jsonStr = stats.exportJson();
              Share.share(jsonStr, subject: 'BoxCalm backup');
            },
            icon: const Icon(Icons.ios_share_rounded),
          ),
          PopupMenuButton<String>(
            onSelected: (val) async {
              if (val == 'csv') {
                final csv = stats.exportCsv();
                Share.share(csv, subject: 'BoxCalm sessions CSV');
              } else if (val == 'clear') {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear history?'),
                    content: const Text(
                        'This will delete all saved sessions and achievements permanently.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Clear')),
                    ],
                  ),
                );
                if (ok == true) await stats.clearHistory();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'csv', child: Text('Export CSV')),
              const PopupMenuItem(
                  value: 'clear', child: Text('Clear history')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Badges'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(snapshot: snapshot, palette: palette),
          _BadgesTab(stats: stats, palette: palette),
          _HistoryTab(stats: stats, palette: palette),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.snapshot, required this.palette});

  final StatsSnapshot snapshot;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      children: [
        Row(
          children: [
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Streak', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Text(
                          '${snapshot.currentStreak}',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(' days', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('Best: ${snapshot.longestStreak} days',
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total time', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 6),
                    Text(
                      formatMinutes(snapshot.totalMinutes),
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text('${snapshot.completedSessions} sessions',
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('This week', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 24),
              SizedBox(
                height: 170,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (snapshot.week
                                .map((e) => e.minutes)
                                .fold<int>(10, (a, b) => a > b ? a : b) *
                            1.2)
                        .toDouble(),
                    barTouchData: BarTouchData(enabled: true),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (val, meta) {
                            final idx = val.toInt();
                            if (idx < 0 || idx >= snapshot.week.length) {
                              return const Text('');
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                weekdayInitial(snapshot.week[idx].date.weekday - 1),
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      for (var i = 0; i < snapshot.week.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: snapshot.week[i].minutes.toDouble(),
                              color: snapshot.week[i].minutes > 0
                                  ? palette.accent
                                  : BoxTheme.of(context).border,
                              width: 14,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BadgesTab extends StatelessWidget {
  const _BadgesTab({required this.stats, required this.palette});

  final StatsProvider stats;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final unlockedIds = stats.unlocked;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.15,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final badge = achievements[index];
        final isUnlocked = unlockedIds.containsKey(badge.id);
        return GlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(badge.emoji, style: const TextStyle(fontSize: 26)),
                  const Spacer(),
                  Icon(
                    isUnlocked
                        ? Icons.check_circle_rounded
                        : Icons.lock_outline_rounded,
                    size: 18,
                    color: isUnlocked ? palette.accent : Colors.grey.shade600,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                badge.title,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isUnlocked ? null : Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                badge.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.stats, required this.palette});

  final StatsProvider stats;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final list = stats.sessions;
    if (list.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: Icons.history_rounded,
          title: 'No sessions yet',
          message: 'Complete your first breathing session to see it here.',
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final s = list[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: palette.accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    s.completed ? Icons.air_rounded : Icons.pause_rounded,
                    color: palette.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.presetName,
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        '${formatClock(s.durationSec)} · ${s.cyclesDone} cycles',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      relativeDayLabel(s.startedAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    IconButton(
                      onPressed: () => stats.deleteSession(s.id),
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      color: Colors.grey,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
