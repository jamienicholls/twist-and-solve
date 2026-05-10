import 'cube.dart';
import 'cube_colour.dart';
import 'cube_validator.dart';
import 'face.dart';
import 'move.dart';

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// The name of each solving phase (used in [SolveStep] and D7 teaching mode).
enum SolvePhase { cross, firstLayerCorners, secondLayer, oll, pll }

/// Moves associated with a single solving phase.
class SolveStep {
  final SolvePhase phase;
  final List<Move> moves;
  const SolveStep(this.phase, this.moves);
}

/// The result returned by [CubeSolver.solve].
class SolveResult {
  /// The complete, ordered solution sequence.
  final List<Move> moves;

  /// The same moves broken down by phase (Cross → Corners → 2nd layer → OLL → PLL).
  final List<SolveStep> steps;

  const SolveResult({required this.moves, required this.steps});
}

/// Solves a [Cube] using a deterministic phase-by-phase IDA* search.
///
/// Each phase is solved independently with a narrow goal, producing a
/// structured [SolveResult] suitable for D7 teaching mode.
class CubeSolver {
  const CubeSolver._();

  static const Duration _maxPhaseDuration = Duration(seconds: 60);

  /// Solves [cube] or throws [ArgumentError] for invalid/unsolvable states.
  static SolveResult solve(Cube cube) {
    // Reject invalid states (D4).
    final validation = CubeValidator.validate(cube);
    if (!validation.isValid) {
      throw ArgumentError(
        'Cannot solve an invalid cube: ${validation.errors.join('; ')}',
      );
    }

    // Solve phase by phase, accumulating moves.
    final phaseResults = <SolveStep>[];
    var state = cube;

    for (final phase in SolvePhase.values) {
      final phaseMoves = _solvePhase(state, phase);
      state = state.applyMoves(phaseMoves);
      phaseResults.add(SolveStep(phase, phaseMoves));
    }

    final allMoves = [for (final s in phaseResults) ...s.moves];
    return SolveResult(moves: allMoves, steps: phaseResults);
  }

  // ---------------------------------------------------------------------------
  // Phase dispatch
  // ---------------------------------------------------------------------------

  static List<Move> _solvePhase(Cube cube, SolvePhase phase) {
    final goal = _phaseGoal(phase);
    if (goal(cube)) return const [];
    return _iddfs(cube, goal, _heuristic(phase), _maxDepth(phase));
  }

  static int _maxDepth(SolvePhase phase) => switch (phase) {
      SolvePhase.cross => 12,
      SolvePhase.firstLayerCorners => 16,
      SolvePhase.secondLayer => 14,
      SolvePhase.oll => 16,
      SolvePhase.pll => 14,
      };

  // ---------------------------------------------------------------------------
  // Goal predicates
  // ---------------------------------------------------------------------------

  static bool Function(Cube) _phaseGoal(SolvePhase phase) => switch (phase) {
        SolvePhase.cross => _crossSolved,
        SolvePhase.firstLayerCorners => _firstLayerSolved,
        SolvePhase.secondLayer => _twoLayersSolved,
        SolvePhase.oll => _ollSolved,
        SolvePhase.pll => (c) => c == Cube.solved(),
      };

  /// White cross on U face: U[1], U[3], U[5], U[7] are white,
  /// and each adjacent centre edge sticker matches its centre.
  static bool _crossSolved(Cube cube) {
    if (cube.sticker(Face.U, 1) != CubeColour.white) return false;
    if (cube.sticker(Face.U, 3) != CubeColour.white) return false;
    if (cube.sticker(Face.U, 5) != CubeColour.white) return false;
    if (cube.sticker(Face.U, 7) != CubeColour.white) return false;
    // Adjacent edge stickers must match face centres.
    if (cube.sticker(Face.F, 1) != cube.sticker(Face.F, 4)) return false;
    if (cube.sticker(Face.B, 1) != cube.sticker(Face.B, 4)) return false;
    if (cube.sticker(Face.L, 1) != cube.sticker(Face.L, 4)) return false;
    if (cube.sticker(Face.R, 1) != cube.sticker(Face.R, 4)) return false;
    return true;
  }

  /// First layer solved: cross + U corners solved.
  /// U corners: U[0],U[2],U[6],U[8] white, adjacent corners match centres.
  static bool _firstLayerSolved(Cube cube) {
    if (!_crossSolved(cube)) return false;
    // Corner stickers on U face.
    if (cube.sticker(Face.U, 0) != CubeColour.white) return false;
    if (cube.sticker(Face.U, 2) != CubeColour.white) return false;
    if (cube.sticker(Face.U, 6) != CubeColour.white) return false;
    if (cube.sticker(Face.U, 8) != CubeColour.white) return false;
    // Side stickers of U corners must match centres.
    // UFL corner → F[0], L[2]
    if (cube.sticker(Face.F, 0) != cube.sticker(Face.F, 4)) return false;
    if (cube.sticker(Face.L, 2) != cube.sticker(Face.L, 4)) return false;
    // UFR corner → F[2], R[0]
    if (cube.sticker(Face.F, 2) != cube.sticker(Face.F, 4)) return false;
    if (cube.sticker(Face.R, 0) != cube.sticker(Face.R, 4)) return false;
    // UBL corner → B[2], L[0]
    if (cube.sticker(Face.B, 2) != cube.sticker(Face.B, 4)) return false;
    if (cube.sticker(Face.L, 0) != cube.sticker(Face.L, 4)) return false;
    // UBR corner → B[0], R[2]
    if (cube.sticker(Face.B, 0) != cube.sticker(Face.B, 4)) return false;
    if (cube.sticker(Face.R, 2) != cube.sticker(Face.R, 4)) return false;
    return true;
  }

  /// Two layers solved: first layer + equator edges solved.
  /// Equator edges: F[3],F[5], L[3],L[5], R[3],R[5], B[3],B[5] match centres.
  static bool _twoLayersSolved(Cube cube) {
    if (!_firstLayerSolved(cube)) return false;
    // Equator edge stickers.
    if (cube.sticker(Face.F, 3) != cube.sticker(Face.F, 4)) return false;
    if (cube.sticker(Face.F, 5) != cube.sticker(Face.F, 4)) return false;
    if (cube.sticker(Face.L, 3) != cube.sticker(Face.L, 4)) return false;
    if (cube.sticker(Face.L, 5) != cube.sticker(Face.L, 4)) return false;
    if (cube.sticker(Face.R, 3) != cube.sticker(Face.R, 4)) return false;
    if (cube.sticker(Face.R, 5) != cube.sticker(Face.R, 4)) return false;
    if (cube.sticker(Face.B, 3) != cube.sticker(Face.B, 4)) return false;
    if (cube.sticker(Face.B, 5) != cube.sticker(Face.B, 4)) return false;
    return true;
  }

  /// OLL solved: all D face stickers are yellow.
  static bool _ollSolved(Cube cube) {
    for (var i = 0; i < 9; i++) {
      if (cube.sticker(Face.D, i) != CubeColour.yellow) return false;
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // Heuristics (admissible lower bounds on moves remaining per phase)
  // ---------------------------------------------------------------------------

  static int Function(Cube) _heuristic(SolvePhase phase) => switch (phase) {
        SolvePhase.cross => _crossHeuristic,
        SolvePhase.firstLayerCorners => _cornersHeuristic,
        SolvePhase.secondLayer => _secondLayerHeuristic,
        SolvePhase.oll => _ollHeuristic,
        SolvePhase.pll => (c) => c == Cube.solved() ? 0 : 1,
      };

  /// Number of cross edge pieces not yet in place and oriented.
  /// ceil(n/2) is admissible: one move can simultaneously fix two cross edges (e.g. U).
  static int _crossHeuristic(Cube cube) {
    var unsolved = 0;
    if (cube.sticker(Face.U, 1) != CubeColour.white ||
        cube.sticker(Face.F, 1) != cube.sticker(Face.F, 4)) unsolved++;
    if (cube.sticker(Face.U, 3) != CubeColour.white ||
        cube.sticker(Face.L, 1) != cube.sticker(Face.L, 4)) unsolved++;
    if (cube.sticker(Face.U, 5) != CubeColour.white ||
        cube.sticker(Face.R, 1) != cube.sticker(Face.R, 4)) unsolved++;
    if (cube.sticker(Face.U, 7) != CubeColour.white ||
        cube.sticker(Face.B, 1) != cube.sticker(Face.B, 4)) unsolved++;
    return (unsolved + 1) ~/ 2;
  }

  static int _cornersHeuristic(Cube cube) {
    if (!_crossSolved(cube)) return _crossHeuristic(cube) + 1;
    var unsolved = 0;
    if (cube.sticker(Face.U, 0) != CubeColour.white) unsolved++;
    if (cube.sticker(Face.U, 2) != CubeColour.white) unsolved++;
    if (cube.sticker(Face.U, 6) != CubeColour.white) unsolved++;
    if (cube.sticker(Face.U, 8) != CubeColour.white) unsolved++;
    return unsolved;
  }

  static int _secondLayerHeuristic(Cube cube) {
    if (!_firstLayerSolved(cube)) return 1;
    var unsolved = 0;
    for (final f in [Face.F, Face.L, Face.R, Face.B]) {
      if (cube.sticker(f, 3) != cube.sticker(f, 4)) unsolved++;
      if (cube.sticker(f, 5) != cube.sticker(f, 4)) unsolved++;
    }
    return unsolved;
  }

  static int _ollHeuristic(Cube cube) {
    if (!_twoLayersSolved(cube)) return 1;
    var notYellow = 0;
    for (var i = 0; i < 9; i++) {
      if (cube.sticker(Face.D, i) != CubeColour.yellow) notYellow++;
    }
    // Each move affects at most 3 D-face stickers directly.
    return (notYellow + 2) ~/ 3;
  }

  // ---------------------------------------------------------------------------
  // IDDFS (Iterative-Deepening Depth-First Search)
  // ---------------------------------------------------------------------------

  static const _allMoves = [
    Move(MoveFace.U, MoveRotation.cw),
    Move(MoveFace.U, MoveRotation.ccw),
    Move(MoveFace.U, MoveRotation.half),
    Move(MoveFace.D, MoveRotation.cw),
    Move(MoveFace.D, MoveRotation.ccw),
    Move(MoveFace.D, MoveRotation.half),
    Move(MoveFace.L, MoveRotation.cw),
    Move(MoveFace.L, MoveRotation.ccw),
    Move(MoveFace.L, MoveRotation.half),
    Move(MoveFace.R, MoveRotation.cw),
    Move(MoveFace.R, MoveRotation.ccw),
    Move(MoveFace.R, MoveRotation.half),
    Move(MoveFace.F, MoveRotation.cw),
    Move(MoveFace.F, MoveRotation.ccw),
    Move(MoveFace.F, MoveRotation.half),
    Move(MoveFace.B, MoveRotation.cw),
    Move(MoveFace.B, MoveRotation.ccw),
    Move(MoveFace.B, MoveRotation.half),
  ];

  // Opposite-face pairs — these faces commute, so we enforce an ordering
  // to avoid searching both (U then D) and (D then U).
  static const _oppositeFace = {
    MoveFace.U: MoveFace.D,
    MoveFace.D: MoveFace.U,
    MoveFace.L: MoveFace.R,
    MoveFace.R: MoveFace.L,
    MoveFace.F: MoveFace.B,
    MoveFace.B: MoveFace.F,
  };

  static List<Move> _iddfs(
    Cube start,
    bool Function(Cube) goal,
    int Function(Cube) heuristic,
    int maxDepth,
  ) {
    final timer = Stopwatch()..start();
    final visits = <int>[0];
    for (var depth = 1; depth <= maxDepth; depth++) {
      final result = <Move>[];
      // Depth-scoped transposition table: avoid re-exploring equivalent states
      // with the same or worse remaining depth.
      final seen = <String, int>{};
      try {
        if (_dfs(
          start,
          goal,
          heuristic,
          depth,
          result,
          null,
          seen,
          timer,
          visits,
        )) {
          return result;
        }
      } on _SearchTimeoutExceeded {
        throw StateError(
          'Search timed out while solving this phase. '
          'The state may be extremely difficult or unsolvable for this solver.',
        );
      }
    }
    throw StateError(
      'Could not solve phase within $maxDepth moves. '
      'The cube may be in an unsolvable state.',
    );
  }

  static bool _dfs(
    Cube cube,
    bool Function(Cube) goal,
    int Function(Cube) heuristic,
    int remaining,
    List<Move> path,
    MoveFace? lastFace,
    Map<String, int> seen,
    Stopwatch timer,
    List<int> visits,
  ) {
    visits[0]++;
    if (visits[0] % 1024 == 0 && timer.elapsed > _maxPhaseDuration) {
      throw const _SearchTimeoutExceeded();
    }

    if (goal(cube)) return true;
    if (remaining == 0) return false;

    final stateKey = _stateKey(cube);

    // Heuristic pruning: if the lower bound exceeds remaining depth, cut.
    final h = heuristic(cube);
    if (h > remaining) return false;

    // Transposition pruning: if we've seen this state (with lastFace context)
    // before at an equal or greater remaining depth, no need to explore again.
    final key = '$stateKey|${lastFace?.index ?? -1}';
    final prevRemaining = seen[key];
    if (prevRemaining != null && prevRemaining >= remaining) {
      return false;
    }
    seen[key] = remaining;

    for (final move in _allMoves) {
      // Same-face pruning.
      if (move.face == lastFace) continue;
      // Opposite-face commutative pruning: enforce canonical ordering.
      if (lastFace != null &&
          move.face == _oppositeFace[lastFace] &&
          move.face.index < lastFace.index) continue;

      final next = cube.applyMove(move);
      path.add(move);
      if (_dfs(
        next,
        goal,
        heuristic,
        remaining - 1,
        path,
        move.face,
        seen,
        timer,
        visits,
      )) {
        return true;
      }
      path.removeLast();
    }
    return false;
  }

  // Compact deterministic state key for transposition pruning.
  static String _stateKey(Cube cube) {
    final sb = StringBuffer();
    for (final f in Face.values) {
      for (var i = 0; i < 9; i++) {
        sb.write(cube.sticker(f, i).index);
      }
      sb.write('|');
    }
    return sb.toString();
  }
}

class _SearchTimeoutExceeded implements Exception {
  const _SearchTimeoutExceeded();
}
