import 'package:flutter/material.dart';
import 'package:twist_and_solve/core/cube.dart';
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

  /// Sticker index that is currently selected in the editor (thick white border).
  final int? selectedIndex;

  /// Sticker indices highlighted for teaching mode (amber border).
  final Set<int>? highlightedIndices;

  /// Called with the sticker index when the user taps a sticker.
  final void Function(int)? onTap;

  const FaceGrid({
    super.key,
    required this.cube,
    required this.face,
    this.cellSize = 28,
    this.selectedIndex,
    this.highlightedIndices,
    this.onTap,
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
            final isSelected = selectedIndex == index;
            final isHighlighted = highlightedIndices?.contains(index) ?? false;

            final border = isSelected
                ? Border.all(color: Colors.white, width: 2.5)
                : isHighlighted
                    ? Border.all(color: Colors.amber, width: 2)
                    : Border.all(color: Colors.black54, width: 0.5);

            Widget cell = Container(
              key: ValueKey('sticker_${face.name}_$index'),
              width: cellSize,
              height: cellSize,
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: stickerColor(colour),
                border: border,
              ),
            );

            if (onTap != null) {
              cell = GestureDetector(onTap: () => onTap!(index), child: cell);
            }

            return cell;
          }),
        );
      }),
    );
  }
}

/// The colour name label shown below each face grid (for accessibility).
class FaceLabel extends StatelessWidget {
  final String label;
  final bool isActive;

  const FaceLabel({super.key, required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: isActive ? Colors.amber : null,
      ),
    );
  }
}

/// A face grid with a label centred below it.
class LabelledFace extends StatelessWidget {
  final Cube cube;
  final Face face;
  final double cellSize;
  final int? selectedIndex;
  final Set<int>? highlightedIndices;
  final void Function(int)? onTap;
  final bool isActive;

  const LabelledFace({
    super.key,
    required this.cube,
    required this.face,
    this.cellSize = 28,
    this.selectedIndex,
    this.highlightedIndices,
    this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaceGrid(
          cube: cube,
          face: face,
          cellSize: cellSize,
          selectedIndex: selectedIndex,
          highlightedIndices: highlightedIndices,
          onTap: onTap,
        ),
        FaceLabel(label: face.name, isActive: isActive),
      ],
    );
  }
}
