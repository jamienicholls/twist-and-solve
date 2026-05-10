import 'package:flutter/material.dart';
import 'package:twist_and_solve/core/cube.dart';
import 'package:twist_and_solve/core/move.dart';
import 'widgets/cube_layout.dart';

/// All 18 moves with their display labels.
const _moves = <(String, Move)>[
  ('U', Move(MoveFace.U, MoveRotation.cw)),
  ("U'", Move(MoveFace.U, MoveRotation.ccw)),
  ('U2', Move(MoveFace.U, MoveRotation.half)),
  ('D', Move(MoveFace.D, MoveRotation.cw)),
  ("D'", Move(MoveFace.D, MoveRotation.ccw)),
  ('D2', Move(MoveFace.D, MoveRotation.half)),
  ('L', Move(MoveFace.L, MoveRotation.cw)),
  ("L'", Move(MoveFace.L, MoveRotation.ccw)),
  ('L2', Move(MoveFace.L, MoveRotation.half)),
  ('R', Move(MoveFace.R, MoveRotation.cw)),
  ("R'", Move(MoveFace.R, MoveRotation.ccw)),
  ('R2', Move(MoveFace.R, MoveRotation.half)),
  ('F', Move(MoveFace.F, MoveRotation.cw)),
  ("F'", Move(MoveFace.F, MoveRotation.ccw)),
  ('F2', Move(MoveFace.F, MoveRotation.half)),
  ('B', Move(MoveFace.B, MoveRotation.cw)),
  ("B'", Move(MoveFace.B, MoveRotation.ccw)),
  ('B2', Move(MoveFace.B, MoveRotation.half)),
];

class CubeScreen extends StatefulWidget {
  const CubeScreen({super.key});

  @override
  State<CubeScreen> createState() => _CubeScreenState();
}

class _CubeScreenState extends State<CubeScreen> {
  Cube _cube = Cube.solved();

  void _applyMove(Move move) {
    setState(() {
      _cube = _cube.applyMove(move);
    });
  }

  void _reset() {
    setState(() {
      _cube = Cube.solved();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Twist & Solve')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CubeLayout(cube: _cube),
            const SizedBox(height: 24),
            _MoveButtons(onMove: _applyMove),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const ValueKey('btn_reset'),
              onPressed: _reset,
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wrap of buttons for all 18 moves.
class _MoveButtons extends StatelessWidget {
  final void Function(Move) onMove;

  const _MoveButtons({required this.onMove});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final (label, move) in _moves)
          ElevatedButton(
            key: ValueKey('btn_$label'),
            onPressed: () => onMove(move),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: const Size(40, 32),
            ),
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
      ],
    );
  }
}
