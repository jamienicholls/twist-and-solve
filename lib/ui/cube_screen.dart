import 'package:flutter/material.dart';
import 'package:twist_and_solve/core/cube.dart';
import 'package:twist_and_solve/core/face.dart';
import 'package:twist_and_solve/core/move.dart';
import 'face_grid.dart';

/// All 18 moves with their display labels.
const _moves = <(String, Move)>[
  ('U', Move(MoveFace.U, MoveRotation.cw)),
  ("U'", Move(MoveFace.U, MoveRotation.ccw)),
  ('U2', Move(MoveFace.U, MoveRotation.double)),
  ('D', Move(MoveFace.D, MoveRotation.cw)),
  ("D'", Move(MoveFace.D, MoveRotation.ccw)),
  ('D2', Move(MoveFace.D, MoveRotation.double)),
  ('L', Move(MoveFace.L, MoveRotation.cw)),
  ("L'", Move(MoveFace.L, MoveRotation.ccw)),
  ('L2', Move(MoveFace.L, MoveRotation.double)),
  ('R', Move(MoveFace.R, MoveRotation.cw)),
  ("R'", Move(MoveFace.R, MoveRotation.ccw)),
  ('R2', Move(MoveFace.R, MoveRotation.double)),
  ('F', Move(MoveFace.F, MoveRotation.cw)),
  ("F'", Move(MoveFace.F, MoveRotation.ccw)),
  ('F2', Move(MoveFace.F, MoveRotation.double)),
  ('B', Move(MoveFace.B, MoveRotation.cw)),
  ("B'", Move(MoveFace.B, MoveRotation.ccw)),
  ('B2', Move(MoveFace.B, MoveRotation.double)),
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
            _CubeLayout(cube: _cube),
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

/// The 2D cross layout:
///        [ U ]
///  [ L ][ F ][ R ][ B ]
///        [ D ]
class _CubeLayout extends StatelessWidget {
  final Cube cube;

  const _CubeLayout({required this.cube});

  @override
  Widget build(BuildContext context) {
    const cellSize = 28.0;
    // Each face is 3 cells wide (plus margins): 3*(cellSize+2) = 90px per face.
    const faceWidth = 3 * (cellSize + 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: U centred above F (offset by one face width).
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: faceWidth),
            LabelledFace(cube: cube, face: Face.U, cellSize: cellSize),
          ],
        ),
        // Row 2: L F R B side by side.
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LabelledFace(cube: cube, face: Face.L, cellSize: cellSize),
            LabelledFace(cube: cube, face: Face.F, cellSize: cellSize),
            LabelledFace(cube: cube, face: Face.R, cellSize: cellSize),
            LabelledFace(cube: cube, face: Face.B, cellSize: cellSize),
          ],
        ),
        // Row 3: D under F.
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: faceWidth),
            LabelledFace(cube: cube, face: Face.D, cellSize: cellSize),
          ],
        ),
      ],
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
