import 'package:auricapri_games_common/auricapri_games_common.dart';
import 'package:flutter/material.dart';

import 'ds/app_theme.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConsentService.load();
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
      home: const _ConsentGate(child: SplashScreen()),
    );
  }
}

/// Wraps the splash screen so first-launch users see the LGPD/GDPR
/// consent dialog before any analytics or ads bootstraps.
class _ConsentGate extends StatefulWidget {
  const _ConsentGate({required this.child});

  final Widget child;

  @override
  State<_ConsentGate> createState() => _ConsentGateState();
}

class _ConsentGateState extends State<_ConsentGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await ConsentService.ensureConsent(context);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
