import 'package:flutter/material.dart';

import '../core/game_state.dart';
import '../ds/app_colors.dart';

const Map<SwitchColor, Color> _ballTint = {
  SwitchColor.red: AppColors.primary,
  SwitchColor.blue: AppColors.accent,
  SwitchColor.yellow: AppColors.secondary,
  SwitchColor.green: Color(0xFF88E0A1),
};

/// Tinted ball sprite. The base sprite is white-pearl; we lay a colour
/// halo behind it and a colour-multiplied disc on top for a candy look.
class BallSprite extends StatelessWidget {
  const BallSprite({
    required this.color,
    required this.size,
    super.key,
  });

  final SwitchColor color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tint = _ballTint[color]!;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 1.25,
            height: size * 1.25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: tint.withValues(alpha: 0.5),
                  blurRadius: size * 0.5,
                ),
              ],
            ),
          ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.4),
                colors: [
                  Color.lerp(Colors.white, tint, 0.15)!,
                  tint,
                  Color.lerp(tint, Colors.black, 0.25)!,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
            child: Image.asset(
              'assets/sprites/ball.png',
              color: tint,
              colorBlendMode: BlendMode.modulate,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
