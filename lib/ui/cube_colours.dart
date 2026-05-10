import 'package:flutter/material.dart';
import 'package:twist_and_solve/core/cube_colour.dart';

Color stickerColor(CubeColour colour) {
  switch (colour) {
    case CubeColour.white:
      return Colors.white;
    case CubeColour.yellow:
      return Colors.yellow;
    case CubeColour.red:
      return Colors.red;
    case CubeColour.orange:
      return Colors.orange;
    case CubeColour.blue:
      return Colors.blue;
    case CubeColour.green:
      return Colors.green;
  }
}
