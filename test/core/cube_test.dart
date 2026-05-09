import 'package:flutter_test/flutter_test.dart';
import 'package:twist_and_solve/core/cube.dart';
import 'package:twist_and_solve/core/cube_colour.dart';
import 'package:twist_and_solve/core/face.dart';

void main() {
  group('Cube.solved()', () {
    test('creates a cube with the correct centre sticker per face', () {
      final cube = Cube.solved();

      expect(cube.sticker(Face.U, 4), CubeColour.white);
      expect(cube.sticker(Face.D, 4), CubeColour.yellow);
      expect(cube.sticker(Face.F, 4), CubeColour.green);
      expect(cube.sticker(Face.B, 4), CubeColour.blue);
      expect(cube.sticker(Face.L, 4), CubeColour.orange);
      expect(cube.sticker(Face.R, 4), CubeColour.red);
    });

    test('every sticker on each face shares the same colour', () {
      final cube = Cube.solved();

      for (final f in Face.values) {
        final stickers = cube.face(f);
        expect(stickers.length, 9);
        expect(stickers.toSet().length, 1,
            reason: 'All stickers on face $f should be the same colour.');
      }
    });

    test('two independent solved cubes are equal', () {
      expect(Cube.solved(), equals(Cube.solved()));
    });

    test('two independent solved cubes share the same hashCode', () {
      expect(Cube.solved().hashCode, Cube.solved().hashCode);
    });
  });

  group('Cube.fromState()', () {
    test('round-trips the state provided', () {
      final state = {
        Face.U: List<CubeColour>.filled(9, CubeColour.white),
        Face.D: List<CubeColour>.filled(9, CubeColour.yellow),
        Face.F: List<CubeColour>.filled(9, CubeColour.green),
        Face.B: List<CubeColour>.filled(9, CubeColour.blue),
        Face.L: List<CubeColour>.filled(9, CubeColour.orange),
        Face.R: List<CubeColour>.filled(9, CubeColour.red),
      };

      final cube = Cube.fromState(state);

      for (final f in Face.values) {
        for (var i = 0; i < 9; i++) {
          expect(cube.sticker(f, i), state[f]![i]);
        }
      }
    });

    test('equals Cube.solved() when given the solved state', () {
      final state = {
        Face.U: List<CubeColour>.filled(9, CubeColour.white),
        Face.D: List<CubeColour>.filled(9, CubeColour.yellow),
        Face.F: List<CubeColour>.filled(9, CubeColour.green),
        Face.B: List<CubeColour>.filled(9, CubeColour.blue),
        Face.L: List<CubeColour>.filled(9, CubeColour.orange),
        Face.R: List<CubeColour>.filled(9, CubeColour.red),
      };

      expect(Cube.fromState(state), equals(Cube.solved()));
    });

    test('accepts a mixed (scrambled) state', () {
      final state = {
        for (final f in Face.values)
          f: List<CubeColour>.generate(
            9,
            (i) => CubeColour.values[i % CubeColour.values.length],
          ),
      };

      final cube = Cube.fromState(state);

      for (final f in Face.values) {
        expect(cube.face(f), state[f]);
      }
    });

    test('throws when a face is missing', () {
      final incomplete = {
        Face.U: List<CubeColour>.filled(9, CubeColour.white),
        Face.D: List<CubeColour>.filled(9, CubeColour.yellow),
        Face.F: List<CubeColour>.filled(9, CubeColour.green),
        Face.B: List<CubeColour>.filled(9, CubeColour.blue),
        Face.L: List<CubeColour>.filled(9, CubeColour.orange),
        // Face.R missing
      };

      expect(() => Cube.fromState(incomplete), throwsArgumentError);
    });

    test('throws when a face has fewer than 9 stickers', () {
      final bad = {
        Face.U: List<CubeColour>.filled(8, CubeColour.white),
        Face.D: List<CubeColour>.filled(9, CubeColour.yellow),
        Face.F: List<CubeColour>.filled(9, CubeColour.green),
        Face.B: List<CubeColour>.filled(9, CubeColour.blue),
        Face.L: List<CubeColour>.filled(9, CubeColour.orange),
        Face.R: List<CubeColour>.filled(9, CubeColour.red),
      };

      expect(() => Cube.fromState(bad), throwsArgumentError);
    });

    test('throws when a face has more than 9 stickers', () {
      final bad = {
        Face.U: List<CubeColour>.filled(10, CubeColour.white),
        Face.D: List<CubeColour>.filled(9, CubeColour.yellow),
        Face.F: List<CubeColour>.filled(9, CubeColour.green),
        Face.B: List<CubeColour>.filled(9, CubeColour.blue),
        Face.L: List<CubeColour>.filled(9, CubeColour.orange),
        Face.R: List<CubeColour>.filled(9, CubeColour.red),
      };

      expect(() => Cube.fromState(bad), throwsArgumentError);
    });
  });

  group('face() and sticker() accessors', () {
    test('face() returns an unmodifiable list', () {
      final cube = Cube.solved();
      expect(
        () => cube.face(Face.U).add(CubeColour.red),
        throwsUnsupportedError,
      );
    });

    test('sticker() throws RangeError for out-of-bounds index', () {
      final cube = Cube.solved();
      expect(() => cube.sticker(Face.U, -1), throwsRangeError);
      expect(() => cube.sticker(Face.U, 9), throwsRangeError);
    });

    test('sticker() accesses all 9 positions deterministically', () {
      final state = {
        Face.U: List<CubeColour>.generate(
          9,
          (i) => CubeColour.values[i % CubeColour.values.length],
        ),
        for (final f in [Face.D, Face.F, Face.B, Face.L, Face.R])
          f: List<CubeColour>.filled(9, CubeColour.white),
      };

      final cube = Cube.fromState(state);

      for (var i = 0; i < 9; i++) {
        expect(
          cube.sticker(Face.U, i),
          CubeColour.values[i % CubeColour.values.length],
        );
      }
    });
  });

  group('Serialization (toMap / fromMap)', () {
    test('toMap produces string keys and colour name values', () {
      final map = Cube.solved().toMap();

      expect(map.keys, containsAll(['U', 'D', 'F', 'B', 'L', 'R']));
      expect(map['U'], everyElement(equals('white')));
      expect(map['D'], everyElement(equals('yellow')));
    });

    test('fromMap round-trips toMap output', () {
      final original = Cube.solved();
      final restored = Cube.fromMap(original.toMap());

      expect(restored, equals(original));
    });

    test('fromMap round-trips a custom state', () {
      final state = {
        for (final f in Face.values)
          f: List<CubeColour>.generate(
            9,
            (i) => CubeColour.values[(i + f.index) % CubeColour.values.length],
          ),
      };

      final original = Cube.fromState(state);
      final restored = Cube.fromMap(original.toMap());

      expect(restored, equals(original));
    });

    test('fromMap throws on unknown face key', () {
      final bad = {'X': List.filled(9, 'white')};
      expect(() => Cube.fromMap(bad), throwsArgumentError);
    });

    test('fromMap throws on unknown colour name', () {
      final map = Cube.solved().toMap();
      map['U'] = List.filled(9, 'purple'); // invalid colour
      expect(() => Cube.fromMap(map), throwsArgumentError);
    });
  });
}
