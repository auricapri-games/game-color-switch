import 'package:flutter_test/flutter_test.dart';
import 'package:game_color_switch/config/level_params.dart';
import 'package:game_color_switch/core/game_rules.dart';
import 'package:game_color_switch/core/game_state.dart';
import 'package:game_color_switch/core/level_generator.dart';

void main() {
  group('ColorSwitchRules.applyMove', () {
    const rules = ColorSwitchRules();
    const generator = ColorSwitchLevelGenerator();

    test('matching color advances ring queue and increments score', () {
      final state = generator.generate(ColorSwitchParams.fromPhase(1));
      expect(state.ballColor, state.ringQueue.first);

      final after = rules.applyMove(state, SwitchMove.tap);
      expect(after.score, 1);
      expect(after.movesUsed, 1);
      expect(after.ringQueue.length, state.ringQueue.length - 1);
      expect(after.isOver, isFalse);
    });

    test('mismatch triggers immediate game over with isWon=false', () {
      final base = generator.generate(ColorSwitchParams.fromPhase(1));
      // Force a mismatch by recoloring the ball to anything not equal to head.
      final wrongColor = SwitchColor.values.firstWhere(
        (c) => c != base.ringQueue.first,
      );
      final mismatched = base.copyWith(ballColor: wrongColor);

      final after = rules.applyMove(mismatched, SwitchMove.tap);
      expect(after.isOver, isTrue);
      expect(after.isWon, isFalse);
      expect(after.score, 0);
    });

    test('clearing every ring marks the level won', () {
      var state = generator.generate(ColorSwitchParams.fromPhase(1));
      while (!state.isOver) {
        state = rules.applyMove(state, SwitchMove.tap);
      }
      expect(state.isWon, isTrue);
      expect(state.score, state.targetScore);
      expect(state.ringQueue, isEmpty);
    });

    test('isLegal is false once over', () {
      var state = generator.generate(ColorSwitchParams.fromPhase(1));
      while (!state.isOver) {
        state = rules.applyMove(state, SwitchMove.tap);
      }
      expect(rules.isLegal(state, SwitchMove.tap), isFalse);
      // Applying after over is a no-op.
      final same = rules.applyMove(state, SwitchMove.tap);
      expect(same, equals(state));
    });
  });
}
