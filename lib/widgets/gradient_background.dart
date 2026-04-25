import 'package:flutter/material.dart';

import '../ds/app_colors.dart';

/// Soft three-stop gradient + radial glow vignette — the "candy" backdrop
/// every screen rides on top of.
class GradientBackground extends StatelessWidget {
  const GradientBackground({
    required this.child,
    super.key,
    this.glowColor,
  });

  final Widget child;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final glow = glowColor ?? AppColors.secondary;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background,
            AppColors.backgroundAlt,
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.4),
                radius: 0.9,
                colors: [
                  glow.withValues(alpha: 0.35),
                  glow.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
