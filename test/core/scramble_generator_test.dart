import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:twist_and_solve/core/cube.dart';
import 'package:twist_and_solve/core/move.dart';
import 'package:twist_and_solve/core/scramble_generator.dart';
import 'package:twist_and_solve/core/solver.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Syntactic validity
  // ---------------------------------------------------------------------------

  group('Syntactic validity', () {
    test('generates the requested number of moves (default 20)', () {
      final scramble = ScrambleGenerator.generate(random: Random(42));
      expect(scramble, hasLength(20));
    });

    test('generates the requested number of moves (custom length)', () {
      for (final len in [1, 10, 25, 30]) {
        final scramble = ScrambleGenerator.generate(length: len, random: Random(0));
        expect(scramble, hasLength(len), reason: 'length=$len');
      }
    });

    test('all moves use valid MoveFace and MoveRotation values', () {
      final scramble = ScrambleGenerator.generate(random: Random(7));
      for (final move in scramble) {
        expect(MoveFace.values, contains(move.face));
        expect(MoveRotation.values, contains(move.rotation));
      }
    });

    test('no same-face repeats', () {
      for (var seed = 0; seed < 20; seed++) {
        final scramble =
            ScrambleGenerator.generate(length: 25, random: Random(seed));
        for (var i = 1; i < scramble.length; i++) {
          expect(scramble[i].face, isNot(scramble[i - 1].face),
              reason: 'seed=$seed, index=$i: consecutive same face');
        }
      }
    });

    test('no immediate inverse moves', () {
      for (var seed = 0; seed < 20; seed++) {
        final scramble =
            ScrambleGenerator.generate(length: 25, random: Random(seed));
        for (var i = 1; i < scramble.length; i++) {
          // Same-face is already forbidden, so inverses on the same face
          // cannot occur. This test is a belt-and-braces check.
          final prev = scramble[i - 1];
          final curr = scramble[i];
          final isInverse = curr.face == prev.face &&
              curr.rotation == prev.inverse.rotation;
          expect(isInverse, isFalse,
              reason: 'seed=$seed, index=$i: immediate inverse');
        }
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Scrambles a solved cube
  // ---------------------------------------------------------------------------

  group('Scrambling', () {
    test('scrambling a solved cube yields a non-solved state', () {
      // Run several seeds to reduce false-negative probability.
      for (var seed = 0; seed < 10; seed++) {
        final moves = ScrambleGenerator.generate(random: Random(seed));
        final scrambled = Cube.solved().applyMoves(moves);
        expect(scrambled, isNot(equals(Cube.solved())),
            reason: 'seed=$seed should produce a non-solved cube');
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Solver can solve scrambled cube
  // ---------------------------------------------------------------------------

  group('Solver integration', () {
    test('solver solves a generated scramble', () {
      // Use short scrambles (length 2) so the phase IDA* finds solutions quickly.
      // A 2-move scramble's inverse is always within the solver's search depth.
      for (var seed = 0; seed < 5; seed++) {
        final moves = ScrambleGenerator.generate(length: 2, random: Random(seed));
        final scrambled = Cube.solved().applyMoves(moves);
        final result = CubeSolver.solve(scrambled);
        expect(scrambled.applyMoves(result.moves), equals(Cube.solved()),
            reason: 'seed=$seed: solver did not return to solved');
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Edge cases
  // ---------------------------------------------------------------------------

  group('Edge cases', () {
    test('length 1 produces exactly one move', () {
      final scramble = ScrambleGenerator.generate(length: 1, random: Random(0));
      expect(scramble, hasLength(1));
    });

    test('throws ArgumentError for length < 1', () {
      expect(
        () => ScrambleGenerator.generate(length: 0),
        throwsArgumentError,
      );
    });
  });
}
