import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class AuroraBackground extends StatelessWidget {
  const AuroraBackground({
    super.key,
    required this.child,
    this.withGlow = true,
  });

  final Widget child;
  final bool withGlow;

  @override
  Widget build(BuildContext context) {
    final box = BoxTheme.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: box.gradient,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (withGlow) ...[
            Positioned(
              top: -160,
              left: -140,
              child: _Glow(
                color: box.palette.accent.withValues(alpha: dark ? 0.13 : 0.10),
                size: 400,
              ),
            ),
            Positioned(
              bottom: -220,
              right: -170,
              child: _Glow(
                color:
                    box.palette.secondary.withValues(alpha: dark ? 0.12 : 0.09),
                size: 480,
              ),
            ),
            if (!dark)
              Positioned(
                top: 120,
                right: -180,
                child: _Glow(
                  color: box.palette.accent.withValues(alpha: 0.05),
                  size: 380,
                ),
              ),
          ],
          child,
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
