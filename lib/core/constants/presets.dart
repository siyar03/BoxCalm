import '../../models/breath_pattern.dart';
import '../../models/preset.dart';

List<Preset> builtInPresets() => [
      Preset(
        id: 'builtin_box_4444',
        name: 'Classic Box',
        description:
            'The balanced 4-4-4-4 rhythm used by athletes and first responders. Even, steady, grounding.',
        pattern: BreathPattern.box,
        targetMinutes: 5,
        isBuiltIn: true,
        category: PresetCategory.tactical,
        ambient: 'ocean',
        sortOrder: 0,
      ),
      Preset(
        id: 'builtin_extended_5555',
        name: 'Extended Box',
        description:
            'A longer 5-5-5-5 box for a deeper settle. Good when the mind is still racing after the first minute.',
        pattern: const BreathPattern(inhale: 5, hold1: 5, exhale: 5, hold2: 5),
        targetMinutes: 6,
        isBuiltIn: true,
        category: PresetCategory.tactical,
        sortOrder: 1,
      ),
      Preset(
        id: 'builtin_relax_478',
        name: '4-7-8 Unwind',
        description:
            'A long exhale favourite for winding down. The extended hold gently slows a busy nervous system.',
        pattern: const BreathPattern(inhale: 4, hold1: 7, exhale: 8, hold2: 0),
        targetMinutes: 4,
        isBuiltIn: true,
        category: PresetCategory.relax,
        ambient: 'rain',
        sortOrder: 2,
      ),
      Preset(
        id: 'builtin_coherent_5050',
        name: 'Coherent 5-5',
        description:
            'Slow, equal breathing at roughly six breaths a minute — a simple way to find coherence.',
        pattern: const BreathPattern(inhale: 5, hold1: 0, exhale: 5, hold2: 0),
        targetMinutes: 5,
        isBuiltIn: true,
        category: PresetCategory.relax,
        ambient: 'forest',
        sortOrder: 3,
      ),
      Preset(
        id: 'builtin_energy_6020',
        name: 'Morning Lift',
        description:
            'A crisp inhale and a short exhale. Use it to shake off heaviness without overstimulating.',
        pattern: const BreathPattern(inhale: 6, hold1: 0, exhale: 2, hold2: 0),
        targetMinutes: 2,
        isBuiltIn: true,
        category: PresetCategory.energy,
        sortOrder: 4,
      ),
      Preset(
        id: 'builtin_sleep_478',
        name: 'Sleep Wind-Down',
        description:
            'Eight rounds of 4-7-8, sized for the edge of sleep. Lie down, soften the jaw, let the exhale go.',
        pattern: const BreathPattern(inhale: 4, hold1: 7, exhale: 8, hold2: 0),
        targetMinutes: 4,
        targetCycles: 8,
        isBuiltIn: true,
        category: PresetCategory.sleep,
        ambient: 'bowl',
        sortOrder: 5,
      ),
    ];

String nextPresetId() =>
    'preset_${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';
