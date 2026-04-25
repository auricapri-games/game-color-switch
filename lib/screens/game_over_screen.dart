import 'package:flutter/material.dart';

import '../ds/app_colors.dart';
import '../ds/app_theme.dart';
import '../widgets/candy_button.dart';
import '../widgets/gradient_background.dart';
import 'gameplay_screen.dart';
import 'home_screen.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({
    required this.phase,
    required this.score,
    super.key,
  });

  final int phase;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        glowColor: AppColors.primary,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.45),
                          AppColors.primary.withValues(alpha: 0),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/sprites/mascot.png',
                        width: 130,
                        height: 130,
                        opacity: const AlwaysStoppedAnimation<double>(0.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Wrong Color!', style: AppTheme.title(34)),
                  const SizedBox(height: 6),
                  Text(
                    'Phase $phase  ·  Score $score',
                    style: AppTheme.subtitle(18),
                  ),
                  const SizedBox(height: 32),
                  CandyButton(
                    label: 'TRY AGAIN',
                    icon: Icons.refresh_rounded,
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => GameplayScreen(phase: phase),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (_) => const HomeScreen(),
                      ),
                      (route) => false,
                    ),
                    child: Text(
                      'Back to Home',
                      style: AppTheme.body(14)
                          .copyWith(color: AppColors.text.withValues(alpha: 0.7)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
