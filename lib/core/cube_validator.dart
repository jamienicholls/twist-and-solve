import 'cube.dart';
import 'cube_colour.dart';
import 'face.dart';

/// The result of validating a [Cube] state.
class CubeValidationResult {
  /// Whether the cube state is valid.
  final bool isValid;

  /// Human-readable descriptions of each validation failure.
  /// Empty when [isValid] is `true`.
  final List<String> errors;

  const CubeValidationResult._({required this.isValid, required this.errors});

  static const CubeValidationResult valid =
      CubeValidationResult._(isValid: true, errors: []);

  factory CubeValidationResult.invalid(List<String> errors) {
    assert(errors.isNotEmpty);
    return CubeValidationResult._(isValid: false, errors: List.unmodifiable(errors));
  }
}

/// Validates a [Cube] state against the rules defined in spec section 3.4.
///
/// v1 checks:
///   1. Each face's centre sticker (index 4) is a unique colour — centres are
///      fixed on a 3×3 and define the identity of each face.
///   2. Each [CubeColour] appears exactly 9 times across all 54 stickers.
class CubeValidator {
  const CubeValidator._();

  /// Validates [cube] and returns a [CubeValidationResult].
  static CubeValidationResult validate(Cube cube) {
    final errors = <String>[];

    // --- Check 1: all 6 centre stickers must be distinct colours. ---
    // On a standard 3×3, centres cannot move, so each face must have a
    // unique centre colour.
    final centres = <CubeColour>{};
    for (final face in Face.values) {
      final centre = cube.sticker(face, 4);
      if (!centres.add(centre)) {
        errors.add(
          'Centre sticker colour ${centre.name} appears on more than one face. '
          'Each face must have a unique centre colour.',
        );
      }
    }

    // --- Check 2: each colour must appear exactly 9 times. ---
    final counts = <CubeColour, int>{
      for (final c in CubeColour.values) c: 0,
    };
    for (final face in Face.values) {
      for (var i = 0; i < 9; i++) {
        counts[cube.sticker(face, i)] = counts[cube.sticker(face, i)]! + 1;
      }
    }
    for (final entry in counts.entries) {
      if (entry.value != 9) {
        errors.add(
          'Colour ${entry.key.name} appears ${entry.value} time(s); expected 9.',
        );
      }
    }

    return errors.isEmpty
        ? CubeValidationResult.valid
        : CubeValidationResult.invalid(errors);
  }
}
