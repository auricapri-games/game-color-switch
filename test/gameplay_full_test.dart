// Drives the rules engine through a full successful run, exercising
// timing-aligned taps and the deterministic level generator.

import 'package:flutter_test/flutter_test.dart';
import 'package:game_color_switch/config/level_params.dart';
import 'package:game_color_switch/core/game_rules.dart';
import 'package:game_color_switch/core/level_generator.dart';

void main() {
  test('perfect-timing run wins phase 1', () {
    const rules = ColorSwitchRules();
    const generator = ColorSwitchLevelGenerator();
    var state = generator.generate(ColorSwitchParams.fromPhase(1));

    var safety = 0;
    while (!state.isOver && safety < 500) {
      if (state.visibleRingColor == state.ballColor) {
        state = rules.applyMove(state, SwitchMove.tap);
      } else {
        state = rules.applyMove(state, SwitchMove.tick);
      }
      safety++;
    }

    expect(state.isWon, isTrue, reason: 'safe-tap walker should win');
    expect(state.score, state.targetScore);
  });

  test('mistimed taps end the run before reaching targetScore', () {
    const rules = ColorSwitchRules();
    const generator = ColorSwitchLevelGenerator();
    var state = generator.generate(ColorSwitchParams.fromPhase(1));

    // Force mismatch: rotate until visible != ball, then tap.
    while (state.visibleRingColor == state.ballColor) {
      state = rules.applyMove(state, SwitchMove.tick);
    }
    final after = rules.applyMove(state, SwitchMove.tap);
    expect(after.isOver, isTrue);
    expect(after.isWon, isFalse);
    expect(after.score, lessThan(after.targetScore));
  });
}
