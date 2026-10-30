import 'package:flutter/material.dart';

import '../widgets/common/aurora_background.dart';
import '../widgets/common/glass_card.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learn & Technique')),
      body: AuroraBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: const [
            _Article(
              title: 'The Science of Box Breathing',
              body:
                  'Box breathing (or tactical breathing) is a powerful stress-relieving technique. '
                  'By equalizing the four phases — inhale, hold, exhale, hold — you stimulate the parasympathetic nervous system, '
                  'lowering heart rate and cortisol levels within seconds.',
            ),
            _Article(
              title: 'Why holds matter',
              body:
                  'Breath retention builds carbon dioxide tolerance gently. '
                  'When CO2 levels rise slightly, the body releases oxygen more efficiently to tissues and the brain, '
                  'clearing mental fog and sharpening calm focus.',
            ),
            _Article(
              title: 'Tips for eyes-closed practice',
              body:
                  'Let the haptic pulses and soft chimes guide your pacing. '
                  'If your mind wanders, gently return attention to the physical sensation of air moving in and out.',
            ),
          ],
        ),
      ),
    );
  }
}

class _Article extends StatelessWidget {
  const _Article({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Text(body, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
