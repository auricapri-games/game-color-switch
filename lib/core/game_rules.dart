import 'package:auricapri_engine/auricapri_engine.dart' as engine;

import '../config/level_params.dart';
import 'game_state.dart';

/// Player input: a single tap that asks the ball to attempt the current
/// ring. There is no other input — Color Switch is one-button gameplay.
enum SwitchMove { tap }

class ColorSwitchRules
    extends engine.GameRules<ColorSwitchParams, ColorSwitchState, SwitchMove> {
  const ColorSwitchRules();

  @override
  bool isLegal(ColorSwitchState state, SwitchMove move) =>
      !state.isOver && state.ringQueue.isNotEmpty;

  @override
  ColorSwitchState applyMove(ColorSwitchState state, SwitchMove move) {
    if (!isLegal(state, move)) return state;

    final ring = state.ringQueue.first;
    final matched = ring == state.ballColor;
    final movesUsed = state.movesUsed + 1;

    if (!matched) {
      return state.copyWith(
        movesUsed: movesUsed,
        isOver: true,
        isWon: false,
      );
    }

    final newQueue = state.ringQueue.sublist(1);
    final score = state.score + 1;
    final reachedTarget = score >= state.targetScore;

    // Pull next ball color deterministically from the pre-shuffled stream.
    final streamIndex = score - 1;
    final nextBall = streamIndex < state.nextBallStream.length
        ? state.nextBallStream[streamIndex]
        : state.ballColor;

    return state.copyWith(
      score: score,
      movesUsed: movesUsed,
      ballColor: nextBall,
      ringQueue: newQueue,
      isOver: reachedTarget || newQueue.isEmpty,
      isWon: reachedTarget || newQueue.isEmpty,
    );
  }
}
