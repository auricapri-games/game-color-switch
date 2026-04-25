import 'package:flutter/material.dart';

import 'ds/app_colors.dart';

void main() {
  runApp(const GameColorSwitchApp());
}

class GameColorSwitchApp extends StatelessWidget {
  const GameColorSwitchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Switch',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'Color Switch — building...',
            style: TextStyle(color: AppColors.text, fontSize: 22),
          ),
        ),
      ),
    );
  }
}
