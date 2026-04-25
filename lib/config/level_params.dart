import 'package:auricapri_engine/auricapri_engine.dart' as engine;
import 'package:meta/meta.dart';

@immutable
class ColorSwitchParams extends engine.LevelParams {
  const ColorSwitchParams({
    required super.phase,
    required super.seed,
    required this.numRings,
    required this.numColors,
    required this.tickHz,
  });

  /// How many rings the player must pass to clear the phase.
  final int numRings;

  /// How many distinct colors are in the active palette this phase.
  /// Always between 2 (warm-up) and 4 (full Color Switch).
  final int numColors;

  /// Visual rotation speed (cycles per second). Higher = harder. Used by
  /// the gameplay timer to derive the tick interval.
  final double tickHz;

  factory ColorSwitchParams.fromPhase(int phase) {
    final rings = 5 + (phase ~/ 2);
    final colors = phase < 3 ? 2 : (phase < 6 ? 3 : 4);
    final speed = 1.6 + (phase * 0.18);
    return ColorSwitchParams(
      phase: phase,
      seed: phase,
      numRings: rings.clamp(5, 30),
      numColors: colors,
      tickHz: speed.clamp(1.4, 4.0),
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
          other.tickHz == tickHz);

  @override
  int get hashCode =>
      Object.hash(phase, seed, numRings, numColors, tickHz);
}
