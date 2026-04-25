import 'package:flutter_test/flutter_test.dart';
import 'package:game_color_switch/config/level_params.dart';

void main() {
  group('ColorSwitchParams.fromPhase', () {
    test('phase 1 starts with 2 colors', () {
      final p = ColorSwitchParams.fromPhase(1);
      expect(p.numColors, 2);
      expect(p.numRings, 5);
      expect(p.spinSpeedHz, closeTo(0.48, 0.001));
    });

    test('numColors caps at 4', () {
      for (var phase = 6; phase < 50; phase++) {
        expect(ColorSwitchParams.fromPhase(phase).numColors, 4);
      }
    });

    test('numRings clamps at 30', () {
      final big = ColorSwitchParams.fromPhase(200);
      expect(big.numRings, 30);
    });

    test('spinSpeedHz clamps at 1.6', () {
      final big = ColorSwitchParams.fromPhase(200);
      expect(big.spinSpeedHz, 1.6);
    });

    test('equality + hashCode', () {
      final a = ColorSwitchParams.fromPhase(3);
      final b = ColorSwitchParams.fromPhase(3);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('phase 0 still produces valid bounded params', () {
      final p = ColorSwitchParams.fromPhase(0);
      expect(p.numRings, 5);
      expect(p.numColors, 2);
    });
  });
}
