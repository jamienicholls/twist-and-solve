import 'package:flutter_test/flutter_test.dart';
import 'package:twist_and_solve/main.dart';

void main() {
  testWidgets('App smoke test: renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const TwistAndSolveApp());
    expect(find.text('Twist & Solve'), findsOneWidget);
  });
}
