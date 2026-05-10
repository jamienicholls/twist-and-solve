import '../core/cube.dart';
import '../core/cube_validator.dart';

export '../core/cube_validator.dart' show CubeValidationResult;

/// A1 — Validate Cube
///
/// Input:  a [Cube] state
/// Output: [CubeValidationResult] with isValid flag and any error messages
class ValidateCube {
  const ValidateCube._();

  static CubeValidationResult execute(Cube cube) =>
      CubeValidator.validate(cube);
}
