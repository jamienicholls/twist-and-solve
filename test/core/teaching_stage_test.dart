import 'package:flutter_test/flutter_test.dart';
import 'package:twist_and_solve/core/cube.dart';
import 'package:twist_and_solve/core/face.dart';
import 'package:twist_and_solve/core/move.dart';
import 'package:twist_and_solve/core/solver.dart';
import 'package:twist_and_solve/core/teaching_stage.dart';

// Fixed short scrambles — deterministic and within the IDA* phase depth limits.
const _trigger = [
  Move(MoveFace.U, MoveRotation.cw),
  Move(MoveFace.R, MoveRotation.cw),
  Move(MoveFace.U, MoveRotation.ccw),
  Move(MoveFace.R, MoveRotation.ccw),
];

const _crossAlg = [
  Move(MoveFace.F, MoveRotation.cw),
  Move(MoveFace.R, MoveRotation.cw),
  Move(MoveFace.U, MoveRotation.cw),
  Move(MoveFace.R, MoveRotation.ccw),
  Move(MoveFace.U, MoveRotation.ccw),
  Move(MoveFace.F, MoveRotation.ccw),
];

void main() {
  // ---------------------------------------------------------------------------
  // StickerRef equality
  // ---------------------------------------------------------------------------

  group('StickerRef', () {
    test('equal when face/row/col match', () {
      expect(StickerRef(Face.U, 0, 1), equals(StickerRef(Face.U, 0, 1)));
    });

    test('not equal when face differs', () {
      expect(StickerRef(Face.U, 0, 1), isNot(equals(StickerRef(Face.D, 0, 1))));
    });

    test('usable in a Set', () {
      final s = {StickerRef(Face.U, 0, 1), StickerRef(Face.U, 0, 1)};
      expect(s, hasLength(1));
    });
  });

  // ---------------------------------------------------------------------------
  // TeachingBreakdown — solved cube
  // ---------------------------------------------------------------------------

  group('TeachingBreakdown on solved cube', () {
    late TeachingBreakdown breakdown;

    setUp(() {
      final cube = Cube.solved();
      final result = CubeSolver.solve(cube);
      breakdown = TeachingBreakdown.fromSolveResult(cube, result);
    });

    test('produces one stage per SolvePhase', () {
      expect(breakdown.stages, hasLength(SolvePhase.values.length));
    });

    test('stage names are non-empty strings', () {
      for (final stage in breakdown.stages) {
        expect(stage.stageName, isNotEmpty);
        expect(stage.description, isNotEmpty);
        expect(stage.patternHint, isNotEmpty);
      }
    });

    test('all stages have empty moves for a solved cube', () {
      for (final stage in breakdown.stages) {
        expect(stage.moves, isEmpty);
      }
    });

    test('expectedState equals solved cube for every stage', () {
      for (final stage in breakdown.stages) {
        expect(stage.expectedState, equals(Cube.solved()));
      }
    });

    test('cross stage has correct activeFace', () {
      expect(breakdown.stages.first.highlights.activeFace, equals(Face.U));
    });

    test('cross stage highlights include U edge stickers', () {
      final stickers = breakdown.stages.first.highlights.stickers;
      expect(stickers, contains(StickerRef(Face.U, 0, 1)));
      expect(stickers, contains(StickerRef(Face.U, 1, 0)));
      expect(stickers, contains(StickerRef(Face.U, 1, 2)));
      expect(stickers, contains(StickerRef(Face.U, 2, 1)));
    });

    test('OLL stage activeFace is D', () {
      final oll = breakdown.stages
          .firstWhere((s) => s.stageName == 'Orient Last Layer');
      expect(oll.highlights.activeFace, equals(Face.D));
    });

    test('PLL stage highlights include D face and bottom side rows', () {
      final pll = breakdown.stages
          .firstWhere((s) => s.stageName == 'Permute Last Layer');
      final stickers = pll.highlights.stickers;
      // D face centre
      expect(stickers, contains(StickerRef(Face.D, 1, 1)));
      // Bottom row of F face
      expect(stickers, contains(StickerRef(Face.F, 2, 0)));
      expect(stickers, contains(StickerRef(Face.F, 2, 1)));
      expect(stickers, contains(StickerRef(Face.F, 2, 2)));
    });

    test('second-layer stage has null activeFace', () {
      final sl = breakdown.stages
          .firstWhere((s) => s.stageName == 'Second Layer Edges');
      expect(sl.highlights.activeFace, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // TeachingBreakdown — known scrambles (end-to-end)
  // ---------------------------------------------------------------------------

  group('TeachingBreakdown on known scrambles', () {
    test('applying all stage moves in order solves U R U\' R\'', () {
      final initial = Cube.solved().applyMoves(_trigger);
      final result = CubeSolver.solve(initial);
      final breakdown = TeachingBreakdown.fromSolveResult(initial, result);

      var state = initial;
      for (final stage in breakdown.stages) {
        state = state.applyMoves(stage.moves);
      }
      expect(state, equals(Cube.solved()));
    });

    test('expectedState at each stage matches replayed state', () {
      final initial = Cube.solved().applyMoves(_trigger);
      final result = CubeSolver.solve(initial);
      final breakdown = TeachingBreakdown.fromSolveResult(initial, result);

      var state = initial;
      for (final stage in breakdown.stages) {
        state = state.applyMoves(stage.moves);
        expect(stage.expectedState, equals(state));
      }
    });

    test('stage count equals number of SolvePhases for F R U R\' U\' F\'', () {
      final initial = Cube.solved().applyMoves(_crossAlg);
      final result = CubeSolver.solve(initial);
      final breakdown = TeachingBreakdown.fromSolveResult(initial, result);
      expect(breakdown.stages, hasLength(SolvePhase.values.length));
    });
  });
}
