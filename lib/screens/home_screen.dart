import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ds/app_colors.dart';
import '../ds/app_theme.dart';
import '../widgets/candy_button.dart';
import '../widgets/gradient_background.dart';
import '../widgets/score_card.dart';
import 'gameplay_screen.dart';
import 'legal_screen.dart';
import 'level_select_screen.dart';
import 'remove_ads_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob;
  int _bestScore = 0;
  int _highestPhase = 1;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _bestScore = prefs.getInt('best_score') ?? 0;
      _highestPhase = prefs.getInt('highest_phase') ?? 1;
    });
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  void _onPlay() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameplayScreen(phase: _highestPhase),
      ),
    ).then((_) => _loadStats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: AnimatedBuilder(
                    animation: _bob,
                    builder: (context, child) {
                      final dy = -8 * _bob.value;
                      return Transform.translate(
                        offset: Offset(0, dy),
                        child: child,
                      );
                    },
                    child: Image.asset(
                      'assets/sprites/mascot.png',
                      width: 160,
                      height: 160,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Color Switch',
                  textAlign: TextAlign.center,
                  style: AppTheme.title(40),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap when the ball matches the ring',
                  textAlign: TextAlign.center,
                  style: AppTheme.body(14)
                      .copyWith(color: AppColors.text.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 18),
                Center(
                  child: ScoreCard(
                    icon: Icons.emoji_events_outlined,
                    label: 'BEST',
                    value: '$_bestScore  ·  Phase $_highestPhase',
                  ),
                ),
                const Spacer(),
                CandyButton(
                  label: 'PLAY',
                  icon: Icons.play_arrow_rounded,
                  onPressed: _onPlay,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SoftIconButton(
                      icon: Icons.grid_view_rounded,
                      label: 'Levels',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              LevelSelectScreen(highestPhase: _highestPhase),
                        ),
                      ).then((_) => _loadStats()),
                    ),
                    SoftIconButton(
                      icon: Icons.settings_rounded,
                      label: 'Settings',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                    ),
                    SoftIconButton(
                      icon: Icons.shopping_bag_outlined,
                      label: 'No Ads',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const RemoveAdsScreen(),
                        ),
                      ),
                    ),
                    SoftIconButton(
                      icon: Icons.gavel_outlined,
                      label: 'Legal',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const LegalScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
