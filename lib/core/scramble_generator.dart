import 'dart:math';

import 'move.dart';

/// Generates random Rubik's Cube scramble sequences.
///
/// Constraints (spec D6):
/// - No immediate inverses (e.g. R then R').
/// - No same-face repeats (e.g. R then R2).
/// - Configurable length (default 20).
/// - Uses [MoveFace] + [MoveRotation].
class ScrambleGenerator {
  static const int defaultLength = 20;

  const ScrambleGenerator._();

  /// Generates a scramble of [length] moves using [random] as the RNG.
  ///
  /// Throws [ArgumentError] if [length] < 1.
  static List<Move> generate({int length = defaultLength, Random? random}) {
    if (length < 1) {
      throw ArgumentError.value(length, 'length', 'Must be at least 1.');
    }

    final rng = random ?? Random();
    final scramble = <Move>[];
    MoveFace? lastFace;

    while (scramble.length < length) {
      // Pick a face different from the last one used.
      MoveFace face;
      do {
        face = MoveFace.values[rng.nextInt(MoveFace.values.length)];
      } while (face == lastFace);

      // Pick any rotation — but if the last move was on the same face this
      // could never happen (guarded above). Still, ensure no inverse or
      // same-rotation repeat with the very last move.
      MoveRotation rotation;
      if (scramble.isNotEmpty && scramble.last.face == face) {
        // This branch is unreachable given the face guard above, but kept
        // for defensive correctness.
        final forbidden = {
          scramble.last.rotation,
          scramble.last.rotation == MoveRotation.cw
              ? MoveRotation.ccw
              : MoveRotation.cw,
        };
        final allowed = MoveRotation.values
            .where((r) => !forbidden.contains(r))
            .toList();
        rotation = allowed[rng.nextInt(allowed.length)];
      } else {
        rotation =
            MoveRotation.values[rng.nextInt(MoveRotation.values.length)];
      }

      scramble.add(Move(face, rotation));
      lastFace = face;
    }

    return scramble;
  }
}
