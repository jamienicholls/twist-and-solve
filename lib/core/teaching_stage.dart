import 'cube.dart';
import 'face.dart';
import 'move.dart';
import 'solver.dart';

// ---------------------------------------------------------------------------
// Sticker reference
// ---------------------------------------------------------------------------

class StickerRef {
  final Face face;
  final int row;
  final int col;

  const StickerRef(this.face, this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is StickerRef &&
      other.face == face &&
      other.row == row &&
      other.col == col;

  @override
  int get hashCode => Object.hash(face, row, col);

  @override
  String toString() => 'StickerRef($face, $row, $col)';
}

// ---------------------------------------------------------------------------
// Highlight
// ---------------------------------------------------------------------------

class Highlight {
  final Face? activeFace;
  final Set<StickerRef> stickers;

  const Highlight({this.activeFace, required this.stickers});
}

// ---------------------------------------------------------------------------
// TeachingStage
// ---------------------------------------------------------------------------

class TeachingStage {
  final String stageName;
  final String description;
  final String patternHint;
  final List<Move> moves;
  final Cube expectedState;
  final Highlight highlights;

  const TeachingStage({
    required this.stageName,
    required this.description,
    required this.patternHint,
    required this.moves,
    required this.expectedState,
    required this.highlights,
  });
}

// ---------------------------------------------------------------------------
// Per-phase highlight definitions (static final — Set elements override ==)
// ---------------------------------------------------------------------------

final _crossHighlight = Highlight(
  activeFace: Face.U,
  stickers: {
    StickerRef(Face.U, 0, 1),
    StickerRef(Face.U, 1, 0),
    StickerRef(Face.U, 1, 2),
    StickerRef(Face.U, 2, 1),
    StickerRef(Face.F, 0, 1),
    StickerRef(Face.L, 0, 1),
    StickerRef(Face.R, 0, 1),
    StickerRef(Face.B, 0, 1),
  },
);

final _cornersHighlight = Highlight(
  activeFace: Face.U,
  stickers: {
    StickerRef(Face.U, 0, 0),
    StickerRef(Face.U, 0, 1),
    StickerRef(Face.U, 0, 2),
    StickerRef(Face.U, 1, 0),
    StickerRef(Face.U, 1, 1),
    StickerRef(Face.U, 1, 2),
    StickerRef(Face.U, 2, 0),
    StickerRef(Face.U, 2, 1),
    StickerRef(Face.U, 2, 2),
    StickerRef(Face.F, 0, 0),
    StickerRef(Face.F, 0, 2),
    StickerRef(Face.L, 0, 0),
    StickerRef(Face.L, 0, 2),
    StickerRef(Face.R, 0, 0),
    StickerRef(Face.R, 0, 2),
    StickerRef(Face.B, 0, 0),
    StickerRef(Face.B, 0, 2),
  },
);

final _secondLayerHighlight = Highlight(
  activeFace: null,
  stickers: {
    StickerRef(Face.F, 1, 0),
    StickerRef(Face.F, 1, 2),
    StickerRef(Face.L, 1, 0),
    StickerRef(Face.L, 1, 2),
    StickerRef(Face.R, 1, 0),
    StickerRef(Face.R, 1, 2),
    StickerRef(Face.B, 1, 0),
    StickerRef(Face.B, 1, 2),
  },
);

final _ollHighlight = Highlight(
  activeFace: Face.D,
  stickers: {
    for (var r = 0; r < 3; r++)
      for (var c = 0; c < 3; c++) StickerRef(Face.D, r, c),
  },
);

final _pllHighlight = Highlight(
  activeFace: Face.D,
  stickers: {
    for (var r = 0; r < 3; r++)
      for (var c = 0; c < 3; c++) StickerRef(Face.D, r, c),
    for (final f in [Face.F, Face.L, Face.R, Face.B])
      for (var c = 0; c < 3; c++) StickerRef(f, 2, c),
  },
);

// ---------------------------------------------------------------------------
// TeachingBreakdown
// ---------------------------------------------------------------------------

class TeachingBreakdown {
  final List<TeachingStage> stages;

  const TeachingBreakdown(this.stages);

  /// Builds a [TeachingBreakdown] from the [SolveResult] and the cube state
  /// at the moment [CubeSolver.solve] was called.
  static TeachingBreakdown fromSolveResult(Cube initial, SolveResult result) {
    final stages = <TeachingStage>[];
    var state = initial;
    for (final step in result.steps) {
      final after = state.applyMoves(step.moves);
      stages.add(_buildStage(step.phase, step.moves, after));
      state = after;
    }
    return TeachingBreakdown(stages);
  }

  static TeachingStage _buildStage(
    SolvePhase phase,
    List<Move> moves,
    Cube expectedState,
  ) =>
      switch (phase) {
        SolvePhase.cross => TeachingStage(
            stageName: 'White Cross',
            description:
                'Place the four white edge pieces on the top face with matching side colours.',
            patternHint: 'Look for white edge pieces anywhere on the cube.',
            moves: moves,
            expectedState: expectedState,
            highlights: _crossHighlight,
          ),
        SolvePhase.firstLayerCorners => TeachingStage(
            stageName: 'First Layer Corners',
            description:
                'Insert the white corner pieces to complete the first layer.',
            patternHint:
                'Find white corner pieces sitting in the bottom (D) layer.',
            moves: moves,
            expectedState: expectedState,
            highlights: _cornersHighlight,
          ),
        SolvePhase.secondLayer => TeachingStage(
            stageName: 'Second Layer Edges',
            description:
                'Place the four middle-layer edge pieces between the top corners.',
            patternHint:
                'Find edge pieces that have no yellow — they belong in the equator.',
            moves: moves,
            expectedState: expectedState,
            highlights: _secondLayerHighlight,
          ),
        SolvePhase.oll => TeachingStage(
            stageName: 'Orient Last Layer',
            description:
                'Rotate the bottom-layer pieces so all yellow stickers face down.',
            patternHint:
                'Count how many yellow stickers already face down on the D face.',
            moves: moves,
            expectedState: expectedState,
            highlights: _ollHighlight,
          ),
        SolvePhase.pll => TeachingStage(
            stageName: 'Permute Last Layer',
            description:
                'Cycle the bottom-layer pieces into their correct positions to finish the cube.',
            patternHint:
                'Look for a pair of adjacent corners that already match their side centres.',
            moves: moves,
            expectedState: expectedState,
            highlights: _pllHighlight,
          ),
      };
}
