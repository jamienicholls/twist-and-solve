import 'cube_colour.dart';
import 'face.dart';

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
