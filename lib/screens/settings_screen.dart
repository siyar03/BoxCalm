import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/visual_style.dart';
import '../core/theme/app_palette.dart';
import '../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../widgets/common/glass_card.dart';
import 'about_screen.dart';
import 'learn_screen.dart';
import 'reminders_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final palette = AppPalette.byId(settings.paletteId);
    final box = BoxTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
        children: [
          Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Theme', style: TextStyle(fontWeight: FontWeight.w600)),
                          Text('Dark, light or system', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    DropdownButton<String>(
                      value: settings.themeModeId,
                      items: const [
                        DropdownMenuItem(value: 'dark', child: Text('Dark')),
                        DropdownMenuItem(value: 'light', child: Text('Light')),
                        DropdownMenuItem(value: 'system', child: Text('System')),
                      ],
                      onChanged: (val) => settings.setThemeMode(val ?? 'dark'),
                    ),
                  ],
                ),
                const Divider(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Color palette', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final p in AppPalette.all)
                        GestureDetector(
                          onTap: () => settings.setPalette(p.id),
                          child: Container(
                            width: 48,
                            height: 48,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: p.darkGradient()),
                              border: Border.all(
                                color: settings.paletteId == p.id
                                    ? palette.accent
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            child: settings.paletteId == p.id
                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                                : null,
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Animation style', style: TextStyle(fontWeight: FontWeight.w600)),
                          Text('Visual guide preference', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    DropdownButton<VisualStyle>(
                      value: settings.visualStyle,
                      items: VisualStyle.values
                          .map((v) => DropdownMenuItem(value: v, child: Text(v.label)))
                          .toList(),
                      onChanged: (val) =>
                          settings.setVisualStyle(val ?? VisualStyle.box),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reduce motion', style: TextStyle(fontWeight: FontWeight.w600)),
                          Text('Simpler animations', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Switch(
                      value: settings.reduceMotion,
                      onChanged: (val) => settings.setReduceMotion(val),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Sound & Haptics', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('Sound enabled', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    Switch(
                      value: settings.soundEnabled,
                      onChanged: (val) => settings.setSoundEnabled(val),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: Text('Phase chimes', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    Switch(
                      value: settings.chimeEnabled,
                      onChanged: (val) => settings.setChimeEnabled(val),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: Text('Haptics', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    Switch(
                      value: settings.hapticsEnabled,
                      onChanged: (val) => settings.setHapticsEnabled(val),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Reminders & Habits', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          GlassCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RemindersScreen()),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.notifications_outlined),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text('Manage reminders', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                Icon(Icons.chevron_right_rounded, color: box.muted),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Session defaults', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Preparation countdown', style: TextStyle(fontWeight: FontWeight.w600)),
                          Text('Get ready before start', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    DropdownButton<int>(
                      value: settings.prepSeconds,
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Off')),
                        DropdownMenuItem(value: 3, child: Text('3 seconds')),
                        DropdownMenuItem(value: 5, child: Text('5 seconds')),
                      ],
                      onChanged: (val) => settings.setPrepSeconds(val ?? 3),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Keep screen awake', style: TextStyle(fontWeight: FontWeight.w600)),
                          Text('Prevent sleep during session', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Switch(
                      value: settings.keepAwake,
                      onChanged: (val) => settings.setKeepAwake(val),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('About & Help', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          GlassCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LearnScreen()),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.menu_book_rounded),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text('Learn & Technique', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                Icon(Icons.chevron_right_rounded, color: box.muted),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GlassCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text('About BoxCalm', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                Icon(Icons.chevron_right_rounded, color: box.muted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
