import 'dart:math';

import '../core/move.dart';
import '../core/scramble_generator.dart';

export '../core/move.dart' show Move, MoveFace, MoveRotation;

/// A3 — Generate Scramble
///
/// Input:  optional [length] (defaults to [ScrambleGenerator.defaultLength])
///         optional [random] for deterministic testing
/// Output: a valid scramble as a [List<Move>]
class GenerateScramble {
  /// Length used by the UI scramble action.
  static const int uiDefaultLength = ScrambleGenerator.defaultLength;

  const GenerateScramble._();

  static List<Move> execute({int? length, Random? random}) =>
      ScrambleGenerator.generate(
        length: length ?? ScrambleGenerator.defaultLength,
        random: random,
      );

  /// Returns a scramble that the current v1 solver can solve deterministically.
  ///
  /// In v1 this is equivalent to [execute]; the solve path handles harder
  /// scramble-generated states via a deterministic inverse-scramble fast path.
  static List<Move> executeSolverCompatible({
    int length = uiDefaultLength,
    Random? random,
  }) {
    return execute(length: length, random: random);
  }
}
