import 'package:flutter/material.dart';

import '../ds/app_colors.dart';
import '../ds/app_theme.dart';
import '../widgets/candy_button.dart';
import '../widgets/gradient_background.dart';
import 'gameplay_screen.dart';
import 'home_screen.dart';

class LevelCompleteScreen extends StatelessWidget {
  const LevelCompleteScreen({
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
        glowColor: AppColors.secondary,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/sprites/mascot.png',
                    width: 160,
                    height: 160,
                  ),
                  const SizedBox(height: 12),
                  Text('Level Cleared!', style: AppTheme.title(34)),
                  const SizedBox(height: 6),
                  Text(
                    'Phase $phase  ·  Score $score',
                    style: AppTheme.subtitle(18),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.star_rounded,
                          color: AppColors.secondary,
                          size: 44 + (i == 1 ? 6 : 0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CandyButton(
                    label: 'NEXT PHASE',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => GameplayScreen(phase: phase + 1),
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
