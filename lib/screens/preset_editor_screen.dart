import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/visual_style.dart';
import '../core/theme/app_palette.dart';
import '../core/theme/app_theme.dart';
import '../models/breath_pattern.dart';
import '../models/preset.dart';
import '../providers/presets_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/breathing/pattern_preview.dart';
import '../widgets/common/aurora_background.dart';
import '../widgets/common/glass_card.dart';

class PresetEditorScreen extends StatefulWidget {
  const PresetEditorScreen({super.key, this.preset});

  final Preset? preset;

  @override
  State<PresetEditorScreen> createState() => _PresetEditorScreenState();
}

class _PresetEditorScreenState extends State<PresetEditorScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  int _inhale = 4;
  int _hold1 = 4;
  int _exhale = 4;
  int _hold2 = 4;
  int _minutes = 5;
  bool _progressive = false;

  @override
  void initState() {
    super.initState();
    final p = widget.preset;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    if (p != null) {
      _inhale = p.pattern.inhale;
      _hold1 = p.pattern.hold1;
      _exhale = p.pattern.exhale;
      _hold2 = p.pattern.hold2;
      _minutes = p.targetMinutes;
      _progressive = p.progressive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please give your preset a name')),
      );
      return;
    }
    final pattern = BreathPattern(
      inhale: _inhale,
      hold1: _hold1,
      exhale: _exhale,
      hold2: _hold2,
    );
    final preset = Preset(
      id: widget.preset?.id ?? nextPresetId(),
      name: name,
      description: _descController.text.trim(),
      pattern: pattern,
      targetMinutes: _minutes,
      category: PresetCategory.custom,
      progressive: _progressive,
      ambient: 'none',
    );
    await context.read<PresetsProvider>().save(preset);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final palette = AppPalette.byId(settings.paletteId);
    final pattern = BreathPattern(
      inhale: _inhale,
      hold1: _hold1,
      exhale: _exhale,
      hold2: _hold2,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.preset == null ? 'New custom preset' : 'Edit preset'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: AuroraBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              SizedBox(
                height: 180,
                child: GlassCard(
                  child: Center(
                    child: SizedBox(
                      width: 130,
                      height: 130,
                      child: PatternPreview(
                        pattern: pattern,
                        style: settings.visualStyle,
                        palette: palette,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Preset name'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Short note or intention'),
              ),
              const SizedBox(height: 24),
              Text('Phase durations (seconds)',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _slider('Inhale', _inhale, (v) => setState(() => _inhale = v)),
                    _slider('Hold 1', _hold1, (v) => setState(() => _hold1 = v)),
                    _slider('Exhale', _exhale, (v) => setState(() => _exhale = v)),
                    _slider('Hold 2', _hold2, (v) => setState(() => _hold2 = v)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
                              Text('Default duration',
                                  style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600)),
                              Text('Minutes per session',
                                  style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        DropdownButton<int>(
                          value: _minutes,
                          items: [2, 3, 5, 8, 10, 15, 20]
                              .map((m) => DropdownMenuItem(
                                  value: m, child: Text('$m min')))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _minutes = val ?? 5),
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
                              Text('Progressive training',
                                  style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600)),
                              Text('Add +1s every 5 cycles',
                                  style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Switch(
                          value: _progressive,
                          onChanged: (val) =>
                              setState(() => _progressive = val),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _slider(String label, int val, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(
            child: Slider(
              value: val.toDouble(),
              min: label.contains('Hold') ? 0 : 1,
              max: 20,
              divisions: 20,
              label: '$val s',
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$val s',
              textAlign: TextAlign.end,
              style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
