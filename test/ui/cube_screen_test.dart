import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twist_and_solve/core/cube.dart';
import 'package:twist_and_solve/core/cube_colour.dart';
import 'package:twist_and_solve/core/face.dart';
import 'package:twist_and_solve/core/move.dart';
import 'package:twist_and_solve/ui/cube_colours.dart';
import 'package:twist_and_solve/ui/cube_screen.dart';

/// Pumps [CubeScreen] inside a [MaterialApp].
Future<void> pumpCubeScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(home: CubeScreen()),
  );
}

/// Returns the [BoxDecoration] color of the sticker identified by [key].
Color stickerColourAt(WidgetTester tester, String key) {
  final container = tester.widget<Container>(find.byKey(ValueKey(key)));
  return (container.decoration! as BoxDecoration).color!;
}

void main() {
  // ---------------------------------------------------------------------------
  // Initial state
  // ---------------------------------------------------------------------------

  group('Initial state', () {
    testWidgets('renders 6 face grids in solved colours', (tester) async {
      await pumpCubeScreen(tester);

      // Each face centre (index 4) should be its solved colour.
      expect(stickerColourAt(tester, 'sticker_U_4'), stickerColor(CubeColour.white));
      expect(stickerColourAt(tester, 'sticker_D_4'), stickerColor(CubeColour.yellow));
      expect(stickerColourAt(tester, 'sticker_F_4'), stickerColor(CubeColour.green));
      expect(stickerColourAt(tester, 'sticker_B_4'), stickerColor(CubeColour.blue));
      expect(stickerColourAt(tester, 'sticker_L_4'), stickerColor(CubeColour.orange));
      expect(stickerColourAt(tester, 'sticker_R_4'), stickerColor(CubeColour.red));
    });

    testWidgets('18 move buttons are present', (tester) async {
      await pumpCubeScreen(tester);

      for (final label in [
        'U', "U'", 'U2', 'D', "D'", 'D2',
        'L', "L'", 'L2', 'R', "R'", 'R2',
        'F', "F'", 'F2', 'B', "B'", 'B2',
      ]) {
        expect(find.byKey(ValueKey('btn_$label')), findsOneWidget,
            reason: 'Button for $label should exist');
      }
    });

    testWidgets('Reset button is present', (tester) async {
      await pumpCubeScreen(tester);
      expect(find.byKey(const ValueKey('btn_reset')), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // U move button
  // ---------------------------------------------------------------------------

  group('U move button', () {
    testWidgets('U CW: F top row becomes orange (was L top)', (tester) async {
      await pumpCubeScreen(tester);
      await tester.tap(find.byKey(const ValueKey('btn_U')));
      await tester.pump();

      // After U CW: new F-top ← old L-top (orange)
      expect(stickerColourAt(tester, 'sticker_F_0'), Colors.orange);
      expect(stickerColourAt(tester, 'sticker_F_1'), Colors.orange);
      expect(stickerColourAt(tester, 'sticker_F_2'), Colors.orange);
    });

    testWidgets("U CW then U' returns to solved", (tester) async {
      await pumpCubeScreen(tester);
      await tester.tap(find.byKey(const ValueKey('btn_U')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey("btn_U'")));
      await tester.pump();

      // Back to green on F top
      expect(stickerColourAt(tester, 'sticker_F_0'), Colors.green);
      expect(stickerColourAt(tester, 'sticker_F_1'), Colors.green);
      expect(stickerColourAt(tester, 'sticker_F_2'), Colors.green);
    });

    testWidgets('U2 matches domain-layer applyMove(Move(U, double))', (tester) async {
      await pumpCubeScreen(tester);
      await tester.tap(find.byKey(const ValueKey('btn_U2')));
      await tester.pump();

      final expected = Cube.solved().applyMove(Move(MoveFace.U, MoveRotation.half));

      for (final face in Face.values) {
        for (var i = 0; i < 9; i++) {
          final expectedColor = stickerColor(expected.sticker(face, i));
          final actual = stickerColourAt(tester, 'sticker_${face.name}_$i');
          expect(actual, expectedColor,
              reason: 'Face ${face.name} index $i after U2');
        }
      }
    });

    testWidgets("U' matches domain-layer applyMove(Move(U, ccw))", (tester) async {
      await pumpCubeScreen(tester);
      await tester.tap(find.byKey(const ValueKey("btn_U'")));
      await tester.pump();

      final expected = Cube.solved().applyMove(Move(MoveFace.U, MoveRotation.ccw));

      for (final face in Face.values) {
        for (var i = 0; i < 9; i++) {
          final expectedColor = stickerColor(expected.sticker(face, i));
          final actual = stickerColourAt(tester, 'sticker_${face.name}_$i');
          expect(actual, expectedColor,
              reason: "Face ${face.name} index $i after U'");
        }
      }
    });
  });

  // ---------------------------------------------------------------------------
  // Reset button
  // ---------------------------------------------------------------------------

  group('Reset button', () {
    testWidgets('resets to solved after a move', (tester) async {
      await pumpCubeScreen(tester);
      await tester.tap(find.byKey(const ValueKey('btn_R')));
      await tester.pump();

      // Verify it's changed (U right col should be green).
      expect(stickerColourAt(tester, 'sticker_U_2'), Colors.green);

      await tester.tap(find.byKey(const ValueKey('btn_reset')));
      await tester.pump();

      // All faces restored to solved colours.
      expect(stickerColourAt(tester, 'sticker_U_2'), Colors.white);
      expect(stickerColourAt(tester, 'sticker_F_0'), Colors.green);
      expect(stickerColourAt(tester, 'sticker_R_4'), Colors.red);
    });

    testWidgets('resets after multiple moves', (tester) async {
      await pumpCubeScreen(tester);
      await tester.tap(find.byKey(const ValueKey('btn_R')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('btn_U')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey("btn_F'")));
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('btn_reset')));
      await tester.pump();

      for (final face in Face.values) {
        for (var i = 0; i < 9; i++) {
          final expectedColor = stickerColor(Cube.solved().sticker(face, i));
          expect(
            stickerColourAt(tester, 'sticker_${face.name}_$i'),
            expectedColor,
            reason: 'Face ${face.name}[$i] should be solved after reset',
          );
        }
      }
    });
  });

  // ---------------------------------------------------------------------------
  // UI rebuilds
  // ---------------------------------------------------------------------------

  group('UI rebuilds on move', () {
    testWidgets('face changes after each move button tap', (tester) async {
      await pumpCubeScreen(tester);

      final beforeF0 = stickerColourAt(tester, 'sticker_F_0');
      await tester.tap(find.byKey(const ValueKey('btn_U')));
      await tester.pump();
      final afterF0 = stickerColourAt(tester, 'sticker_F_0');

      expect(afterF0, isNot(equals(beforeF0)));
    });
  });

  // ---------------------------------------------------------------------------
  // Face layout matches domain for arbitrary sequence
  // ---------------------------------------------------------------------------

  group('Face layout matches domain layer', () {
    testWidgets('after R U R\' U\' the UI matches domain applyMoves', (tester) async {
      await pumpCubeScreen(tester);

      final sequence = [
        const ValueKey('btn_R'),
        const ValueKey('btn_U'),
        const ValueKey("btn_R'"),
        const ValueKey("btn_U'"),
      ];

      for (final key in sequence) {
        await tester.tap(find.byKey(key));
        await tester.pump();
      }

      final expected = Cube.solved().applyMoves([
        Move(MoveFace.R, MoveRotation.cw),
        Move(MoveFace.U, MoveRotation.cw),
        Move(MoveFace.R, MoveRotation.ccw),
        Move(MoveFace.U, MoveRotation.ccw),
      ]);

      for (final face in Face.values) {
        for (var i = 0; i < 9; i++) {
          final expectedColor = stickerColor(expected.sticker(face, i));
          final actual = stickerColourAt(tester, 'sticker_${face.name}_$i');
          expect(actual, expectedColor,
              reason: "Face ${face.name}[$i] after R U R' U'");
        }
      }
    });
  });
}
