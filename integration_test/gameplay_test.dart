import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:game_color_switch/config/level_params.dart';
import 'package:game_color_switch/core/game_rules.dart';
import 'package:game_color_switch/core/game_state.dart';
import 'package:game_color_switch/core/level_generator.dart';
import 'package:game_color_switch/main.dart';
import 'package:game_color_switch/screens/gameplay_screen.dart';

const _rules = ColorSwitchRules();
const _generator = ColorSwitchLevelGenerator();

/// Drives the rules engine until the visible color matches the ball,
/// then returns the post-tap state. If the visible color is already a
/// match, taps immediately. Used to test that a winning tap really
/// awards a point.
ColorSwitchState _tapAtNextMatch(ColorSwitchState state) {
  var s = state;
  for (var i = 0; i < 16 && !s.isOver; i++) {
    if (s.visibleRingColor == s.ballColor) {
      return _rules.applyMove(s, SwitchMove.tap);
    }
    s = _rules.applyMove(s, SwitchMove.tick);
  }
  return s;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'auricapri_consent_status': 'granted',
    });
  });

  testWidgets('home → tap PLAY → gameplay screen mounts', (tester) async {
    await tester.pumpWidget(const GameColorSwitchApp());
    // Splash auto-navigates after ~1.6s. Give time for fonts + nav.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('PLAY'), findsOneWidget);

    await tester.tap(find.text('PLAY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Score card with starting score must be visible on gameplay screen.
    expect(find.byKey(const ValueKey<String>('score-card')), findsOneWidget);
    expect(find.textContaining('SCORE'), findsOneWidget);
  });

  testWidgets(
    'pure rules: tap at matching moment scores; off-color taps end game',
    (tester) async {
      // Boot a deterministic state via the generator and exercise the rules
      // engine directly. This guards against the "tap always wins" bug.
      final params = ColorSwitchParams.fromPhase(1);
      final initial = _generator.generate(params);

      // Tap with current visible color matching → score increments.
      final winning = _tapAtNextMatch(initial);
      expect(winning.score, greaterThan(initial.score));
      expect(winning.isOver, isFalse);

      // Tap with mismatched color → game over.
      var s = initial;
      while (s.visibleRingColor == s.ballColor) {
        s = _rules.applyMove(s, SwitchMove.tick);
      }
      final losing = _rules.applyMove(s, SwitchMove.tap);
      expect(losing.isOver, isTrue);
      expect(losing.isWon, isFalse);
    },
  );

  testWidgets(
    'integration: 5 mistimed taps drive the game to over, score stays low',
    (tester) async {
      // BUG #1 guard: if the gameplay screen ignored visible color, all 5
      // taps would simply pass and score would equal 5. We assert the
      // opposite: with mistimed taps the run terminates with score < 5.
      await tester.pumpWidget(
        const MaterialApp(home: GameplayScreen(phase: 1)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap five times at random-ish moments. With four colors per ring
      // the chance of all five matching is (1/4)^5 ≈ 0.1%. Stable for CI.
      for (var i = 0; i < 5; i++) {
        await tester.tapAt(const Offset(200, 400));
        await tester.pump(const Duration(milliseconds: 137));
      }
      // At least one mismatch must have triggered navigation away from
      // the gameplay screen OR the game over screen replaced it. Either
      // way: the score card with "5 / N" must NOT be visible.
      expect(
        find.text('5 / 5'),
        findsNothing,
        reason: 'all 5 taps cannot win; mechanic is fake',
      );
    },
  );

  testWidgets('tutorial fades after first interaction', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: GameplayScreen(phase: 1)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    expect(
      find.text('Tap when the ring color matches the ball'),
      findsOneWidget,
    );

    // First tap. AnimatedOpacity drives it to 0; widget remains in tree
    // with opacity 0, which is the desired UX.
    await tester.tapAt(const Offset(200, 400));
    await tester.pump(const Duration(milliseconds: 80));

    final opacity = tester.widget<AnimatedOpacity>(
      find.ancestor(
        of: find.text('Tap when the ring color matches the ball'),
        matching: find.byType(AnimatedOpacity),
      ),
    );
    expect(opacity.opacity, 0);
  });
}
