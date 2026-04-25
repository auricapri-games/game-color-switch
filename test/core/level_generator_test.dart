import 'package:flutter_test/flutter_test.dart';
import 'package:game_color_switch/config/level_params.dart';
import 'package:game_color_switch/core/game_state.dart';
import 'package:game_color_switch/core/level_generator.dart';

void main() {
  group('ColorSwitchLevelGenerator', () {
    const generator = ColorSwitchLevelGenerator();

    test('produces solvable levels for 1000 seeds', () {
      for (var phase = 1; phase <= 1000; phase++) {
        final params = ColorSwitchParams.fromPhase(phase);
        final state = generator.generate(params);
        expect(
          generator.validateSolvable(state),
          isTrue,
          reason: 'phase $phase failed solvability',
        );
      }
    });

    test('same phase produces deterministic state', () {
      final a = generator.generate(ColorSwitchParams.fromPhase(7));
      final b = generator.generate(ColorSwitchParams.fromPhase(7));
      expect(a, equals(b));
    });

    test('palette grows across early phases', () {
      final p1 = generator.generate(ColorSwitchParams.fromPhase(1));
      final p9 = generator.generate(ColorSwitchParams.fromPhase(9));
      expect(p1.ringPalettes.first.length, lessThanOrEqualTo(2));
      expect(p9.ringPalettes.first.length, 4);
    });

    test('targetScore equals number of rings', () {
      final s = generator.generate(ColorSwitchParams.fromPhase(4));
      expect(s.targetScore, s.ringPalettes.length);
    });

    test('every ring palette contains the ball color it must match', () {
      for (var phase = 1; phase <= 50; phase++) {
        final s =
            generator.generate(ColorSwitchParams.fromPhase(phase));
        expect(s.ringPalettes.first.contains(s.ballColor), isTrue);
        for (var i = 1; i < s.ringPalettes.length; i++) {
          final expectedBall = s.nextBallStream[i - 1];
          expect(
            s.ringPalettes[i].contains(expectedBall),
            isTrue,
            reason: 'phase $phase ring $i must contain $expectedBall',
          );
        }
      }
    });

    test('state equality + hashCode + isLost', () {
      final s = generator.generate(ColorSwitchParams.fromPhase(2));
      final clone = s.copyWith();
      expect(s, equals(clone));
      expect(s.hashCode, clone.hashCode);
      expect(s.isLost, isFalse);
    });

    test('SwitchColor enum has 4 entries', () {
      expect(SwitchColor.values.length, 4);
    });

    test('visibleRingColor returns null when palettes empty', () {
      final s =
          generator.generate(ColorSwitchParams.fromPhase(1)).copyWith(
        ringPalettes: <List<SwitchColor>>[],
      );
      expect(s.visibleRingColor, isNull);
    });
  });
}
