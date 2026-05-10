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
  const GenerateScramble._();

  static List<Move> execute({int? length, Random? random}) =>
      ScrambleGenerator.generate(
        length: length ?? ScrambleGenerator.defaultLength,
        random: random,
      );
}
