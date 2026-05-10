import 'package:flutter_test/flutter_test.dart';
import 'package:twist_and_solve/application/solve_cube.dart';
import 'package:twist_and_solve/core/cube.dart';
import 'package:twist_and_solve/core/cube_colour.dart';
import 'package:twist_and_solve/core/face.dart';
import 'package:twist_and_solve/core/move.dart';

// Known short scramble — within IDA* phase depth limits.
const _trigger = [
  Move(MoveFace.U, MoveRotation.cw),
  Move(MoveFace.R, MoveRotation.cw),
  Move(MoveFace.U, MoveRotation.ccw),
  Move(MoveFace.R, MoveRotation.ccw),
];

void main() {
  group('A2 — SolveCube', () {
    group('solved cube', () {
      late SolveCubeResult result;

      setUp(() => result = SolveCube.execute(Cube.solved()));

      test('returns success', () => expect(result, isA<SolveCubeSuccess>()));

      test('solution move list is empty', () {
        final s = result as SolveCubeSuccess;
        expect(s.solveResult.moves, isEmpty);
      });

      test('teaching breakdown has one stage per phase', () {
        final s = result as SolveCubeSuccess;
        expect(s.teachingBreakdown.stages, hasLength(SolvePhase.values.length));
      });
    });

    group('scrambled cube', () {
      late SolveCubeSuccess success;

      setUp(() {
        final cube = Cube.solved().applyMoves(_trigger);
        success = SolveCube.execute(cube) as SolveCubeSuccess;
      });

      test('applying solution moves solves the cube', () {
        final initial = Cube.solved().applyMoves(_trigger);
        final solved = initial.applyMoves(success.solveResult.moves);
        expect(solved, equals(Cube.solved()));
      });

      test('flat moves equal concatenation of step moves', () {
        final fromSteps = [
          for (final step in success.solveResult.steps) ...step.moves,
        ];
        expect(success.solveResult.moves, equals(fromSteps));
      });

      test('teaching breakdown stage moves also solve the cube', () {
        var state = Cube.solved().applyMoves(_trigger);
        for (final stage in success.teachingBreakdown.stages) {
          state = state.applyMoves(stage.moves);
        }
        expect(state, equals(Cube.solved()));
      });
    });

    group('invalid cube', () {
      test('returns failure for wrong colour counts', () {
        final bad = {
          for (final f in Face.values)
            f: List<CubeColour>.filled(9, CubeColour.white),
        };
        final result = SolveCube.execute(Cube.fromState(bad));
        expect(result, isA<SolveCubeFailure>());
      });

      test('failure carries a non-empty error message', () {
        final bad = {
          for (final f in Face.values)
            f: List<CubeColour>.filled(9, CubeColour.white),
        };
        final failure = SolveCube.execute(Cube.fromState(bad)) as SolveCubeFailure;
        expect(failure.error, isNotEmpty);
      });
    });
  });
}
