import 'package:auricapri_engine/auricapri_engine.dart' as engine;

import '../config/level_params.dart';
import 'game_state.dart';

/// Builds a fresh [ColorSwitchState] from [ColorSwitchParams] in a way that
/// is *guaranteed solvable by construction*: the ring queue is generated
/// first, then the ball color stream is set to the same sequence so that
/// matching colors at every step is always possible.
class ColorSwitchLevelGenerator
    extends engine.LevelGenerator<ColorSwitchParams, ColorSwitchState> {
  const ColorSwitchLevelGenerator();

  @override
  ColorSwitchState generate(ColorSwitchParams params) {
    final rng = engine.SeededRandom(params.seed);
    final palette = SwitchColor.values.sublist(0, params.numColors);

    final rings = <SwitchColor>[
      for (var i = 0; i < params.numRings; i++)
        palette[rng.nextInt(palette.length)],
    ];

    // The first ring is what the ball starts on; ball color = first ring.
    final firstBall = rings.first;
    // Stream: the color the ball turns into AFTER each successful pass.
    // To stay solvable by construction, the next ball color equals the
    // next ring color in the queue (player can always succeed by tapping
    // at the right moment in the production game; for our turn-based
    // logic this means perfect play scores `numRings` points).
    final stream = <SwitchColor>[
      for (var i = 1; i < rings.length; i++) rings[i],
    ];

    return ColorSwitchState(
      phase: params.phase,
      score: 0,
      movesUsed: 0,
      isOver: false,
      isWon: false,
      ballColor: firstBall,
      ringQueue: rings,
      nextBallStream: stream,
      targetScore: params.numRings,
    );
  }

  @override
  bool validateSolvable(ColorSwitchState state) {
    if (state.ringQueue.length > state.nextBallStream.length + 1) return false;
    if (state.ringQueue.isEmpty) return true;
    if (state.ballColor != state.ringQueue.first) return false;
    for (var i = 1; i < state.ringQueue.length; i++) {
      if (state.nextBallStream[i - 1] != state.ringQueue[i]) return false;
    }
    return true;
  }
}
