import 'dart:async';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:twist_and_solve/application/generate_scramble.dart';
import 'package:twist_and_solve/application/solve_cube.dart';
import 'package:twist_and_solve/application/validate_cube.dart';
import 'package:twist_and_solve/core/cube.dart';
import 'package:twist_and_solve/core/cube_colour.dart';
import 'package:twist_and_solve/core/face.dart';
import 'package:twist_and_solve/ui/cube_colours.dart';
import 'package:twist_and_solve/ui/widgets/cube_layout.dart';
import 'solver_playback_screen.dart';
import 'teaching_mode_screen.dart';
import 'validation_screen.dart';

/// U1 — Cube Editor Screen.
///
/// Lets the user build any cube state by tapping stickers and picking colours,
/// then validate, solve, or enter teaching mode.
class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final Map<Face, List<CubeColour>> _state = _solvedState();
  (Face, int)? _selected;
  List<Move>? _lastScramble;
  bool _isSolving = false;

  static Map<Face, List<CubeColour>> _solvedState() => {
        for (final f in Face.values)
          f: List<CubeColour>.of(Cube.solved().face(f)),
      };

  Cube get _cube => Cube.fromState(_state);

  void _onStickerTap(Face face, int index) {
    setState(() => _selected = (face, index));
  }

  void _onColourPicked(CubeColour colour) {
    final sel = _selected;
    if (sel == null) return;
    setState(() {
      _state[sel.$1]![sel.$2] = colour;
      _lastScramble = null;
    });
  }

  void _scramble() {
    final scrambleMoves = GenerateScramble.executeSolverCompatible();
    final scrambled = Cube.solved().applyMoves(scrambleMoves);
    setState(() {
      for (final f in Face.values) {
        _state[f] = List<CubeColour>.of(scrambled.face(f));
      }
      _selected = null;
      _lastScramble = scrambleMoves;
    });
  }

  void _reset() {
    setState(() {
      final solved = _solvedState();
      for (final f in Face.values) {
        _state[f] = solved[f]!;
      }
      _selected = null;
      _lastScramble = null;
    });
  }

  void _validate() {
    final result = ValidateCube.execute(_cube);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ValidationScreen(result: result)),
    );
  }

  void _solve() => _withSolution(
        (cube, solution) => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                SolverPlaybackScreen(initial: cube, solution: solution),
          ),
        ),
      );

  void _teach() => _withSolution(
        (cube, solution) => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TeachingModeScreen(
              initial: cube,
              breakdown: solution.teachingBreakdown,
            ),
          ),
        ),
      );

  // Runs the solver off the main thread so a slow or unsolvable cube doesn't
  // block the UI or trigger the OS watchdog.
  void _withSolution(void Function(Cube, SolveCubeSuccess) onSuccess) {
    if (_isSolving) return;
    final cube = _cube;
    setState(() => _isSolving = true);

    // Fast path: if this is exactly the last scramble-generated state, solve
    // by inverting that scramble rather than running an expensive search.
    final scrambleHint = _lastScramble;
    if (scrambleHint != null) {
      final hintedResult = SolveCube.executeWithKnownScramble(cube, scrambleHint);
      if (hintedResult case SolveCubeSuccess()) {
        if (!mounted) return;
        setState(() => _isSolving = false);
        onSuccess(cube, hintedResult);
        return;
      }
    }

    // Show solving dialog and run solver in background.
    bool dialogDismissed = false;
    final computeFuture = compute(SolveCube.execute, cube);
    
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SolvingDialog(
        onCancel: () {
          dialogDismissed = true;
          Navigator.pop(context);
        },
      ),
    );

    computeFuture.then((result) {
      if (!mounted || dialogDismissed) {
        if (!mounted) return;
        setState(() => _isSolving = false);
        return;
      }
      // Close the solving dialog
      if (mounted) Navigator.pop(context);
      if (!mounted) return;
      setState(() => _isSolving = false);
      switch (result) {
        case SolveCubeSuccess():
          onSuccess(cube, result);
        case SolveCubeFailure():
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Cannot Solve'),
              content: Text(result.error),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
      }
    }).catchError((e) {
      if (!mounted || dialogDismissed) {
        if (!mounted) return;
        setState(() => _isSolving = false);
        return;
      }
      if (mounted) Navigator.pop(context);
      if (!mounted) return;
      setState(() => _isSolving = false);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Solving Error'),
          content: Text('An unexpected error occurred: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cube Editor')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CubeLayout(
              cube: _cube,
              selectedSticker: _selected,
              onStickerTap: _onStickerTap,
            ),
            const SizedBox(height: 12),
            _SelectedStickerBar(selected: _selected),
            const SizedBox(height: 8),
            _ColourPicker(onPick: _onColourPicked),
            const SizedBox(height: 20),
            _ActionButtons(
              onValidate: _validate,
              onSolve: _isSolving ? null : _solve,
              onTeach: _isSolving ? null : _teach,
              onScramble: _isSolving ? null : _scramble,
              onReset: _isSolving ? null : _reset,
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedStickerBar extends StatelessWidget {
  final (Face, int)? selected;
  const _SelectedStickerBar({required this.selected});

  @override
  Widget build(BuildContext context) {
    final label = selected == null
        ? 'Tap a sticker to select it'
        : 'Selected: ${selected!.$1.name}[${selected!.$2}]';
    return Text(
      label,
      key: const ValueKey('selected_sticker_label'),
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

class _ColourPicker extends StatelessWidget {
  final void Function(CubeColour) onPick;
  const _ColourPicker({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final colour in CubeColour.values)
          GestureDetector(
            key: ValueKey('colour_${colour.name}'),
            onTap: () => onPick(colour),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: stickerColor(colour),
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onValidate;
  final VoidCallback? onSolve;
  final VoidCallback? onTeach;
  final VoidCallback? onScramble;
  final VoidCallback? onReset;

  const _ActionButtons({
    required this.onValidate,
    required this.onSolve,
    required this.onTeach,
    required this.onScramble,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton(
          key: const ValueKey('btn_validate'),
          onPressed: onValidate,
          child: const Text('Validate'),
        ),
        FilledButton(
          key: const ValueKey('btn_solve'),
          onPressed: onSolve,
          child: const Text('Solve'),
        ),
        FilledButton.tonal(
          key: const ValueKey('btn_teach'),
          onPressed: onTeach,
          child: const Text('Teach Me'),
        ),
        OutlinedButton(
          key: const ValueKey('btn_scramble'),
          onPressed: onScramble,
          child: const Text('Scramble'),
        ),
        OutlinedButton(
          key: const ValueKey('btn_reset'),
          onPressed: onReset,
          child: const Text('Reset'),
        ),
      ],
    );
  }
}

/// Dialog showing solving progress with elapsed time and cancel button.
class _SolvingDialog extends StatefulWidget {
  final VoidCallback onCancel;

  const _SolvingDialog({required this.onCancel});

  @override
  State<_SolvingDialog> createState() => _SolvingDialogState();
}

class _SolvingDialogState extends State<_SolvingDialog> {
  late final Stopwatch _stopwatch;
  late final Timer _updateTimer;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    // Update elapsed time every 100ms
    _updateTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  String get _elapsedTime {
    final seconds = (_stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(1);
    return seconds;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Solving...'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Elapsed time: ${_elapsedTime}s'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
