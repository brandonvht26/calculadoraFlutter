import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Calculator smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());
    expect(find.text('0'), findsOneWidget);
  });
}
