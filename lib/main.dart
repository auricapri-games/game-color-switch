import 'package:flutter/material.dart';

import 'ds/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const GameColorSwitchApp());
}

class GameColorSwitchApp extends StatelessWidget {
  const GameColorSwitchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Switch',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const SplashScreen(),
    );
  }
}
