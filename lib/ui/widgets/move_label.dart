import 'package:twist_and_solve/core/move.dart';

String moveLabel(Move m) => switch (m.rotation) {
      MoveRotation.cw => m.face.name,
      MoveRotation.ccw => "${m.face.name}'",
      MoveRotation.half => '${m.face.name}2',
    };
