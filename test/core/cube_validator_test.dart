import 'package:flutter_test/flutter_test.dart';
import 'package:twist_and_solve/core/cube.dart';
import 'package:twist_and_solve/core/cube_colour.dart';
import 'package:twist_and_solve/core/cube_validator.dart';
import 'package:twist_and_solve/core/face.dart';
import 'package:twist_and_solve/core/move.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Valid states
  // ---------------------------------------------------------------------------

  group('Valid states', () {
    test('solved cube passes', () {
      final result = CubeValidator.validate(Cube.solved());
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('cube after any single move passes', () {
      for (final face in MoveFace.values) {
        for (final rot in MoveRotation.values) {
          final cube = Cube.solved().applyMove(Move(face, rot));
          final result = CubeValidator.validate(cube);
          expect(result.isValid, isTrue,
              reason: 'Move $face $rot should produce a valid state');
        }
      }
    });

    test('cube after a known scramble passes', () {
      final scrambled = Cube.solved().applyMoves([
        Move(MoveFace.R, MoveRotation.cw),
        Move(MoveFace.U, MoveRotation.cw),
        Move(MoveFace.R, MoveRotation.ccw),
        Move(MoveFace.U, MoveRotation.ccw),
      ]);
      final result = CubeValidator.validate(scrambled);
      expect(result.isValid, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Invalid states
  // ---------------------------------------------------------------------------

  group('Invalid states', () {
    /// Builds a state identical to the solved cube, then overrides specific
    /// stickers to introduce a colour imbalance.
    Cube _buildInvalidCube(
        Map<(Face, int), CubeColour> overrides) {
      final state = <Face, List<CubeColour>>{
        Face.U: List.filled(9, CubeColour.white),
        Face.D: List.filled(9, CubeColour.yellow),
        Face.F: List.filled(9, CubeColour.green),
        Face.B: List.filled(9, CubeColour.blue),
        Face.L: List.filled(9, CubeColour.orange),
        Face.R: List.filled(9, CubeColour.red),
      };
      for (final entry in overrides.entries) {
        state[entry.key.$1]![entry.key.$2] = entry.value;
      }
      return Cube.fromState(state);
    }

    test('one colour with 10 stickers is rejected', () {
      // Replace one yellow sticker on D with white → white=10, yellow=8.
      final cube = _buildInvalidCube({(Face.D, 0): CubeColour.white});
      final result = CubeValidator.validate(cube);
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(2));
      expect(result.errors.any((e) => e.contains('white')), isTrue);
      expect(result.errors.any((e) => e.contains('yellow')), isTrue);
    });

    test('all stickers the same colour is rejected', () {
      final allWhite = {
        for (final f in Face.values) f: List<CubeColour>.filled(9, CubeColour.white),
      };
      final cube = Cube.fromState(allWhite);
      final result = CubeValidator.validate(cube);
      expect(result.isValid, isFalse);
      // white appears 54 times; the other 5 colours appear 0 times.
      expect(result.errors.length, 6);
    });

    test('two colours swapped produces exactly two errors', () {
      // Swap one white (U,0) with one yellow (D,0).
      final cube = _buildInvalidCube({
        (Face.U, 0): CubeColour.yellow,
        (Face.D, 0): CubeColour.white,
      });
      // Both white and yellow still have 9 each → still valid!
      // Use a swap that breaks counts: replace white with green.
      final cube2 = _buildInvalidCube({(Face.U, 0): CubeColour.green});
      final result = CubeValidator.validate(cube2);
      expect(result.isValid, isFalse);
      // white=8, green=10
      expect(result.errors.any((e) => e.contains('white')), isTrue);
      expect(result.errors.any((e) => e.contains('green')), isTrue);
    });

    test('error messages mention colour name and count', () {
      final cube = _buildInvalidCube({(Face.U, 0): CubeColour.red});
      final result = CubeValidator.validate(cube);
      // white should now appear 8 times, red 10 times.
      final whiteError = result.errors.firstWhere((e) => e.contains('white'));
      expect(whiteError, contains('8'));
      final redError = result.errors.firstWhere((e) => e.contains('red'));
      expect(redError, contains('10'));
    });
  });

  // ---------------------------------------------------------------------------
  // CubeValidationResult
  // ---------------------------------------------------------------------------

  group('CubeValidationResult', () {
    test('valid result has isValid=true and empty errors', () {
      expect(CubeValidationResult.valid.isValid, isTrue);
      expect(CubeValidationResult.valid.errors, isEmpty);
    });

    test('invalid result has isValid=false and non-empty errors', () {
      final result = CubeValidationResult.invalid(['Some error']);
      expect(result.isValid, isFalse);
      expect(result.errors, ['Some error']);
    });

    test('errors list is unmodifiable', () {
      final result = CubeValidationResult.invalid(['err']);
      expect(() => result.errors.add('x'), throwsUnsupportedError);
    });
  });
}
