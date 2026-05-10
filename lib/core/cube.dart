import 'cube_colour.dart';
import 'face.dart';
import 'move.dart';

// Standard solved-state colour for each face (white-top, green-front orientation).
const _solvedColours = {
  Face.U: CubeColour.white,
  Face.D: CubeColour.yellow,
  Face.F: CubeColour.green,
  Face.B: CubeColour.blue,
  Face.L: CubeColour.orange,
  Face.R: CubeColour.red,
};

class Cube {
  final Map<Face, List<CubeColour>> _faces;

  Cube._(Map<Face, List<CubeColour>> faces)
      : _faces = Map.unmodifiable(
          faces.map((f, stickers) => MapEntry(f, List<CubeColour>.unmodifiable(stickers))),
        );

  factory Cube.solved() => Cube._(
        Map.fromEntries(
          Face.values.map(
            (f) => MapEntry(f, List.filled(9, _solvedColours[f]!)),
          ),
        ),
      );

  factory Cube.fromState(Map<Face, List<CubeColour>> state) {
    if (state.length != Face.values.length) {
      throw ArgumentError(
        'Expected ${Face.values.length} faces, got ${state.length}.',
      );
    }
    for (final f in Face.values) {
      if (!state.containsKey(f)) {
        throw ArgumentError('Missing face: $f.');
      }
      if (state[f]!.length != 9) {
        throw ArgumentError(
          'Face $f must have 9 stickers, got ${state[f]!.length}.',
        );
      }
    }
    return Cube._(state);
  }

  factory Cube.fromMap(Map<String, List<String>> map) {
    final state = <Face, List<CubeColour>>{};
    for (final entry in map.entries) {
      final face = Face.values.firstWhere(
        (f) => f.name == entry.key,
        orElse: () => throw ArgumentError('Unknown face key: "${entry.key}".'),
      );
      final stickers = entry.value.map((s) {
        return CubeColour.values.firstWhere(
          (c) => c.name == s,
          orElse: () => throw ArgumentError('Unknown colour: "$s".'),
        );
      }).toList();
      state[face] = stickers;
    }
    return Cube.fromState(state);
  }

  List<CubeColour> face(Face f) => _faces[f]!;

  CubeColour sticker(Face f, int index) {
    RangeError.checkValidIndex(index, _faces[f]!, 'index', 9);
    return _faces[f]![index];
  }

  Map<String, List<String>> toMap() => _faces.map(
        (f, stickers) =>
            MapEntry(f.name, stickers.map((c) => c.name).toList()),
      );

  /// Returns a new [Cube] with [move] applied.
  Cube applyMove(Move move) => _applyMoveTimes(move, 1);

  /// Returns a new [Cube] with each move in [moves] applied in order.
  Cube applyMoves(Iterable<Move> moves) {
    var cube = this;
    for (final m in moves) {
      cube = cube.applyMove(m);
    }
    return cube;
  }

  Cube _applyMoveTimes(Move move, int times) {
    final reps = switch (move.rotation) {
      MoveRotation.cw => 1,
      MoveRotation.ccw => 3,
      MoveRotation.double => 2,
    } *
        times;
    var cube = this;
    for (var i = 0; i < reps % 4; i++) {
      cube = cube._applyCwMove(move.face);
    }
    return cube;
  }

  /// Applies a single 90° clockwise turn of [moveFace] and returns the new cube.
  Cube _applyCwMove(MoveFace moveFace) {
    // Work on mutable copies.
    final next = _faces.map((f, s) => MapEntry(f, s.toList()));

    final face = _moveFaceToFace(moveFace);

    // Rotate the turning face's stickers clockwise.
    // Layout:
    //   0 1 2
    //   3 4 5
    //   6 7 8
    // CW: new[0]=old[6], new[1]=old[3], new[2]=old[0],
    //     new[3]=old[7], new[4]=old[4], new[5]=old[1],
    //     new[6]=old[8], new[7]=old[5], new[8]=old[2]
    const cwSrc = [6, 3, 0, 7, 4, 1, 8, 5, 2];
    final old = _faces[face]!;
    final rotated = List<CubeColour>.generate(9, (i) => old[cwSrc[i]]);
    next[face] = rotated;

    // Cycle the adjacent stickers.
    // Each cycle entry is a list of 4 (face, [indices]) in CW order.
    // After one CW turn: slot[n] = old slot[n-1] (cycle shifts forward).
    final cycles = _adjacentCycles[moveFace]!;
    for (final cycle in cycles) {
      // cycle = [(face0, [i0..]), (face1, [i1..]), (face2, [i2..]), (face3, [i3..])]
      // CW means face1 ← face0, face2 ← face1, face3 ← face2, face0 ← face3
      final saved = _readSlots(_faces, cycle[3].$1, cycle[3].$2);
      for (var k = 3; k > 0; k--) {
        _writeSlots(next, cycle[k].$1, cycle[k].$2,
            _readSlots(_faces, cycle[k - 1].$1, cycle[k - 1].$2));
      }
      _writeSlots(next, cycle[0].$1, cycle[0].$2, saved);
    }

    return Cube._(next);
  }

  static List<CubeColour> _readSlots(
      Map<Face, List<CubeColour>> faces, Face f, List<int> indices) {
    return [for (final i in indices) faces[f]![i]];
  }

  static void _writeSlots(Map<Face, List<CubeColour>> faces, Face f,
      List<int> indices, List<CubeColour> values) {
    for (var i = 0; i < indices.length; i++) {
      faces[f]![indices[i]] = values[i];
    }
  }

  static Face _moveFaceToFace(MoveFace mf) {
    return switch (mf) {
      MoveFace.U => Face.U,
      MoveFace.D => Face.D,
      MoveFace.L => Face.L,
      MoveFace.R => Face.R,
      MoveFace.F => Face.F,
      MoveFace.B => Face.B,
    };
  }

  // Adjacent sticker cycles for each face's clockwise turn.
  // Each entry is a list of cycle groups; each cycle group has 4 (Face, indices) pairs
  // in clockwise order: slot[n] receives old slot[n-1].
  //
  // Orientation: U=white/top, F=green/front, R=red/right, B=blue/back, L=orange/left, D=yellow/bottom.
  //
  // Sticker index layout per face:
  //   0 1 2
  //   3 4 5
  //   6 7 8
  static const _adjacentCycles = <MoveFace, List<List<(Face, List<int>)>>>{
    // U clockwise (looking from top): F-top → R-top → B-top → L-top (cycle: slot[n] ← slot[n-1])
    // new F-top ← old L-top, new R-top ← old F-top, new B-top ← old R-top, new L-top ← old B-top
    MoveFace.U: [
      [
        (Face.F, [0, 1, 2]),
        (Face.R, [0, 1, 2]),
        (Face.B, [0, 1, 2]),
        (Face.L, [0, 1, 2]),
      ],
    ],

    // D clockwise (looking from bottom): F-bottom → L-bottom → B-bottom → R-bottom
    // new F-bottom ← old R-bottom, new L-bottom ← old F-bottom,
    // new B-bottom ← old L-bottom, new R-bottom ← old B-bottom
    MoveFace.D: [
      [
        (Face.F, [6, 7, 8]),
        (Face.L, [6, 7, 8]),
        (Face.B, [6, 7, 8]),
        (Face.R, [6, 7, 8]),
      ],
    ],

    // F clockwise (looking from front):
    // U-bottom ← L-right-col (reversed), R-left-col ← U-bottom, D-top ← R-left-col (reversed), L-right-col ← D-top
    // U bottom row: indices [6,7,8]   (left→right)
    // R left col:   indices [0,3,6]   (top→bottom)
    // D top row:    indices [2,1,0]   (right→left, i.e. reversed)  <- actually [0,1,2] but reversed in direction
    // L right col:  indices [8,5,2]   (bottom→top)
    //
    // CW F turn: U[6,7,8] → R[0,3,6], R[0,3,6] → D[2,1,0], D[2,1,0] → L[8,5,2], L[8,5,2] → U[6,7,8]
    MoveFace.F: [
      [
        (Face.U, [6, 7, 8]),
        (Face.R, [0, 3, 6]),
        (Face.D, [2, 1, 0]),
        (Face.L, [8, 5, 2]),
      ],
    ],

    // B clockwise (looking from back, i.e. reversed left-right):
    // U-top row → L-left-col (reversed), L-left-col → D-bottom (reversed), D-bottom → R-right-col (reversed), R-right-col → U-top
    // U top row:   [0,1,2] left→right
    // L left col:  [0,3,6] top→bottom → reversed = [6,3,0]
    // D bottom:    [8,7,6] → reversed of [6,7,8]
    // R right col: [2,5,8] top→bottom
    //
    // CW B: U[2,1,0] → R[2,5,8], R[2,5,8] → D[6,7,8]... let me use the verified mapping:
    // new U-top ← old R-right (reversed): U[0,1,2] ← R[8,5,2]
    // new R-right ← old D-bottom:         R[2,5,8] ← D[6,7,8]
    // new D-bottom ← old L-left (rev):    D[8,7,6] ← L[0,3,6]  → D[6,7,8] ← L[6,3,0]
    // new L-left ← old U-top (rev):       L[0,3,6] ← U[2,1,0]
    MoveFace.B: [
      [
        (Face.U, [0, 1, 2]),
        (Face.L, [6, 3, 0]),
        (Face.D, [8, 7, 6]),
        (Face.R, [2, 5, 8]),
      ],
    ],

    // R clockwise (looking from right):
    // U-right-col → B-left-col (reversed), B ← D, D ← F, F ← U
    // U right col: [2,5,8] top→bottom
    // B left col:  [8,5,2] bottom→top (reversed because B faces opposite direction)
    // D right col: [2,5,8]
    // F right col: [2,5,8]
    //
    // CW R: F[2,5,8] → U[2,5,8], U[2,5,8] → B[6,3,0], B[6,3,0] → D[2,5,8], D[2,5,8] → F[2,5,8]
    MoveFace.R: [
      [
        (Face.F, [2, 5, 8]),
        (Face.U, [2, 5, 8]),
        (Face.B, [6, 3, 0]),
        (Face.D, [2, 5, 8]),
      ],
    ],

    // L clockwise (looking from left):
    // F-left-col → D-left-col, D ← B (reversed), B ← U, U ← F
    // F left col: [0,3,6]
    // D left col: [0,3,6]
    // B right col (reversed): [8,5,2] → but from back perspective [2,5,8] maps to left
    //
    // CW L: F[0,3,6] → D[0,3,6]... actually:
    // new U-left ← old F-left: U[0,3,6] ← F[0,3,6]
    // new F-left ← old D-left: F[0,3,6] ← D[0,3,6]
    // new D-left ← old B-right (reversed): D[0,3,6] ← B[8,5,2]
    // new B-right ← old U-left (reversed): B[8,5,2] ← U[0,3,6] → B[2,5,8] ← U[6,3,0]
    //
    // Cycle order (slot[n] ← slot[n-1]):
    // U[0,3,6] ← F[0,3,6], F ← D, D[0,3,6] ← B[8,5,2], B[8,5,2] ← U[0,3,6]
    MoveFace.L: [
      [
        (Face.U, [0, 3, 6]),
        (Face.F, [0, 3, 6]),
        (Face.D, [0, 3, 6]),
        (Face.B, [8, 5, 2]),
      ],
    ],
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Cube) return false;
    for (final f in Face.values) {
      final a = _faces[f]!;
      final b = other._faces[f]!;
      for (var i = 0; i < 9; i++) {
        if (a[i] != b[i]) return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    var h = 0;
    for (final f in Face.values) {
      for (final c in _faces[f]!) {
        h = h * 31 + c.index;
      }
    }
    return h;
  }
}
