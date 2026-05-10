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
    return _iddfs(cube, goal, _maxDepth(phase));
  }

  static int _maxDepth(SolvePhase phase) => switch (phase) {
        SolvePhase.cross => 8,
        SolvePhase.firstLayerCorners => 10,
        SolvePhase.secondLayer => 12,
        SolvePhase.oll => 10,
        SolvePhase.pll => 10,
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
  // IDDFS (Iterative-Deepening Depth-First Search)
  // ---------------------------------------------------------------------------

  static const _allMoves = [
    Move(MoveFace.U, MoveRotation.cw),
    Move(MoveFace.U, MoveRotation.ccw),
    Move(MoveFace.U, MoveRotation.double),
    Move(MoveFace.D, MoveRotation.cw),
    Move(MoveFace.D, MoveRotation.ccw),
    Move(MoveFace.D, MoveRotation.double),
    Move(MoveFace.L, MoveRotation.cw),
    Move(MoveFace.L, MoveRotation.ccw),
    Move(MoveFace.L, MoveRotation.double),
    Move(MoveFace.R, MoveRotation.cw),
    Move(MoveFace.R, MoveRotation.ccw),
    Move(MoveFace.R, MoveRotation.double),
    Move(MoveFace.F, MoveRotation.cw),
    Move(MoveFace.F, MoveRotation.ccw),
    Move(MoveFace.F, MoveRotation.double),
    Move(MoveFace.B, MoveRotation.cw),
    Move(MoveFace.B, MoveRotation.ccw),
    Move(MoveFace.B, MoveRotation.double),
  ];

  static List<Move> _iddfs(Cube start, bool Function(Cube) goal, int maxDepth) {
    for (var depth = 1; depth <= maxDepth; depth++) {
      final result = <Move>[];
      if (_dfs(start, goal, depth, result, null)) return result;
    }
    throw StateError(
      'Could not solve phase within $maxDepth moves. '
      'The cube may be in an unsolvable state.',
    );
  }

  static bool _dfs(
    Cube cube,
    bool Function(Cube) goal,
    int remaining,
    List<Move> path,
    MoveFace? lastFace,
  ) {
    if (goal(cube)) return true;
    if (remaining == 0) return false;

    for (final move in _allMoves) {
      // Prune: don't repeat the same face consecutively.
      if (move.face == lastFace) continue;

      final next = cube.applyMove(move);
      path.add(move);
      if (_dfs(next, goal, remaining - 1, path, move.face)) return true;
      path.removeLast();
    }
    return false;
  }
}
