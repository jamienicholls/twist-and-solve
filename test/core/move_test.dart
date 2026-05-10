import 'package:flutter_test/flutter_test.dart';
import 'package:twist_and_solve/core/cube.dart';
import 'package:twist_and_solve/core/cube_colour.dart';
import 'package:twist_and_solve/core/face.dart';
import 'package:twist_and_solve/core/move.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Move model
  // ---------------------------------------------------------------------------

  group('Move model', () {
    test('inverse of CW is CCW', () {
      final m = Move(MoveFace.R, MoveRotation.cw);
      expect(m.inverse, Move(MoveFace.R, MoveRotation.ccw));
    });

    test('inverse of CCW is CW', () {
      final m = Move(MoveFace.U, MoveRotation.ccw);
      expect(m.inverse, Move(MoveFace.U, MoveRotation.cw));
    });

    test('inverse of double is double', () {
      final m = Move(MoveFace.F, MoveRotation.half);
      expect(m.inverse, Move(MoveFace.F, MoveRotation.half));
    });

    test('equality and hashCode', () {
      final a = Move(MoveFace.R, MoveRotation.cw);
      final b = Move(MoveFace.R, MoveRotation.cw);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('toString formatting', () {
      expect(Move(MoveFace.R, MoveRotation.cw).toString(), 'R');
      expect(Move(MoveFace.U, MoveRotation.ccw).toString(), "U'");
      expect(Move(MoveFace.F, MoveRotation.half).toString(), 'F2');
    });
  });

  // ---------------------------------------------------------------------------
  // Four-move identity: any face turned CW 4× returns to solved
  // ---------------------------------------------------------------------------

  group('Four CW turns return to solved', () {
    for (final face in MoveFace.values) {
      test('$face × 4', () {
        final move = Move(face, MoveRotation.cw);
        var cube = Cube.solved();
        for (var i = 0; i < 4; i++) {
          cube = cube.applyMove(move);
        }
        expect(cube, equals(Cube.solved()));
      });
    }
  });

  // ---------------------------------------------------------------------------
  // Move + inverse returns to solved
  // ---------------------------------------------------------------------------

  group('Move followed by inverse returns to solved', () {
    for (final face in MoveFace.values) {
      for (final rot in [MoveRotation.cw, MoveRotation.ccw, MoveRotation.half]) {
        test('${Move(face, rot)} then inverse', () {
          final move = Move(face, rot);
          final cube = Cube.solved().applyMove(move).applyMove(move.inverse);
          expect(cube, equals(Cube.solved()));
        });
      }
    }
  });

  // ---------------------------------------------------------------------------
  // Double move = two CW moves
  // ---------------------------------------------------------------------------

  group('Double move equals two CW moves', () {
    for (final face in MoveFace.values) {
      test('$face double', () {
        final double2 = Cube.solved().applyMove(Move(face, MoveRotation.half));
        final twice = Cube.solved()
            .applyMove(Move(face, MoveRotation.cw))
            .applyMove(Move(face, MoveRotation.cw));
        expect(double2, equals(twice));
      });
    }
  });

  // ---------------------------------------------------------------------------
  // applyMoves: known sequence
  // Sexy move (R U R' U') × 6 = identity.
  // ---------------------------------------------------------------------------

  group('applyMoves', () {
    test('sexy move (R U R\' U\') × 6 returns to solved', () {
      final sexyMove = [
        Move(MoveFace.R, MoveRotation.cw),
        Move(MoveFace.U, MoveRotation.cw),
        Move(MoveFace.R, MoveRotation.ccw),
        Move(MoveFace.U, MoveRotation.ccw),
      ];

      var cube = Cube.solved();
      for (var i = 0; i < 6; i++) {
        cube = cube.applyMoves(sexyMove);
      }
      expect(cube, equals(Cube.solved()));
    });

    test('applying a sequence then its inverse returns to solved', () {
      final sequence = [
        Move(MoveFace.R, MoveRotation.cw),
        Move(MoveFace.U, MoveRotation.cw),
        Move(MoveFace.F, MoveRotation.ccw),
        Move(MoveFace.L, MoveRotation.half),
        Move(MoveFace.D, MoveRotation.ccw),
        Move(MoveFace.B, MoveRotation.cw),
      ];
      final inverse = sequence.reversed.map((m) => m.inverse).toList();

      final scrambled = Cube.solved().applyMoves(sequence);
      expect(scrambled, isNot(equals(Cube.solved())));

      final restored = scrambled.applyMoves(inverse);
      expect(restored, equals(Cube.solved()));
    });
  });

  // ---------------------------------------------------------------------------
  // Specific sticker verification after U move
  // ---------------------------------------------------------------------------

  group('Specific sticker positions after U move', () {
    test('U CW moves front top row to right top row', () {
      final cube = Cube.solved().applyMove(Move(MoveFace.U, MoveRotation.cw));

      // After U CW: new R-top should have old F-top colour (green)
      expect(cube.sticker(Face.R, 0), CubeColour.green);
      expect(cube.sticker(Face.R, 1), CubeColour.green);
      expect(cube.sticker(Face.R, 2), CubeColour.green);

      // new B-top should have old R-top colour (red)
      expect(cube.sticker(Face.B, 0), CubeColour.red);
      expect(cube.sticker(Face.B, 1), CubeColour.red);
      expect(cube.sticker(Face.B, 2), CubeColour.red);

      // new L-top should have old B-top colour (blue)
      expect(cube.sticker(Face.L, 0), CubeColour.blue);
      expect(cube.sticker(Face.L, 1), CubeColour.blue);
      expect(cube.sticker(Face.L, 2), CubeColour.blue);

      // new F-top should have old L-top colour (orange)
      expect(cube.sticker(Face.F, 0), CubeColour.orange);
      expect(cube.sticker(Face.F, 1), CubeColour.orange);
      expect(cube.sticker(Face.F, 2), CubeColour.orange);

      // U face itself rotates CW; centre stays the same colour
      expect(cube.sticker(Face.U, 4), CubeColour.white);
    });

    test('R CW moves front right col to U right col', () {
      final cube = Cube.solved().applyMove(Move(MoveFace.R, MoveRotation.cw));

      // new U-right-col should have old F-right-col colour (green)
      expect(cube.sticker(Face.U, 2), CubeColour.green);
      expect(cube.sticker(Face.U, 5), CubeColour.green);
      expect(cube.sticker(Face.U, 8), CubeColour.green);

      // new B-left-col (from back perspective: indices 6,3,0) should have old U-right-col (white)
      expect(cube.sticker(Face.B, 6), CubeColour.white);
      expect(cube.sticker(Face.B, 3), CubeColour.white);
      expect(cube.sticker(Face.B, 0), CubeColour.white);
    });
  });

  // ---------------------------------------------------------------------------
  // Immutability: applyMove returns new cube, original is unchanged
  // ---------------------------------------------------------------------------

  group('Immutability', () {
    test('applyMove returns a new cube and leaves original unchanged', () {
      final original = Cube.solved();
      final moved = original.applyMove(Move(MoveFace.R, MoveRotation.cw));

      expect(moved, isNot(equals(original)));
      expect(original, equals(Cube.solved()));
    });
  });
}
