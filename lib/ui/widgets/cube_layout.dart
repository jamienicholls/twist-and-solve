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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(width: _faceWidth),
          _face(Face.U),
        ]),
        Row(mainAxisSize: MainAxisSize.min, children: [
          _face(Face.L),
          _face(Face.F),
          _face(Face.R),
          _face(Face.B),
        ]),
        Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(width: _faceWidth),
          _face(Face.D),
        ]),
      ],
    );
  }

  double get _faceWidth => 3 * (cellSize + 2);

  Widget _face(Face face) {
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
      cellSize: cellSize,
      selectedIndex: selIndex,
      highlightedIndices: hlIndices?.isEmpty == true ? null : hlIndices,
      onTap: onStickerTap == null ? null : (i) => onStickerTap!(face, i),
      isActive: isActive,
    );
  }
}
