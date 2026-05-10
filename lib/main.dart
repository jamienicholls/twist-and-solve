import 'package:flutter/material.dart';
import 'package:twist_and_solve/ui/screens/editor_screen.dart';

void main() {
  runApp(const TwistAndSolveApp());
}

class TwistAndSolveApp extends StatelessWidget {
  const TwistAndSolveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twist & Solve',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const EditorScreen(),
    );
  }
}
