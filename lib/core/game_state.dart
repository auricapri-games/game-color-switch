import 'package:auricapri_engine/auricapri_engine.dart' as engine;
import 'package:meta/meta.dart';

/// Discrete colors a sphere or ring sector can take in Color Switch.
enum SwitchColor { red, blue, green, yellow }

/// Immutable per-tick game state.
///
/// Each ring in [ringQueue] is a [SwitchColor]; the ball passes a ring only
/// when the ball's current color matches that ring's color. After a
/// successful pass the ring is removed from the head of the queue and the
/// next ring is presented; the ball is recolored to a new random color (the
/// generator pre-computes the color stream for determinism).
@immutable
class ColorSwitchState extends engine.GameState {
  const ColorSwitchState({
    required super.phase,
    required super.score,
    required super.movesUsed,
    required super.isOver,
    required super.isWon,
    required this.ballColor,
    required this.ringQueue,
    required this.nextBallStream,
    required this.targetScore,
  });

  /// Current color of the player-controlled ball.
  final SwitchColor ballColor;

  /// FIFO queue of upcoming ring colors. Head = ring under the ball now.
  final List<SwitchColor> ringQueue;

  /// Pre-shuffled stream of next ball colors after each successful pass.
  /// Drawn one per pass; deterministic for a given seed.
  final List<SwitchColor> nextBallStream;

  /// Score required to clear the current phase.
  final int targetScore;

  /// Color of the active (passable) ring — null when board is exhausted.
  SwitchColor? get currentRingColor =>
      ringQueue.isEmpty ? null : ringQueue.first;

  ColorSwitchState copyWith({
    int? phase,
    int? score,
    int? movesUsed,
    bool? isOver,
    bool? isWon,
    SwitchColor? ballColor,
    List<SwitchColor>? ringQueue,
    List<SwitchColor>? nextBallStream,
    int? targetScore,
  }) =>
      ColorSwitchState(
        phase: phase ?? this.phase,
        score: score ?? this.score,
        movesUsed: movesUsed ?? this.movesUsed,
        isOver: isOver ?? this.isOver,
        isWon: isWon ?? this.isWon,
        ballColor: ballColor ?? this.ballColor,
        ringQueue: ringQueue ?? this.ringQueue,
        nextBallStream: nextBallStream ?? this.nextBallStream,
        targetScore: targetScore ?? this.targetScore,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ColorSwitchState) return false;
    return other.phase == phase &&
        other.score == score &&
        other.movesUsed == movesUsed &&
        other.isOver == isOver &&
        other.isWon == isWon &&
        other.ballColor == ballColor &&
        other.targetScore == targetScore &&
        _listEq(other.ringQueue, ringQueue) &&
        _listEq(other.nextBallStream, nextBallStream);
  }

  @override
  int get hashCode => Object.hash(
        phase,
        score,
        movesUsed,
        isOver,
        isWon,
        ballColor,
        targetScore,
        Object.hashAll(ringQueue),
        Object.hashAll(nextBallStream),
      );
}

bool _listEq<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
