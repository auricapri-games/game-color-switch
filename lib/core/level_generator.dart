import 'package:auricapri_engine/auricapri_engine.dart' as engine;

import '../config/level_params.dart';
import 'game_state.dart';

/// Builds a fresh [ColorSwitchState] from [ColorSwitchParams].
///
/// Solvability by construction: every ring palette contains the ball's
/// upcoming color at some index, so a perfect-timing player always has a
/// valid tap window.
class ColorSwitchLevelGenerator
    extends engine.LevelGenerator<ColorSwitchParams, ColorSwitchState> {
  const ColorSwitchLevelGenerator();

  @override
  ColorSwitchState generate(ColorSwitchParams params) {
    final rng = engine.SeededRandom(params.seed);
    final palette = SwitchColor.values.sublist(0, params.numColors);

    final ballStream = <SwitchColor>[
      for (var i = 0; i < params.numRings; i++)
        palette[rng.nextInt(palette.length)],
    ];

    final firstBall = ballStream.first;

    final ringPalettes = <List<SwitchColor>>[
      for (var i = 0; i < params.numRings; i++)
        _shuffledPaletteContaining(rng, palette, ballStream[i]),
    ];

    final futureStream = <SwitchColor>[
      for (var i = 1; i < ballStream.length; i++) ballStream[i],
    ];

    return ColorSwitchState(
      phase: params.phase,
      score: 0,
      movesUsed: 0,
      isOver: false,
      isWon: false,
      ballColor: firstBall,
      ringPalettes: ringPalettes,
      rotationIndex: 0,
      nextBallStream: futureStream,
      targetScore: params.numRings,
    );
  }

  List<SwitchColor> _shuffledPaletteContaining(
    engine.SeededRandom rng,
    List<SwitchColor> source,
    SwitchColor mustContain,
  ) {
    final out = List<SwitchColor>.of(source);
    for (var i = out.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final tmp = out[i];
      out[i] = out[j];
      out[j] = tmp;
    }
    if (!out.contains(mustContain)) {
      out[0] = mustContain;
    }
    return out;
  }

  @override
  bool validateSolvable(ColorSwitchState state) {
    if (state.ringPalettes.isEmpty) return true;
    if (!state.ringPalettes.first.contains(state.ballColor)) return false;
    for (var i = 1; i < state.ringPalettes.length; i++) {
      final expectedBall = state.nextBallStream[i - 1];
      if (!state.ringPalettes[i].contains(expectedBall)) return false;
    }
    return true;
  }
}
