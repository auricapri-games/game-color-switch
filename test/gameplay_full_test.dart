// Integration test — drives the real widget tree from boot through a full
// gameplay loop. The level generator is solvable-by-construction with the
// ball matching the head ring on every step, so tapping enough times
// always either wins or naturally exhausts moves.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:game_color_switch/main.dart';
import 'package:game_color_switch/screens/gameplay_screen.dart';
import 'package:game_color_switch/screens/level_complete_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<void> stepFrames(WidgetTester tester, int n) async {
    for (var i = 0; i < n; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('boot → home → play → score increments → win', (tester) async {
    await tester.pumpWidget(const GameColorSwitchApp());

    // Splash auto-navigates after 1600ms; pump well past that.
    await stepFrames(tester, 60);

    // Home screen should now be on top with a PLAY button.
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('Color Switch'), findsWidgets);

    await tester.tap(find.text('PLAY'));
    await stepFrames(tester, 20);

    // Gameplay screen visible.
    expect(find.byType(GameplayScreen), findsOneWidget);
    expect(find.textContaining('SCORE'), findsOneWidget);
    expect(find.textContaining('0 /'), findsOneWidget);

    // Tap up to 60 times — the construction guarantees every tap is a
    // match, so the ball clears the ring queue and triggers level
    // complete navigation. Use the global tap area (Scaffold body).
    for (var i = 0; i < 60; i++) {
      // If the gameplay screen is gone the level complete fired.
      if (find.byType(GameplayScreen).evaluate().isEmpty) break;
      await tester.tap(find.byType(GameplayScreen));
      await stepFrames(tester, 4);
    }

    // We should have transitioned to LevelCompleteScreen.
    await stepFrames(tester, 20);
    expect(find.byType(LevelCompleteScreen), findsOneWidget);
    expect(find.text('Level Cleared!'), findsOneWidget);
  });
}
