import 'package:flutter/material.dart';

import '../../core/constants/visual_style.dart';
import '../../core/theme/app_palette.dart';
import '../../models/breath_pattern.dart';
import '../../services/breathing_engine.dart';
import 'breathing_visual.dart';

class PatternPreview extends StatefulWidget {
  const PatternPreview({
    super.key,
    required this.pattern,
    required this.style,
    required this.palette,
    this.reduceMotion = false,
    this.animate = true,
  });

  final BreathPattern pattern;
  final VisualStyle style;
  final AppPalette palette;
  final bool reduceMotion;
  final bool animate;

  @override
  State<PatternPreview> createState() => _PatternPreviewState();
}

class _PatternPreviewState extends State<PatternPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.pattern.cycleSeconds.clamp(4, 30)),
    );
    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant PatternPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pattern.cycleSeconds != widget.pattern.cycleSeconds) {
      _controller.duration =
          Duration(seconds: widget.pattern.cycleSeconds.clamp(4, 30));
      if (widget.animate) _controller.repeat();
    }
    if (oldWidget.animate != widget.animate) {
      if (widget.animate) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final segments = widget.pattern.segments;
        var acc = 0.0;
        var index = 0;
        var local = 0.0;
        for (var i = 0; i < segments.length; i++) {
          if (t <= acc + segments[i] || i == segments.length - 1) {
            index = i;
            local = ((t - acc) / (segments[i] == 0 ? 1 : segments[i]))
                .clamp(0.0, 1.0);
            break;
          }
          acc += segments[i];
        }
        final phases = [
          BreathPhase.inhale,
          BreathPhase.hold1,
          BreathPhase.exhale,
          BreathPhase.hold2,
        ];
        return BreathingVisual(
          phase: phases[index],
          progress: local,
          style: widget.style,
          palette: widget.palette,
          reduceMotion: widget.reduceMotion,
          cycle: (t * 4).floor(),
        );
      },
    );
  }
}
