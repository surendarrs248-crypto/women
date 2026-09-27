// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:women/main.dart';

void main() {
  testWidgets('SAKHI shell starts an SOS session', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('SAKHI'), findsOneWidget);
    expect(find.text('Demo ready'), findsOneWidget);

    await tester.tap(find.text('SOS'));
    await tester.pump();

    expect(find.text('SOS ACTIVE'), findsWidgets);
    expect(find.textContaining('BLR-'), findsWidgets);
  });
}
