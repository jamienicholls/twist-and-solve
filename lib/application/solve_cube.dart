import '../core/cube.dart';
import '../core/solver.dart';
import '../core/teaching_stage.dart';

export '../core/move.dart' show Move, MoveFace, MoveRotation;
export '../core/solver.dart' show SolveResult, SolveStep, SolvePhase;
export '../core/teaching_stage.dart'
    show TeachingBreakdown, TeachingStage, Highlight, StickerRef;

/// A2 — Solve Cube
///
/// Input:  a [Cube] state
/// Output: [SolveCubeSuccess] with solution moves and teaching breakdown,
///         or [SolveCubeFailure] with an error message.
sealed class SolveCubeResult {}

class SolveCubeSuccess extends SolveCubeResult {
  final SolveResult solveResult;
  final TeachingBreakdown teachingBreakdown;

  SolveCubeSuccess({
    required this.solveResult,
    required this.teachingBreakdown,
  });
}

class SolveCubeFailure extends SolveCubeResult {
  final String error;
  SolveCubeFailure(this.error);
}

class SolveCube {
  const SolveCube._();

  static SolveCubeResult execute(Cube cube) {
    try {
      final result = CubeSolver.solve(cube);
      final breakdown = TeachingBreakdown.fromSolveResult(cube, result);
      return SolveCubeSuccess(
        solveResult: result,
        teachingBreakdown: breakdown,
      );
    } on ArgumentError catch (e) {
      return SolveCubeFailure(e.message.toString());
    } on StateError catch (e) {
      return SolveCubeFailure(e.message);
    }
  }
}
