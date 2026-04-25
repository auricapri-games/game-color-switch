import 'package:flutter_test/flutter_test.dart';
import 'package:game_color_switch/config/level_params.dart';
import 'package:game_color_switch/core/game_rules.dart';
import 'package:game_color_switch/core/game_state.dart';
import 'package:game_color_switch/core/level_generator.dart';

void main() {
  group('ColorSwitchRules.applyMove', () {
    const rules = ColorSwitchRules();
    const generator = ColorSwitchLevelGenerator();

    ColorSwitchState align(ColorSwitchState s) {
      var c = s;
      for (var i = 0; i < 16; i++) {
        if (c.visibleRingColor == c.ballColor) return c;
        c = rules.applyMove(c, SwitchMove.tick);
      }
      return c;
    }

    test('matching color advances ring queue and increments score', () {
      final state = align(generator.generate(ColorSwitchParams.fromPhase(1)));
      final after = rules.applyMove(state, SwitchMove.tap);
      expect(after.score, 1);
      expect(after.movesUsed, 1);
      expect(after.ringsRemaining, state.ringsRemaining - 1);
      expect(after.isOver, isFalse);
    });

    test('mismatch triggers immediate game over with isWon=false', () {
      final base = generator.generate(ColorSwitchParams.fromPhase(1));
      final wrongColor = SwitchColor.values.firstWhere(
        (c) =>
            c != base.visibleRingColor &&
            base.ringPalettes.first.contains(c),
        orElse: () => SwitchColor.values.firstWhere(
          (c) => c != base.visibleRingColor,
        ),
      );
      // Rotate the ring until visible != ballColor and visible != wrongColor.
      var s = base.copyWith(ballColor: wrongColor);
      while (s.visibleRingColor == s.ballColor) {
        s = rules.applyMove(s, SwitchMove.tick);
      }
      final after = rules.applyMove(s, SwitchMove.tap);
      expect(after.isOver, isTrue);
      expect(after.isWon, isFalse);
      expect(after.score, 0);
    });

    test('clearing every ring marks the level won', () {
      var state = generator.generate(ColorSwitchParams.fromPhase(1));
      var safety = 0;
      while (!state.isOver && safety < 200) {
        if (state.visibleRingColor == state.ballColor) {
          state = rules.applyMove(state, SwitchMove.tap);
        } else {
          state = rules.applyMove(state, SwitchMove.tick);
        }
        safety++;
      }
      expect(state.isWon, isTrue);
      expect(state.score, state.targetScore);
      expect(state.ringPalettes, isEmpty);
    });

    test('isLegal is false once over', () {
      var state = generator.generate(ColorSwitchParams.fromPhase(1));
      var safety = 0;
      while (!state.isOver && safety < 200) {
        state = state.visibleRingColor == state.ballColor
            ? rules.applyMove(state, SwitchMove.tap)
            : rules.applyMove(state, SwitchMove.tick);
        safety++;
      }
      expect(rules.isLegal(state, SwitchMove.tap), isFalse);
      final same = rules.applyMove(state, SwitchMove.tap);
      expect(same, equals(state));
    });

    test('tick rotates the visible color', () {
      final initial = generator.generate(ColorSwitchParams.fromPhase(1));
      final ticked = rules.applyMove(initial, SwitchMove.tick);
      expect(ticked.rotationIndex, initial.rotationIndex + 1);
    });
  });
}
