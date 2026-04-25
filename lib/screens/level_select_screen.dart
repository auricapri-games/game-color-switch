import 'package:flutter/material.dart';

import '../ds/app_colors.dart';
import '../ds/app_theme.dart';
import '../widgets/gradient_background.dart';
import 'gameplay_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({required this.highestPhase, super.key});

  final int highestPhase;

  static const int _shown = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _Header(onBack: () => Navigator.of(context).pop()),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _shown,
                  itemBuilder: (context, i) {
                    final phase = i + 1;
                    final unlocked = phase <= highestPhase;
                    return _PhaseTile(
                      phase: phase,
                      unlocked: unlocked,
                      onTap: !unlocked
                          ? null
                          : () => Navigator.of(context).pushReplacement(
                                MaterialPageRoute<void>(
                                  builder: (_) => GameplayScreen(phase: phase),
                                ),
                              ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhaseTile extends StatelessWidget {
  const _PhaseTile({
    required this.phase,
    required this.unlocked,
    required this.onTap,
  });

  final int phase;
  final bool unlocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: unlocked
          ? Colors.white.withValues(alpha: 0.85)
          : Colors.white.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Center(
          child: unlocked
              ? Text('$phase', style: AppTheme.title(22))
              : const Icon(Icons.lock_rounded, color: AppColors.text),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.text,
          ),
          const SizedBox(width: 4),
          Text('Levels', style: AppTheme.title(24)),
        ],
      ),
    );
  }
}
