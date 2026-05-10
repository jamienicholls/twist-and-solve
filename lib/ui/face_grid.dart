import 'package:flutter/material.dart';
import 'package:twist_and_solve/core/cube.dart';
import 'package:twist_and_solve/core/cube_colour.dart';
import 'package:twist_and_solve/core/face.dart';
import 'cube_colours.dart';

/// Renders a single face of the cube as a 3×3 grid of coloured squares.
///
/// Each sticker is given a [ValueKey] of the form `'sticker_<face>_<index>'`
/// to allow widget tests to locate and inspect individual stickers.
class FaceGrid extends StatelessWidget {
  final Cube cube;
  final Face face;
  final double cellSize;

  const FaceGrid({
    super.key,
    required this.cube,
    required this.face,
    this.cellSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (row) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (col) {
            final index = row * 3 + col;
            final colour = cube.sticker(face, index);
            return Container(
              key: ValueKey('sticker_${face.name}_$index'),
              width: cellSize,
              height: cellSize,
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: stickerColor(colour),
                border: Border.all(color: Colors.black54, width: 0.5),
              ),
            );
          }),
        );
      }),
    );
  }
}

/// The colour name label shown below each face grid (for accessibility).
class FaceLabel extends StatelessWidget {
  final String label;
  const FaceLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold));
  }
}

/// A face grid with a label centred below it.
class LabelledFace extends StatelessWidget {
  final Cube cube;
  final Face face;
  final double cellSize;

  const LabelledFace({
    super.key,
    required this.cube,
    required this.face,
    this.cellSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaceGrid(cube: cube, face: face, cellSize: cellSize),
        FaceLabel(label: face.name),
      ],
    );
  }
}
