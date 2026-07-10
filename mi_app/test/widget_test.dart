import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mi_app/main.dart';

void main() {
  testWidgets('permite abrir la calculadora y resolver una suma', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Calculator'));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Calculator'), findsOneWidget);

    for (final input in ['1', '2', '+', '3', '=']) {
      await tester.tap(find.text(input));
      await tester.pump();
    }

    expect(find.text('12.0 + 3.0 = 15.0'), findsOneWidget);
  });
}
