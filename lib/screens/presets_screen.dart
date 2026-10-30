import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_palette.dart';
import '../core/theme/app_theme.dart';
import '../models/preset.dart';
import '../providers/presets_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/breathing/pattern_preview.dart';
import '../widgets/common/aurora_background.dart';
import '../widgets/common/glass_card.dart';
import 'preset_editor_screen.dart';
import 'session_screen.dart';

class PresetsScreen extends StatefulWidget {
  const PresetsScreen({super.key});

  @override
  State<PresetsScreen> createState() => _PresetsScreenState();
}

class _PresetsScreenState extends State<PresetsScreen> {
  PresetCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final presets = context.watch<PresetsProvider>();
    final settings = context.watch<SettingsProvider>();
    final palette = AppPalette.byId(settings.paletteId);
    final box = BoxTheme.of(context);

    final list = _filter == null
        ? presets.all
        : presets.all.where((p) => p.category == _filter).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PresetEditorScreen()),
        ),
        backgroundColor: palette.accent,
        foregroundColor: const Color(0xFF07121F),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Custom'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
          children: [
            Row(
              children: [
                Text('Presets', style: Theme.of(context).textTheme.headlineMedium),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PresetEditorScreen()),
                  ),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                  for (final cat in PresetCategory.values)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: FilterChip(
                        label: Text(cat.label),
                        selected: _filter == cat,
                        onSelected: (val) =>
                            setState(() => _filter = val ? cat : null),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            for (final p in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GlassCard(
                  onTap: () {
                    presets.select(p);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SessionScreen(preset: p),
                      ),
                    );
                  },
                  padding: const EdgeInsets.all(18),
                  borderColor:
                      presets.selected.id == p.id ? palette.accent : null,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: PatternPreview(
                          pattern: p.pattern,
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
                            Row(
                              children: [
                                Text(
                                  p.name,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                if (p.isBuiltIn) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: box.muted.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Built-in',
                                      style: TextStyle(
                                          fontSize: 9, color: box.muted),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              p.description,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              p.pattern.label,
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: palette.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded),
                        onSelected: (val) async {
                          if (val == 'edit') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PresetEditorScreen(preset: p),
                              ),
                            );
                          } else if (val == 'duplicate') {
                            await presets.duplicate(p);
                          } else if (val == 'delete') {
                            await presets.delete(p);
                          } else if (val == 'favorite') {
                            await presets.toggleFavorite(p);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'favorite',
                            child: Text(p.isFavorite
                                ? 'Remove favorite'
                                : 'Favorite'),
                          ),
                          PopupMenuItem(
                            value: 'duplicate',
                            child: const Text('Duplicate'),
                          ),
                          if (!p.isBuiltIn) ...[
                            PopupMenuItem(
                              value: 'edit',
                              child: const Text('Edit'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                'Delete',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
