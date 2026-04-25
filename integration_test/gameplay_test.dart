// Real gameplay integration test — boots the full app, navigates from
// splash → home → gameplay, performs taps, and verifies that visible state
// changes (ring rotates and either the score advances or game-over is
// reached). Random tapping is also asserted to NOT silently always win —
// either score must remain 0 or game must be over.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:game_color_switch/config/level_params.dart';
import 'package:game_color_switch/core/game_rules.dart';
import 'package:game_color_switch/core/game_state.dart';
import 'package:game_color_switch/core/level_generator.dart';
import 'package:game_color_switch/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  Future<void> _bootToHome(WidgetTester tester) async {
    await tester.pumpWidget(const GameColorSwitchApp());
    // Splash auto-navigates after ~1.6s; pump several frames so the
    // pushReplacement + page transition fully completes.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }
  }

  testWidgets('splash → home shows PLAY and mascot', (tester) async {
    await _bootToHome(tester);
    expect(find.text('PLAY'), findsOneWidget);
    // Title may render twice during route transition; require at least one.
    expect(find.text('Color Switch'), findsWidgets);
  });

  testWidgets('home → gameplay → tutorial fades on first input',
      (tester) async {
    await _bootToHome(tester);

    await tester.tap(find.text('PLAY'));
    // Let the gameplay route push + settle.
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    // tutorial visible at first
    expect(
      find.text('Tap when the ring color matches the ball'),
      findsOneWidget,
    );

    // Score card visible from the start.
    expect(find.byKey(const ValueKey<String>('score-card')), findsOneWidget);

    // Tap the gameplay area once.
    final scaffold = find.byType(Scaffold).last;
    await tester.tap(scaffold);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 350));

    // tutorial now invisible (opacity 0)
    final opacityFinder = find.byWidgetPredicate(
      (w) =>
          w is AnimatedOpacity &&
          w.opacity == 0.0 &&
          w.duration.inMilliseconds == 250,
    );
    expect(opacityFinder, findsOneWidget);
  });

  test('rules engine: 5 random taps cannot win — must lose or stay at 0', () {
    // BUG CHECK #1: tapping randomly without aligning colors must NOT
    // always succeed. Either game over (mismatch) or score == 0 (no
    // progress because alignment never happened).
    const rules = ColorSwitchRules();
    const generator = ColorSwitchLevelGenerator();
    var state = generator.generate(ColorSwitchParams.fromPhase(1));
    for (var i = 0; i < 5; i++) {
      state = rules.applyMove(state, SwitchMove.tap);
      if (state.isOver) break;
    }
    expect(
      state.isOver || state.score == 0,
      isTrue,
      reason: 'random taps must not silently win',
    );
  });

  test('rules engine: ticks rotate the visible color over time', () {
    // BUG CHECK #5 / #6: the rotation must actually progress when ticks
    // are applied, otherwise gameplay is static.
    const rules = ColorSwitchRules();
    const generator = ColorSwitchLevelGenerator();
    var state = generator.generate(ColorSwitchParams.fromPhase(2));
    final seen = <SwitchColor?>{state.visibleRingColor};
    for (var i = 0; i < 8; i++) {
      state = rules.applyMove(state, SwitchMove.tick);
      seen.add(state.visibleRingColor);
    }
    expect(seen.length, greaterThan(1),
        reason: 'visibleRingColor must change with ticks');
  });
}
