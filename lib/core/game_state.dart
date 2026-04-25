import 'package:auricapri_engine/auricapri_engine.dart' as engine;
import 'package:meta/meta.dart';

/// Discrete colors a sphere or ring sector can take in Color Switch.
enum SwitchColor { red, blue, green, yellow }

/// Immutable per-tick game state.
///
/// Each ring is a rotating palette. The currently visible color of the
/// head ring is `ringPalette[rotationIndex % ringPalette.length]`. The
/// ball passes only when the visible color equals [ballColor] at the
/// moment the player taps.
@immutable
class ColorSwitchState extends engine.GameState {
  const ColorSwitchState({
    required super.phase,
    required super.score,
    required super.movesUsed,
    required super.isOver,
    required super.isWon,
    required this.ballColor,
    required this.ringPalettes,
    required this.rotationIndex,
    required this.nextBallStream,
    required this.targetScore,
  });

  /// Current color of the player-controlled ball.
  final SwitchColor ballColor;

  /// Per-ring rotating palettes. Head = current ring under the ball.
  final List<List<SwitchColor>> ringPalettes;

  /// Pre-shuffled stream of next ball colors after each successful pass.
  final List<SwitchColor> nextBallStream;

  /// Visible-sector index inside the head ring's palette.
  final int rotationIndex;

  /// Score required to clear the current phase.
  final int targetScore;

  /// Color currently visible (the one a tap would commit to).
  SwitchColor? get visibleRingColor {
    if (ringPalettes.isEmpty) return null;
    final head = ringPalettes.first;
    if (head.isEmpty) return null;
    return head[rotationIndex % head.length];
  }

  int get ringsRemaining => ringPalettes.length;

  ColorSwitchState copyWith({
    int? phase,
    int? score,
    int? movesUsed,
    bool? isOver,
    bool? isWon,
    SwitchColor? ballColor,
    List<List<SwitchColor>>? ringPalettes,
    List<SwitchColor>? nextBallStream,
    int? rotationIndex,
    int? targetScore,
  }) =>
      ColorSwitchState(
        phase: phase ?? this.phase,
        score: score ?? this.score,
        movesUsed: movesUsed ?? this.movesUsed,
        isOver: isOver ?? this.isOver,
        isWon: isWon ?? this.isWon,
        ballColor: ballColor ?? this.ballColor,
        ringPalettes: ringPalettes ?? this.ringPalettes,
        nextBallStream: nextBallStream ?? this.nextBallStream,
        rotationIndex: rotationIndex ?? this.rotationIndex,
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
        other.rotationIndex == rotationIndex &&
        _palettesEq(other.ringPalettes, ringPalettes) &&
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
        rotationIndex,
        ringPalettes.length,
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

bool _palettesEq(List<List<SwitchColor>> a, List<List<SwitchColor>> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (!_listEq(a[i], b[i])) return false;
  }
  return true;
}
