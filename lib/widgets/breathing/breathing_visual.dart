import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/visual_style.dart';
import '../../core/theme/app_palette.dart';
import '../../services/breathing_engine.dart';

class BreathingVisual extends StatelessWidget {
  const BreathingVisual({
    super.key,
    required this.phase,
    required this.progress,
    required this.style,
    required this.palette,
    this.reduceMotion = false,
    this.cycle = 0,
  });

  final BreathPhase phase;
  final double progress;
  final VisualStyle style;
  final AppPalette palette;
  final bool reduceMotion;
  final int cycle;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _BreathingPainter(
          phase: phase,
          progress: progress.clamp(0.0, 1.0),
          style: style,
          palette: palette,
          reduceMotion: reduceMotion,
          cycle: cycle,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _BreathingPainter extends CustomPainter {
  _BreathingPainter({
    required this.phase,
    required this.progress,
    required this.style,
    required this.palette,
    required this.reduceMotion,
    required this.cycle,
  });

  final BreathPhase phase;
  final double progress;
  final VisualStyle style;
  final AppPalette palette;
  final bool reduceMotion;
  final int cycle;

  double _ease(double t) => 0.5 - math.cos(math.pi * t) / 2;

  double get _breath {
    if (reduceMotion) return 0.78;
    switch (phase) {
      case BreathPhase.inhale:
        return 0.46 + 0.54 * _ease(progress);
      case BreathPhase.hold1:
        return 1.0;
      case BreathPhase.exhale:
        return 1.0 - 0.54 * _ease(progress);
      case BreathPhase.hold2:
        return 0.46;
      case BreathPhase.preparing:
        return 0.52 + 0.04 * math.sin(progress * math.pi * 2);
      case BreathPhase.complete:
        return 0.72;
      case BreathPhase.idle:
        return 0.6;
    }
  }

  Color get _phaseColor {
    switch (phase) {
      case BreathPhase.inhale:
        return palette.accent;
      case BreathPhase.hold1:
      case BreathPhase.hold2:
        return Color.lerp(palette.accent, palette.secondary, 0.45)!;
      case BreathPhase.exhale:
        return palette.secondary;
      case BreathPhase.complete:
        return palette.accent;
      case BreathPhase.preparing:
        return palette.accent;
      case BreathPhase.idle:
        return palette.accent;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final shortest = math.min(size.width, size.height);
    final color = _phaseColor;
    _drawAmbientGlow(canvas, center, shortest, color);
    switch (style) {
      case VisualStyle.box:
        _drawBox(canvas, size, center, shortest, color);
        break;
      case VisualStyle.circle:
        _drawCircle(canvas, center, shortest, color);
        break;
      case VisualStyle.minimal:
        _drawMinimal(canvas, center, shortest, color);
        break;
      case VisualStyle.lotus:
        _drawLotus(canvas, center, shortest, color);
        break;
    }
  }

  void _drawAmbientGlow(Canvas canvas, Offset center, double shortest, Color color) {
    final radius = shortest * (0.23 + _breath * 0.13);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.15),
          color.withValues(alpha: 0.05),
          color.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.5));
    canvas.drawCircle(center, radius * 1.5, paint);
  }

  void _drawBox(
    Canvas canvas,
    Size size,
    Offset center,
    double shortest,
    Color color,
  ) {
    final inset = shortest * 0.12;
    final rect = Rect.fromCircle(center: center, radius: (shortest / 2) - inset);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(shortest * 0.09));
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Colors.white.withValues(alpha: 0.10);
    canvas.drawRRect(rrect, track);

    final path = Path()..addRRect(rrect);
    final metric = path.computeMetrics().first;
    final side = phase.isBreath ? phase.sideIndex : 0;
    final p = reduceMotion ? 0.5 : progress;
    final total = metric.length;
    final start = (side / 4) * total;
    final end = ((side + p) / 4) * total;

    final trailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [
          color.withValues(alpha: 0.15),
          color.withValues(alpha: 0.75),
          color,
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(rect);
    if (end > start + 0.1) {
      canvas.drawPath(metric.extractPath(start, end), trailPaint);
    }

    final tangent = metric.getTangentForOffset(
      end.clamp(0.0, total - 0.01),
    );
    if (tangent != null) {
      canvas.drawCircle(
        tangent.position,
        shortest * 0.075,
        Paint()
          ..color = color.withValues(alpha: 0.20)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
      canvas.drawCircle(
        tangent.position,
        shortest * 0.018,
        Paint()..color = color,
      );
      canvas.drawCircle(
        tangent.position,
        shortest * 0.010,
        Paint()..color = Colors.white.withValues(alpha: 0.9),
      );
    }

    _drawInnerOrb(canvas, center, shortest, color);
  }

  void _drawCircle(Canvas canvas, Offset center, double shortest, Color color) {
    final base = shortest * 0.33;
    final radius = base * (0.55 + _breath * 0.45);
    for (var i = 3; i >= 1; i--) {
      final r = radius * (1 + i * 0.10);
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = color.withValues(alpha: 0.06 + (3 - i) * 0.025),
      );
    }
    final shader = RadialGradient(
      colors: [
        color.withValues(alpha: 0.24),
        color.withValues(alpha: 0.10),
        color.withValues(alpha: 0.02),
      ],
    ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, Paint()..shader = shader);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = color.withValues(alpha: 0.65),
    );

    final outer = shortest * 0.42;
    canvas.drawCircle(
      center,
      outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.09),
    );
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..color = color;
    if (phase.isBreath) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outer),
        -math.pi / 2,
        math.pi * 2 * (reduceMotion ? 0.4 : progress),
        false,
        arcPaint,
      );
    }
  }

  void _drawMinimal(Canvas canvas, Offset center, double shortest, Color color) {
    final radius = shortest * 0.28;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.08),
    );
    canvas.drawCircle(
      center,
      radius * (0.72 + _breath * 0.12),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = color.withValues(alpha: 0.55),
    );
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = color;
    if (phase.isBreath) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi * 2 * (reduceMotion ? 0.4 : progress),
        false,
        arcPaint,
      );
    }
  }

  void _drawLotus(Canvas canvas, Offset center, double shortest, Color color) {
    final petalLength = shortest * 0.26 * (0.72 + _breath * 0.28);
    final petalWidth = shortest * 0.085 * (0.7 + _breath * 0.3);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate((cycle % 8) * math.pi / 18);
    for (var i = 0; i < 8; i++) {
      canvas.save();
      canvas.rotate(i * math.pi / 4);
      final path = Path()
        ..moveTo(0, -shortest * 0.045)
        ..cubicTo(
          petalWidth,
          -petalLength * 0.45,
          petalWidth * 0.7,
          -petalLength,
          0,
          -petalLength,
        )
        ..cubicTo(
          -petalWidth * 0.7,
          -petalLength,
          -petalWidth,
          -petalLength * 0.45,
          0,
          -shortest * 0.045,
        );
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            color.withValues(alpha: 0.05),
            color.withValues(alpha: 0.18 + (i % 2) * 0.10),
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: petalLength))
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9
          ..color = color.withValues(alpha: 0.35),
      );
      canvas.restore();
    }
    canvas.restore();
    _drawInnerOrb(canvas, center, shortest, color, sizeFactor: 0.22);
  }

  void _drawInnerOrb(
    Canvas canvas,
    Offset center,
    double shortest,
    Color color, {
    double sizeFactor = 0.18,
  }) {
    final radius = shortest * sizeFactor * (0.55 + _breath * 0.45);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.22),
            color.withValues(alpha: 0.04),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = color.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(covariant _BreathingPainter old) =>
      old.phase != phase ||
      old.progress != progress ||
      old.style != style ||
      old.reduceMotion != reduceMotion ||
      old.cycle != cycle ||
      old.palette != palette;
}
