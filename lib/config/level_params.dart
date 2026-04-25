import 'package:auricapri_engine/auricapri_engine.dart' as engine;
import 'package:meta/meta.dart';

@immutable
class ColorSwitchParams extends engine.LevelParams {
  const ColorSwitchParams({
    required super.phase,
    required super.seed,
    required this.numRings,
    required this.numColors,
    required this.spinSpeedHz,
  });

  /// How many rings the player must pass to clear the phase.
  final int numRings;

  /// How many distinct colors are in the active palette this phase.
  /// Always between 2 (warm-up) and 4 (full Color Switch).
  final int numColors;

  /// Visual rotation speed of each ring (cycles per second). Higher =
  /// harder for the human player. Pure UI difficulty knob.
  final double spinSpeedHz;

  factory ColorSwitchParams.fromPhase(int phase) {
    final rings = 5 + (phase ~/ 2);
    final colors = phase < 3 ? 2 : (phase < 6 ? 3 : 4);
    final speed = 0.4 + (phase * 0.08);
    return ColorSwitchParams(
      phase: phase,
      seed: phase,
      numRings: rings.clamp(5, 30),
      numColors: colors,
      spinSpeedHz: speed.clamp(0.4, 1.6),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ColorSwitchParams &&
          other.phase == phase &&
          other.seed == seed &&
          other.numRings == numRings &&
          other.numColors == numColors &&
          other.spinSpeedHz == spinSpeedHz);

  @override
  int get hashCode =>
      Object.hash(phase, seed, numRings, numColors, spinSpeedHz);
}
