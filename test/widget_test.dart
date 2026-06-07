// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:kwartako/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KwartaKoApp());

    // Verify that our Splash Screen is displayed with the title 'KwartaKo' and the tagline
    expect(find.text('KwartaKo'), findsOneWidget);
    expect(find.text('Track today. Improve next week.'), findsOneWidget);
  });
}
