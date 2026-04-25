import 'dart:async';

import 'package:flutter/material.dart';

import '../ds/app_colors.dart';
import '../ds/app_theme.dart';
import '../widgets/gradient_background.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _navTimer = Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              final scale = Curves.elasticOut.transform(_ctrl.value);
              final opacity = Curves.easeIn.transform(_ctrl.value);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: scale,
                    child: Image.asset(
                      'assets/sprites/mascot.png',
                      width: 180,
                      height: 180,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Opacity(
                    opacity: opacity,
                    child: Text('Color Switch', style: AppTheme.title(40)),
                  ),
                  const SizedBox(height: 8),
                  Opacity(
                    opacity: opacity * 0.7,
                    child: Text(
                      'Tap when the colors match',
                      style: AppTheme.body(15)
                          .copyWith(color: AppColors.text.withValues(alpha: 0.7)),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
