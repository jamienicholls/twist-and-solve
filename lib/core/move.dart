/// The face to turn.
enum MoveFace { U, D, L, R, F, B }

/// The rotation direction / amount.
enum MoveRotation {
  /// 90° clockwise.
  cw,

  /// 90° counter-clockwise (prime).
  ccw,

  /// 180° (half turn).
  half,
}

/// A single Rubik's Cube move: a face and a rotation.
class Move {
  final MoveFace face;
  final MoveRotation rotation;

  const Move(this.face, this.rotation);

  /// Returns the inverse of this move.
  Move get inverse {
    switch (rotation) {
      case MoveRotation.cw:
        return Move(face, MoveRotation.ccw);
      case MoveRotation.ccw:
        return Move(face, MoveRotation.cw);
      case MoveRotation.half:
        return Move(face, MoveRotation.half);
    }
  }

  @override
  String toString() {
    final faceName = face.name;
    switch (rotation) {
      case MoveRotation.cw:
        return faceName;
      case MoveRotation.ccw:
        return "$faceName'";
      case MoveRotation.half:
        return '${faceName}2';
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Move && face == other.face && rotation == other.rotation;

  @override
  int get hashCode => Object.hash(face, rotation);
}
