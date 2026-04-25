import 'package:auricapri_engine/auricapri_engine.dart' as engine;

import '../config/level_params.dart';
import 'game_state.dart';

/// Player input. [tap] commits the currently visible ring color; [tick]
/// advances the ring rotation (driven by a UI timer). All transitions are
/// pure functions to keep the state testable from outside the widget tree.
enum SwitchMove { tap, tick }

class ColorSwitchRules
    extends engine.GameRules<ColorSwitchParams, ColorSwitchState, SwitchMove> {
  const ColorSwitchRules();

  @override
  bool isLegal(ColorSwitchState state, SwitchMove move) {
    if (state.isOver) return false;
    return state.ringPalettes.isNotEmpty;
  }

  @override
  ColorSwitchState applyMove(ColorSwitchState state, SwitchMove move) {
    if (!isLegal(state, move)) return state;
    return move == SwitchMove.tap ? _applyTap(state) : _applyTick(state);
  }

  ColorSwitchState _applyTick(ColorSwitchState state) {
    final head = state.ringPalettes.first;
    if (head.isEmpty) return state;
    return state.copyWith(
      rotationIndex: (state.rotationIndex + 1) % head.length,
    );
  }

  ColorSwitchState _applyTap(ColorSwitchState state) {
    final visible = state.visibleRingColor;
    final movesUsed = state.movesUsed + 1;

    if (visible == null || visible != state.ballColor) {
      return state.copyWith(
        movesUsed: movesUsed,
        isOver: true,
        isWon: false,
      );
    }

    final remaining = state.ringPalettes.sublist(1);
    final score = state.score + 1;
    final cleared = remaining.isEmpty || score >= state.targetScore;

    final streamIndex = score - 1;
    final nextBall = streamIndex < state.nextBallStream.length
        ? state.nextBallStream[streamIndex]
        : state.ballColor;

    return state.copyWith(
      score: score,
      movesUsed: movesUsed,
      ballColor: nextBall,
      ringPalettes: remaining,
      rotationIndex: 0,
      isOver: cleared,
      isWon: cleared,
    );
  }
}
