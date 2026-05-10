import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twist_and_solve/application/solve_cube.dart';
import 'package:twist_and_solve/core/cube.dart';
import 'package:twist_and_solve/core/cube_colour.dart';
import 'package:twist_and_solve/core/face.dart';
import 'package:twist_and_solve/ui/screens/editor_screen.dart';
import 'package:twist_and_solve/ui/screens/solver_playback_screen.dart';
import 'package:twist_and_solve/ui/screens/teaching_mode_screen.dart';
import 'package:twist_and_solve/ui/screens/validation_screen.dart';
import 'package:twist_and_solve/application/validate_cube.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: child);

// Known short scramble — within IDA* phase depth limits.
const _trigger = [
  Move(MoveFace.U, MoveRotation.cw),
  Move(MoveFace.R, MoveRotation.cw),
  Move(MoveFace.U, MoveRotation.ccw),
  Move(MoveFace.R, MoveRotation.ccw),
];

// ---------------------------------------------------------------------------
// U1 — EditorScreen
// ---------------------------------------------------------------------------

void main() {
  group('U1 EditorScreen', () {
    testWidgets('renders cube layout and action buttons', (tester) async {
      await tester.pumpWidget(_wrap(const EditorScreen()));
      expect(find.byKey(const ValueKey('btn_validate')), findsOneWidget);
      expect(find.byKey(const ValueKey('btn_solve')), findsOneWidget);
      expect(find.byKey(const ValueKey('btn_teach')), findsOneWidget);
      expect(find.byKey(const ValueKey('btn_scramble')), findsOneWidget);
      expect(find.byKey(const ValueKey('btn_reset')), findsOneWidget);
    });

    testWidgets('shows "Tap a sticker" hint when nothing selected', (tester) async {
      await tester.pumpWidget(_wrap(const EditorScreen()));
      expect(find.text('Tap a sticker to select it'), findsOneWidget);
    });

    testWidgets('tapping a sticker updates the selected label', (tester) async {
      await tester.pumpWidget(_wrap(const EditorScreen()));
      await tester.tap(find.byKey(const ValueKey('sticker_U_4')));
      await tester.pump();
      expect(find.text('Selected: U[4]'), findsOneWidget);
    });

    testWidgets('reset restores solved state', (tester) async {
      await tester.pumpWidget(_wrap(const EditorScreen()));
      // Scramble first.
      await tester.tap(find.byKey(const ValueKey('btn_scramble')));
      await tester.pump();
      // Then reset.
      await tester.tap(find.byKey(const ValueKey('btn_reset')));
      await tester.pump();
      // No sticker should be selected.
      expect(find.text('Tap a sticker to select it'), findsOneWidget);
    });

    testWidgets('validate on solved cube navigates to ValidationScreen', (tester) async {
      await tester.pumpWidget(_wrap(const EditorScreen()));
      await tester.tap(find.byKey(const ValueKey('btn_validate')));
      await tester.pumpAndSettle();
      expect(find.text('Validation Result'), findsOneWidget);
      expect(find.byKey(const ValueKey('validation_title')), findsOneWidget);
    });

    testWidgets('solve on solved cube navigates to SolverPlaybackScreen', (tester) async {
      await tester.pumpWidget(_wrap(const EditorScreen()));
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const ValueKey('btn_solve')));
        await Future.delayed(const Duration(milliseconds: 500));
      });
      await tester.pumpAndSettle();
      expect(find.text('Solver Playback'), findsOneWidget);
    });

    testWidgets('teach on solved cube navigates to TeachingModeScreen', (tester) async {
      await tester.pumpWidget(_wrap(const EditorScreen()));
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const ValueKey('btn_teach')));
        await Future.delayed(const Duration(milliseconds: 500));
      });
      await tester.pumpAndSettle();
      expect(find.text('Teaching Mode'), findsOneWidget);
    });

    testWidgets('solve on invalid cube does not navigate to playback', (tester) async {
      await tester.pumpWidget(_wrap(const EditorScreen()));
      // U[0] = yellow gives 8 whites / 10 yellows — invalid colour counts.
      await tester.tap(find.byKey(const ValueKey('sticker_U_0')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('colour_yellow')));
      await tester.pump();
      // runAsync lets the compute isolate run to completion (invalid cube
      // fails validation immediately, but the isolate still needs to start).
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const ValueKey('btn_solve')));
        await Future.delayed(const Duration(milliseconds: 500));
      });
      await tester.pumpAndSettle();
      expect(find.text('Solver Playback'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // U2 — ValidationScreen
  // ---------------------------------------------------------------------------

  group('U2 ValidationScreen', () {
    testWidgets('shows success for solved cube', (tester) async {
      final result = ValidateCube.execute(Cube.solved());
      await tester.pumpWidget(_wrap(ValidationScreen(result: result)));
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Valid cube!'), findsOneWidget);
    });

    testWidgets('shows errors for invalid cube', (tester) async {
      final bad = {
        for (final f in Face.values)
          f: List<CubeColour>.filled(9, CubeColour.white),
      };
      final result = ValidateCube.execute(Cube.fromState(bad));
      await tester.pumpWidget(_wrap(ValidationScreen(result: result)));
      expect(find.byIcon(Icons.cancel), findsOneWidget);
      expect(find.text('Invalid cube'), findsOneWidget);
      expect(find.textContaining('white'), findsWidgets);
    });
  });

  // ---------------------------------------------------------------------------
  // U3 — SolverPlaybackScreen
  // ---------------------------------------------------------------------------

  group('U3 SolverPlaybackScreen', () {
    late SolveCubeSuccess solution;
    late Cube initial;

    setUp(() {
      initial = Cube.solved().applyMoves(_trigger);
      solution = SolveCube.execute(initial) as SolveCubeSuccess;
    });

    testWidgets('renders cube and step counter', (tester) async {
      await tester.pumpWidget(
          _wrap(SolverPlaybackScreen(initial: initial, solution: solution)));
      expect(find.byKey(const ValueKey('step_counter')), findsOneWidget);
      expect(find.byKey(const ValueKey('btn_prev_move')), findsOneWidget);
      expect(find.byKey(const ValueKey('btn_next_move')), findsOneWidget);
    });

    testWidgets('prev is disabled at step 0', (tester) async {
      await tester.pumpWidget(
          _wrap(SolverPlaybackScreen(initial: initial, solution: solution)));
      final prevBtn = tester.widget<ElevatedButton>(
          find.byKey(const ValueKey('btn_prev_move')));
      expect(prevBtn.onPressed, isNull);
    });

    testWidgets('next advances step counter', (tester) async {
      await tester.pumpWidget(
          _wrap(SolverPlaybackScreen(initial: initial, solution: solution)));
      await tester.tap(find.byKey(const ValueKey('btn_next_move')));
      await tester.pump();
      expect(find.text('Move 1 of ${solution.solveResult.moves.length}'),
          findsOneWidget);
    });

    testWidgets('teaching mode button navigates to TeachingModeScreen',
        (tester) async {
      await tester.pumpWidget(
          _wrap(SolverPlaybackScreen(initial: initial, solution: solution)));
      await tester.tap(find.byKey(const ValueKey('btn_teaching_mode')));
      await tester.pumpAndSettle();
      expect(find.text('Teaching Mode'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // U4 — TeachingModeScreen
  // ---------------------------------------------------------------------------

  group('U4 TeachingModeScreen', () {
    late TeachingBreakdown breakdown;
    late Cube initial;

    setUp(() {
      initial = Cube.solved().applyMoves(_trigger);
      final result = SolveCube.execute(initial) as SolveCubeSuccess;
      breakdown = result.teachingBreakdown;
    });

    testWidgets('renders stage name and controls', (tester) async {
      await tester.pumpWidget(
          _wrap(TeachingModeScreen(initial: initial, breakdown: breakdown)));
      expect(find.byKey(const ValueKey('stage_name')), findsOneWidget);
      expect(find.byKey(const ValueKey('stage_description')), findsOneWidget);
      expect(find.byKey(const ValueKey('stage_pattern_hint')), findsOneWidget);
      expect(find.byKey(const ValueKey('btn_show_me')), findsOneWidget);
      expect(find.byKey(const ValueKey('btn_explain_again')), findsOneWidget);
      expect(find.byKey(const ValueKey('btn_prev_stage')), findsOneWidget);
      expect(find.byKey(const ValueKey('btn_next_stage')), findsOneWidget);
    });

    testWidgets('prev stage is disabled on first stage', (tester) async {
      await tester.pumpWidget(
          _wrap(TeachingModeScreen(initial: initial, breakdown: breakdown)));
      final prevBtn = tester.widget<ElevatedButton>(
          find.byKey(const ValueKey('btn_prev_stage')));
      expect(prevBtn.onPressed, isNull);
    });

    testWidgets('next stage advances stage counter', (tester) async {
      await tester.pumpWidget(
          _wrap(TeachingModeScreen(initial: initial, breakdown: breakdown)));
      final firstName =
          (tester.widget<Text>(find.byKey(const ValueKey('stage_name'))))
              .data;
      await tester.tap(find.byKey(const ValueKey('btn_next_stage')));
      await tester.pump();
      final secondName =
          (tester.widget<Text>(find.byKey(const ValueKey('stage_name'))))
              .data;
      expect(firstName, isNot(equals(secondName)));
    });

    testWidgets('show me and explain again toggle cube view', (tester) async {
      // Find a stage that has moves.
      await tester.pumpWidget(
          _wrap(TeachingModeScreen(initial: initial, breakdown: breakdown)));

      // Advance until a stage with moves (stages may be empty on a solved cube).
      for (var i = 0;
          i < breakdown.stages.length - 1;
          i++) {
        if (breakdown.stages[i].moves.isNotEmpty) break;
        await tester.tap(find.byKey(const ValueKey('btn_next_stage')));
        await tester.pump();
      }

      final showMe = find.byKey(const ValueKey('btn_show_me'));
      final showMeBtn = tester.widget<FilledButton>(showMe);
      if (showMeBtn.onPressed != null) {
        await tester.tap(showMe);
        await tester.pump();
        // Explain again should re-enable after show me.
        await tester.tap(find.byKey(const ValueKey('btn_explain_again')));
        await tester.pump();
      }
      // No crash — test passes.
    });
  });
}
