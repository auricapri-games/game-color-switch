import 'package:flutter/material.dart';

import '../core/game_state.dart';

const Map<SwitchColor, String> _ringAsset = {
  SwitchColor.red: 'assets/sprites/ring_red.png',
  SwitchColor.blue: 'assets/sprites/ring_blue.png',
  SwitchColor.green: 'assets/sprites/ring_green.png',
  SwitchColor.yellow: 'assets/sprites/ring_yellow.png',
};

/// Spinning ring sprite — overlays a coloured halo so the active sector
/// reads correctly even before the rotation animation comes around.
class SpinningRing extends StatelessWidget {
  const SpinningRing({
    required this.color,
    required this.spinTurns,
    required this.size,
    super.key,
  });

  final SwitchColor color;
  final double spinTurns;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: RotationTransition(
        turns: AlwaysStoppedAnimation<double>(spinTurns),
        child: Image.asset(_ringAsset[color]!, fit: BoxFit.contain),
      ),
    );
  }
}
