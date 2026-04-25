import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/level_params.dart';
import '../core/game_rules.dart';
import '../core/game_state.dart';
import '../core/level_generator.dart';
import '../ds/app_colors.dart';
import '../ds/app_theme.dart';
import '../widgets/ball_sprite.dart';
import '../widgets/gradient_background.dart';
import '../widgets/score_card.dart';
import '../widgets/spinning_ring.dart';
import 'game_over_screen.dart';
import 'level_complete_screen.dart';

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({required this.phase, super.key});

  final int phase;

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen>
    with TickerProviderStateMixin {
  static const _rules = ColorSwitchRules();
  static const _generator = ColorSwitchLevelGenerator();

  late ColorSwitchState _state;
  late ColorSwitchParams _params;
  late final AnimationController _spin;
  late final AnimationController _ballPulse;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _params = ColorSwitchParams.fromPhase(widget.phase);
    _state = _generator.generate(_params);
    _spin = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (1000 / _params.spinSpeedHz).round()),
    )..repeat();
    _ballPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _spin.dispose();
    _ballPulse.dispose();
    super.dispose();
  }

  Future<void> _persistOutcome() async {
    final prefs = await SharedPreferences.getInstance();
    final best = prefs.getInt('best_score') ?? 0;
    if (_state.score > best) {
      await prefs.setInt('best_score', _state.score);
    }
    if (_state.isWon) {
      final highest = prefs.getInt('highest_phase') ?? 1;
      if (widget.phase + 1 > highest) {
        await prefs.setInt('highest_phase', widget.phase + 1);
      }
    }
  }

  void _onTap() {
    if (_state.isOver) return;
    final next = _rules.applyMove(_state, SwitchMove.tap);
    setState(() => _state = next);
    if (next.isOver && !_navigated) {
      _navigated = true;
      _spin.stop();
      _ballPulse.stop();
      _persistOutcome().then((_) {
        if (!mounted) return;
        final replacement = next.isWon
            ? LevelCompleteScreen(phase: widget.phase, score: next.score)
            : GameOverScreen(phase: widget.phase, score: next.score);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => replacement),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.pause_rounded),
                      ),
                      ScoreCard(
                        icon: Icons.bolt_rounded,
                        label: 'SCORE',
                        value: '${_state.score} / ${_state.targetScore}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Phase ${widget.phase}',
                    style: AppTheme.subtitle(16)
                        .copyWith(color: AppColors.text.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_state.currentRingColor != null)
                          AnimatedBuilder(
                            animation: _spin,
                            builder: (context, _) => SpinningRing(
                              color: _state.currentRingColor!,
                              spinTurns: _spin.value,
                              size: 240,
                            ),
                          ),
                        if (_state.ringQueue.length > 1)
                          Positioned(
                            top: 24,
                            child: Opacity(
                              opacity: 0.45,
                              child: SpinningRing(
                                color: _state.ringQueue[1],
                                spinTurns: 0,
                                size: 120,
                              ),
                            ),
                          ),
                        AnimatedBuilder(
                          animation: _ballPulse,
                          builder: (context, _) {
                            final s = 0.95 + 0.1 * _ballPulse.value;
                            return Transform.scale(
                              scale: s,
                              child: BallSprite(
                                color: _state.ballColor,
                                size: 56,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'TAP anywhere when the ring matches the ball',
                    textAlign: TextAlign.center,
                    style: AppTheme.body(13)
                        .copyWith(color: AppColors.text.withValues(alpha: 0.65)),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
