import 'package:flutter_test/flutter_test.dart';
import 'package:twist_and_solve/core/cube.dart';
import 'package:twist_and_solve/core/cube_colour.dart';
import 'package:twist_and_solve/core/face.dart';
import 'package:twist_and_solve/core/move.dart';
import 'package:twist_and_solve/core/solver.dart';

/// Convenience scramble helper.
Cube scramble(List<Move> moves) => Cube.solved().applyMoves(moves);

void main() {
  // ---------------------------------------------------------------------------
  // Solved cube
  // ---------------------------------------------------------------------------

  group('Solved cube', () {
    test('returns empty move list', () {
      final result = CubeSolver.solve(Cube.solved());
      expect(result.moves, isEmpty);
    });

    test('returns all phases with empty moves', () {
      final result = CubeSolver.solve(Cube.solved());
      expect(result.steps, hasLength(SolvePhase.values.length));
      for (final step in result.steps) {
        expect(step.moves, isEmpty);
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Known scrambles
  // ---------------------------------------------------------------------------

  group('Known scrambles', () {
    void expectSolves(List<Move> scrambleMoves, String label) {
      final cube = scramble(scrambleMoves);
      final result = CubeSolver.solve(cube);
      final solved = cube.applyMoves(result.moves);
      expect(solved, equals(Cube.solved()),
          reason: '$label: applying solution should yield Cube.solved()');
    }

    test('single U move', () {
      expectSolves([Move(MoveFace.U, MoveRotation.cw)], 'U');
    });

    test('single R move', () {
      expectSolves([Move(MoveFace.R, MoveRotation.cw)], 'R');
    });

    test('U R U\' R\' (beginner trigger)', () {
      expectSolves([
        Move(MoveFace.U, MoveRotation.cw),
        Move(MoveFace.R, MoveRotation.cw),
        Move(MoveFace.U, MoveRotation.ccw),
        Move(MoveFace.R, MoveRotation.ccw),
      ], "U R U' R'");
    });

    test('F R U R\' U\' F\' (cross algorithm)', () {
      expectSolves([
        Move(MoveFace.F, MoveRotation.cw),
        Move(MoveFace.R, MoveRotation.cw),
        Move(MoveFace.U, MoveRotation.cw),
        Move(MoveFace.R, MoveRotation.ccw),
        Move(MoveFace.U, MoveRotation.ccw),
        Move(MoveFace.F, MoveRotation.ccw),
      ], "F R U R' U' F'");
    });
  });

  // ---------------------------------------------------------------------------
  // Solution validity
  // ---------------------------------------------------------------------------

  group('Solution validity', () {
    test('applying solution to scramble yields Cube.solved()', () {
      final scrambleMoves = [
        Move(MoveFace.R, MoveRotation.cw),
        Move(MoveFace.U, MoveRotation.cw),
        Move(MoveFace.R, MoveRotation.ccw),
        Move(MoveFace.U, MoveRotation.ccw),
        Move(MoveFace.F, MoveRotation.cw),
        Move(MoveFace.R, MoveRotation.half),
      ];
      final cube = scramble(scrambleMoves);
      final result = CubeSolver.solve(cube);
      expect(cube.applyMoves(result.moves), equals(Cube.solved()));
    });

    test('steps phases appear in correct order', () {
      final cube = scramble([
        Move(MoveFace.R, MoveRotation.cw),
        Move(MoveFace.U, MoveRotation.cw),
      ]);
      final result = CubeSolver.solve(cube);
      final phases = result.steps.map((s) => s.phase).toList();
      expect(phases, SolvePhase.values);
    });

    test('flat moves equals concatenation of step moves', () {
      final cube = scramble([
        Move(MoveFace.L, MoveRotation.cw),
        Move(MoveFace.D, MoveRotation.ccw),
      ]);
      final result = CubeSolver.solve(cube);
      final fromSteps = [for (final s in result.steps) ...s.moves];
      expect(result.moves, fromSteps);
    });
  });

  // ---------------------------------------------------------------------------
  // Determinism
  // ---------------------------------------------------------------------------

  group('Determinism', () {
    test('same input produces same output', () {
      final scrambleMoves = [
        Move(MoveFace.R, MoveRotation.cw),
        Move(MoveFace.U, MoveRotation.cw),
        Move(MoveFace.R, MoveRotation.ccw),
        Move(MoveFace.U, MoveRotation.ccw),
      ];
      final cube = scramble(scrambleMoves);
      final r1 = CubeSolver.solve(cube);
      final r2 = CubeSolver.solve(cube);
      expect(r1.moves, r2.moves);
    });
  });

  // ---------------------------------------------------------------------------
  // Invalid cubes
  // ---------------------------------------------------------------------------

  group('Invalid cubes', () {
    test('throws ArgumentError for invalid colour counts', () {
      // All-white cube has wrong colour distribution.
      final allWhite = {
        for (final f in Face.values) f: List<CubeColour>.filled(9, CubeColour.white),
      };
      final cube = Cube.fromState(allWhite);
      expect(() => CubeSolver.solve(cube), throwsArgumentError);
    });
  });
}
