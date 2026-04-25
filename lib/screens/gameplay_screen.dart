import 'dart:async';

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

  late final ValueNotifier<ColorSwitchState> _state;
  late final ColorSwitchParams _params;
  late final AnimationController _spin;
  Timer? _tickTimer;
  bool _navigated = false;
  bool _hasInteracted = false;

  Duration get _tickPeriod =>
      Duration(milliseconds: (1000 / _params.tickHz).round().clamp(80, 1000));

  @override
  void initState() {
    super.initState();
    _params = ColorSwitchParams.fromPhase(widget.phase);
    _state = ValueNotifier<ColorSwitchState>(_generator.generate(_params));
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _scheduleTicks();
  }

  void _scheduleTicks() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(_tickPeriod, (_) {
      if (!mounted) return;
      final s = _state.value;
      if (s.isOver) return;
      _state.value = _rules.applyMove(s, SwitchMove.tick);
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _spin.dispose();
    _state.dispose();
    super.dispose();
  }

  Future<void> _persistOutcome(ColorSwitchState s) async {
    final prefs = await SharedPreferences.getInstance();
    final best = prefs.getInt('best_score') ?? 0;
    if (s.score > best) {
      await prefs.setInt('best_score', s.score);
    }
    if (s.isWon) {
      final highest = prefs.getInt('highest_phase') ?? 1;
      if (widget.phase + 1 > highest) {
        await prefs.setInt('highest_phase', widget.phase + 1);
      }
    }
  }

  void _onTap() {
    final s = _state.value;
    if (s.isOver) return;
    if (!_hasInteracted) _hasInteracted = true;
    final next = _rules.applyMove(s, SwitchMove.tap);
    _state.value = next;
    if (next.isOver && !_navigated) {
      _navigated = true;
      _tickTimer?.cancel();
      _spin.stop();
      _persistOutcome(next).then((_) {
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
              child: ValueListenableBuilder<ColorSwitchState>(
                valueListenable: _state,
                builder: (context, state, _) => _Body(
                  state: state,
                  phase: widget.phase,
                  spin: _spin,
                  hasInteracted: _hasInteracted,
                  onPause: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.state,
    required this.phase,
    required this.spin,
    required this.hasInteracted,
    required this.onPause,
  });

  final ColorSwitchState state;
  final int phase;
  final AnimationController spin;
  final bool hasInteracted;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    final visible = state.visibleRingColor;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton.filledTonal(
              onPressed: onPause,
              icon: const Icon(Icons.pause_rounded),
            ),
            ScoreCard(
              key: const ValueKey<String>('score-card'),
              icon: Icons.bolt_rounded,
              label: 'SCORE',
              value: '${state.score} / ${state.targetScore}',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Phase $phase',
          style: AppTheme.subtitle(16)
              .copyWith(color: AppColors.text.withValues(alpha: 0.7)),
        ),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (visible != null)
                AnimatedBuilder(
                  animation: spin,
                  builder: (context, _) => SpinningRing(
                    color: visible,
                    spinTurns: spin.value,
                    size: 240,
                  ),
                ),
              BallSprite(color: state.ballColor, size: 56),
            ],
          ),
        ),
        AnimatedOpacity(
          opacity: hasInteracted ? 0 : 1,
          duration: const Duration(milliseconds: 250),
          child: Text(
            'Tap when the ring color matches the ball',
            textAlign: TextAlign.center,
            style: AppTheme.body(13)
                .copyWith(color: AppColors.text.withValues(alpha: 0.65)),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
