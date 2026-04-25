import 'package:flutter_test/flutter_test.dart';
import 'package:game_color_switch/config/level_params.dart';

void main() {
  group('ColorSwitchParams.fromPhase', () {
    test('phase 1 starts with 2 colors', () {
      final p = ColorSwitchParams.fromPhase(1);
      expect(p.numColors, 2);
      expect(p.numRings, 5);
      expect(p.tickHz, greaterThan(1.4));
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

    test('tickHz clamps at 4.0', () {
      final big = ColorSwitchParams.fromPhase(200);
      expect(big.tickHz, 4.0);
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

    test('inequality across phases', () {
      final a = ColorSwitchParams.fromPhase(1);
      final b = ColorSwitchParams.fromPhase(2);
      expect(a == b, isFalse);
    });
  });
}
