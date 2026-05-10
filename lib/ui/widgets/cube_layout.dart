import 'package:flutter/material.dart';
import 'package:twist_and_solve/core/cube.dart';
import 'package:twist_and_solve/core/face.dart';
import 'package:twist_and_solve/core/teaching_stage.dart';
import '../face_grid.dart';

/// The 2D cross layout used across all D8 screens:
///
///        [ U ]
///  [ L ][ F ][ R ][ B ]
///        [ D ]
///
/// Supports optional sticker tapping (editor), selection highlighting (editor),
/// and teaching-mode highlights from [Highlight].
class CubeLayout extends StatelessWidget {
  final Cube cube;
  final double cellSize;

  /// Called when the user taps a sticker (face + index).
  final void Function(Face face, int index)? onStickerTap;

  /// The currently selected sticker (for the editor).
  final (Face, int)? selectedSticker;

  /// Teaching-mode highlight data.
  final Highlight? highlights;

  const CubeLayout({
    super.key,
    required this.cube,
    this.cellSize = 28,
    this.onStickerTap,
    this.selectedSticker,
    this.highlights,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveCellSize = _effectiveCellSize(constraints.maxWidth);
        final faceWidth = _faceWidth(effectiveCellSize);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(width: faceWidth),
              _face(Face.U, effectiveCellSize),
            ]),
            Row(mainAxisSize: MainAxisSize.min, children: [
              _face(Face.L, effectiveCellSize),
              _face(Face.F, effectiveCellSize),
              _face(Face.R, effectiveCellSize),
              _face(Face.B, effectiveCellSize),
            ]),
            Row(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(width: faceWidth),
              _face(Face.D, effectiveCellSize),
            ]),
          ],
        );
      },
    );
  }

  double _effectiveCellSize(double maxWidth) {
    if (!maxWidth.isFinite) return cellSize;
    // Middle row contains 4 faces: 4 * (3 * (cell + margin*2)).
    final fitByWidth = (maxWidth / 12) - 2;
    return fitByWidth.clamp(12.0, cellSize);
  }

  double _faceWidth(double currentCellSize) => 3 * (currentCellSize + 2);

  Widget _face(Face face, double currentCellSize) {
    final selIndex =
        (selectedSticker != null && selectedSticker!.$1 == face)
            ? selectedSticker!.$2
            : null;

    final hlIndices = highlights == null
        ? null
        : {
            for (final ref in highlights!.stickers)
              if (ref.face == face) ref.row * 3 + ref.col,
          };

    final isActive = highlights?.activeFace == face;

    return LabelledFace(
      cube: cube,
      face: face,
      cellSize: currentCellSize,
      selectedIndex: selIndex,
      highlightedIndices: hlIndices?.isEmpty == true ? null : hlIndices,
      onTap: onStickerTap == null ? null : (i) => onStickerTap!(face, i),
      isActive: isActive,
    );
  }
}
