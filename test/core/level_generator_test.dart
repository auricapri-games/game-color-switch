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
      final colors1 = p1.ringQueue.toSet();
      final colors9 = p9.ringQueue.toSet();
      expect(colors1.length, lessThanOrEqualTo(2));
      expect(colors9.length, greaterThanOrEqualTo(3));
    });

    test('targetScore equals number of rings', () {
      final s = generator.generate(ColorSwitchParams.fromPhase(4));
      expect(s.targetScore, s.ringQueue.length);
    });

    test('state equality + hashCode work', () {
      final s = generator.generate(ColorSwitchParams.fromPhase(2));
      final clone = s.copyWith();
      expect(s, equals(clone));
      expect(s.hashCode, clone.hashCode);
      expect(s.isLost, isFalse);
    });

    test('SwitchColor enum has 4 entries', () {
      expect(SwitchColor.values.length, 4);
    });
  });
}
