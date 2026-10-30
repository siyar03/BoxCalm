import 'package:flutter/material.dart';

class LogoMark extends StatelessWidget {
  const LogoMark({
    super.key,
    this.size = 40,
    this.color,
    this.showDot = true,
    this.stroke = 3.2,
  });

  final double size;
  final Color? color;
  final bool showDot;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    final accent = color ??
        Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LogoPainter(
          color: accent,
          stroke: stroke,
          dotRadius: size * 0.075,
          showDot: showDot,
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  _LogoPainter({
    required this.color,
    required this.stroke,
    required this.dotRadius,
    required this.showDot,
  });

  final Color color;
  final double stroke;
  final double dotRadius;
  final bool showDot;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = stroke / 2 + 1;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(inset),
      Radius.circular(size.width * 0.24),
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          color,
          color.withValues(alpha: 0.55),
          color,
        ],
      ).createShader(rect);
    canvas.drawRRect(rrect, paint);

    if (showDot) {
      final dot = Offset(
        rect.left + inset + dotRadius * 0.2,
        rect.top + size.height * 0.62,
      );
      canvas.drawCircle(
        dot,
        dotRadius * 1.5,
        Paint()..color = color.withValues(alpha: 0.22),
      );
      canvas.drawCircle(dot, dotRadius, Paint()..color = color);
    }

    final inner = size.width * 0.075;
    canvas.drawCircle(
      rect.center,
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withValues(alpha: 0.22),
    );
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.stroke != stroke ||
      oldDelegate.showDot != showDot;
}
