// Integration test — gameplay validation. Required by quality_gate v2.
//
// The agent (you) MUST replace this stub with a real test that:
//   1. Pumps the app
//   2. Navigates from home to gameplay (tap PLAY)
//   3. Performs N gameplay inputs (tap/swipe/key)
//   4. Verifies that something visible CHANGES — score increments,
//      sprite moves, level advances, etc.
//
// Example skeleton (delete and write your own):
//
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:integration_test/integration_test.dart';
// import 'package:game_color_switch/main.dart';
//
// void main() {
//   IntegrationTestWidgetsFlutterBinding.ensureInitialized();
//
//   testWidgets('home → play → score increases', (tester) async {
//     await tester.pumpWidget(const GameColorSwitchApp());
//     await tester.pumpAndSettle();
//     await tester.tap(find.text('PLAY'));
//     await tester.pumpAndSettle();
//     for (var i = 0; i < 10; i++) {
//       await tester.tapAt(const Offset(200, 400));
//       await tester.pump(const Duration(milliseconds: 100));
//     }
//     expect(find.textContaining(RegExp(r'\d+')), findsWidgets);
//   });
// }

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('STUB — agent must replace with real gameplay test', () {
    // Quality gate v2 will fail unless this becomes a widget test that
    // simulates gameplay and asserts visible change.
    fail('integration_test/gameplay_test.dart is a STUB. Implement it.');
  });
}
