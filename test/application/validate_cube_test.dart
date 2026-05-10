import 'package:flutter_test/flutter_test.dart';
import 'package:twist_and_solve/application/validate_cube.dart';
import 'package:twist_and_solve/core/cube.dart';
import 'package:twist_and_solve/core/cube_colour.dart';
import 'package:twist_and_solve/core/face.dart';

void main() {
  group('A1 — ValidateCube', () {
    test('solved cube is valid', () {
      final result = ValidateCube.execute(Cube.solved());
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('cube with duplicate colours is invalid', () {
      // Replace all U stickers with white (gives white 18 times, yellow 0).
      final state = {
        for (final f in Face.values)
          f: List<CubeColour>.filled(9, f == Face.U ? CubeColour.yellow : _solved(f)),
      };
      final result = ValidateCube.execute(Cube.fromState(state));
      expect(result.isValid, isFalse);
      expect(result.errors, isNotEmpty);
    });

    test('error messages reference the offending colour', () {
      final state = {
        for (final f in Face.values)
          f: List<CubeColour>.filled(9, f == Face.U ? CubeColour.yellow : _solved(f)),
      };
      final result = ValidateCube.execute(Cube.fromState(state));
      expect(result.errors.any((e) => e.contains('white')), isTrue);
      expect(result.errors.any((e) => e.contains('yellow')), isTrue);
    });
  });
}

// Solved-state colour for each face (white-top, green-front orientation).
CubeColour _solved(Face f) => const {
      Face.U: CubeColour.white,
      Face.D: CubeColour.yellow,
      Face.F: CubeColour.green,
      Face.B: CubeColour.blue,
      Face.L: CubeColour.orange,
      Face.R: CubeColour.red,
    }[f]!;
