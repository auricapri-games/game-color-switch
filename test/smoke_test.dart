import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_color_switch/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('app boots without crashing', (tester) async {
    await tester.pumpWidget(const GameColorSwitchApp());
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
    // Drain the splash auto-navigate timer + a few frames of animation so
    // no pending Timer remains when the binding tears the widget down.
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 60));
    }
  });
}
