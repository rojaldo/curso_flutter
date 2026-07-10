import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/main.dart';

void main() {
  testWidgets('opens Tetris page from the home menu', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Tetris'));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Tetris'), findsWidgets);
    expect(find.textContaining('Score'), findsOneWidget);
    expect(find.textContaining('Next'), findsOneWidget);
    expect(find.byIcon(Icons.rotate_right), findsOneWidget);
  });
}
