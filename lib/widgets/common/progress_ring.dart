import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    required this.size,
    required this.child,
    this.stroke = 8,
    this.trackColor,
    this.gradient,
  });

  final double progress;
  final double size;
  final Widget child;
  final double stroke;
  final Color? trackColor;
  final List<Color>? gradient;

  @override
  Widget build(BuildContext context) {
    final box = BoxTheme.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress.clamp(0, 1),
          stroke: stroke,
          trackColor: trackColor ??
              Colors.white.withValues(alpha:
                  Theme.of(context).brightness == Brightness.dark ? 0.10 : 0.35),
          gradient: gradient ?? [box.palette.accent, box.palette.secondary],
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.stroke,
    required this.trackColor,
    required this.gradient,
  });

  final double progress;
  final double stroke;
  final Color trackColor;
  final List<Color> gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.width - stroke) / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [...gradient, gradient.first],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress ||
      old.stroke != stroke ||
      old.gradient != gradient ||
      old.trackColor != trackColor;
}

class MiniPatternBar extends StatelessWidget {
  const MiniPatternBar({
    super.key,
    required this.segments,
    this.height = 6,
    this.colors,
    this.radius = 99,
  });

  final List<double> segments;
  final double height;
  final List<Color>? colors;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final box = BoxTheme.of(context);
    final palette = colors ??
        [
          box.palette.accent,
          box.palette.accent.withValues(alpha: 0.55),
          box.palette.secondary,
          box.palette.secondary.withValues(alpha: 0.55),
        ];
    final total = segments.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            for (var i = 0; i < segments.length; i++)
              if (segments[i] > 0)
                Expanded(
                  flex: (segments[i] * 1000).round().clamp(1, 100000),
                  child: Container(
                    margin: EdgeInsets.only(right: i == segments.length - 1 ? 0 : 2),
                    color: palette[i % palette.length],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
