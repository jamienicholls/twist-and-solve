import 'package:flutter/material.dart';
import 'package:twist_and_solve/application/solve_cube.dart';
import 'package:twist_and_solve/core/cube.dart';
import 'package:twist_and_solve/ui/widgets/cube_layout.dart';
import 'package:twist_and_solve/ui/widgets/move_label.dart';
import 'teaching_mode_screen.dart';

/// U3 — Solver Playback Screen.
///
/// Steps through the flat move list from [SolveCubeSuccess], updating the
/// cube view with each move.
class SolverPlaybackScreen extends StatefulWidget {
  final Cube initial;
  final SolveCubeSuccess solution;

  const SolverPlaybackScreen({
    super.key,
    required this.initial,
    required this.solution,
  });

  @override
  State<SolverPlaybackScreen> createState() => _SolverPlaybackScreenState();
}

class _SolverPlaybackScreenState extends State<SolverPlaybackScreen> {
  int _moveIndex = 0;
  late final List<Cube> _cubeStates;

  @override
  void initState() {
    super.initState();
    // Precompute cube state after every move so we can navigate instantly.
    final moves = widget.solution.solveResult.moves;
    _cubeStates = [widget.initial];
    var state = widget.initial;
    for (final m in moves) {
      state = state.applyMove(m);
      _cubeStates.add(state);
    }
  }

  List<Move> get _allMoves => widget.solution.solveResult.moves;
  int get _totalMoves => _allMoves.length;
  Cube get _currentCube => _cubeStates[_moveIndex];

  void _prev() {
    if (_moveIndex > 0) setState(() => _moveIndex--);
  }

  void _next() {
    if (_moveIndex < _totalMoves) setState(() => _moveIndex++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solver Playback'),
        actions: [
          IconButton(
            key: const ValueKey('btn_teaching_mode'),
            tooltip: 'Teaching',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TeachingModeScreen(
                  initial: widget.initial,
                  breakdown: widget.solution.teachingBreakdown,
                ),
              ),
            ),
            icon: const Icon(Icons.school),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CubeLayout(cube: _currentCube),
                  const SizedBox(height: 16),
                  Text(
                    _totalMoves == 0
                        ? 'Already solved!'
                        : 'Move $_moveIndex of $_totalMoves',
                    key: const ValueKey('step_counter'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _MoveList(
                    moves: _allMoves,
                    currentIndex: _moveIndex,
                  ),
                ],
              ),
            ),
          ),
          _StepControls(
            onPrev: _moveIndex > 0 ? _prev : null,
            onNext: _moveIndex < _totalMoves ? _next : null,
          ),
        ],
      ),
    );
  }
}

class _MoveList extends StatelessWidget {
  final List<Move> moves;
  final int currentIndex;

  const _MoveList({required this.moves, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    if (moves.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: [
        for (var i = 0; i < moves.length; i++)
          Container(
            key: ValueKey('move_chip_$i'),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: i < currentIndex
                  ? Colors.green.shade100
                  : i == currentIndex
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
              border: Border.all(
                color: i == currentIndex
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black26,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              moveLabel(moves[i]),
              style: TextStyle(
                fontWeight:
                    i == currentIndex ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }
}

class _StepControls extends StatelessWidget {
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _StepControls({required this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: Theme.of(context).colorScheme.surface,
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: 12,
        runSpacing: 8,
        children: [
          ElevatedButton.icon(
            key: const ValueKey('btn_prev_move'),
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left),
            label: const Text('Prev'),
          ),
          ElevatedButton.icon(
            key: const ValueKey('btn_next_move'),
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
            label: const Text('Next'),
            iconAlignment: IconAlignment.end,
          ),
        ],
      ),
    );
  }
}
