import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:twist_and_solve/application/generate_scramble.dart';
import 'package:twist_and_solve/core/cube.dart';
import 'package:twist_and_solve/core/scramble_generator.dart';

void main() {
  group('A3 — GenerateScramble', () {
    test('returns default length when no argument given', () {
      final moves = GenerateScramble.execute(random: Random(0));
      expect(moves, hasLength(ScrambleGenerator.defaultLength));
    });

    test('returns requested length', () {
      final moves = GenerateScramble.execute(length: 10, random: Random(0));
      expect(moves, hasLength(10));
    });

    test('all moves are valid Move instances', () {
      final moves = GenerateScramble.execute(length: 15, random: Random(42));
      for (final m in moves) {
        expect(MoveFace.values, contains(m.face));
        expect(MoveRotation.values, contains(m.rotation));
      }
    });

    test('no consecutive same-face moves', () {
      final moves = GenerateScramble.execute(length: 20, random: Random(1));
      for (var i = 1; i < moves.length; i++) {
        expect(moves[i].face, isNot(equals(moves[i - 1].face)));
      }
    });

    test('is deterministic for the same seed', () {
      final a = GenerateScramble.execute(length: 20, random: Random(7));
      final b = GenerateScramble.execute(length: 20, random: Random(7));
      expect(a.map((m) => '${m.face}${m.rotation}').toList(),
          equals(b.map((m) => '${m.face}${m.rotation}').toList()));
    });

    test('scrambling a solved cube yields a non-solved state', () {
      final moves = GenerateScramble.execute(length: 10, random: Random(0));
      final scrambled = Cube.solved().applyMoves(moves);
      expect(scrambled, isNot(equals(Cube.solved())));
    });

    test('solver-compatible scramble can be solved by the current solver', () {
      for (var seed = 0; seed < 5; seed++) {
        final moves = GenerateScramble.executeSolverCompatible(
          length: 2,
          random: Random(seed),
        );
        final scrambled = Cube.solved().applyMoves(moves);
        expect(scrambled, isNot(equals(Cube.solved())));
      }
    });

    test('solver-compatible scramble keeps requested length', () {
      final moves =
          GenerateScramble.executeSolverCompatible(length: 8, random: Random(2));
      expect(moves.length, 8);
    });
  });
}
