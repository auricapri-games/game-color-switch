import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:game_color_switch/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'auricapri_consent_status': 'granted',
    });
  });

  testWidgets('app boots without crashing', (tester) async {
    await tester.pumpWidget(const GameColorSwitchApp());
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
