import 'package:flutter/material.dart';

import '../../services/breathing_engine.dart';

class PhaseReadout extends StatelessWidget {
  const PhaseReadout({
    super.key,
    required this.phase,
    required this.remaining,
    required this.accent,
    this.large = true,
  });

  final BreathPhase phase;
  final int remaining;
  final Color accent;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.18),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          ),
          child: Text(
            phase.label,
            key: ValueKey(phase),
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: large ? 22 : 15,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ),
        SizedBox(height: large ? 8 : 4),
        Text(
          phase == BreathPhase.preparing || phase == BreathPhase.complete
              ? '$remaining'
              : '$remaining',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: large ? 64 : 24,
            fontWeight: FontWeight.w300,
            height: 0.95,
            letterSpacing: -2,
            color: accent,
          ),
        ),
      ],
    );
  }
}
