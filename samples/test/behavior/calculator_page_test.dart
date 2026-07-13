// Tests de comportamiento de la página Calculator.
//
// El widget usa BlocBuilder<CalculatorCubit, CalculatorState> para mostrar
// el display. Los tests envuelven la página en BlocProvider con un Cubit
// fresco (prefs: null → no restaura estado previo).
//
// El display está marcado con Key('calculator_display'). Se lee su texto
// directamente con tester.widgetList<Text>(...).first.data.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sample_app/ui/features/exercises/view_models/calculator_cubit.dart';
import 'package:sample_app/ui/features/exercises/views/calculator.dart';

void main() {
  Finder displayKey() => find.byKey(const Key('calculator_display'));

  String displayText(WidgetTester tester) {
    return tester.widgetList<Text>(displayKey()).first.data ?? '';
  }

  Future<void> tapSequence(WidgetTester tester, List<String> labels) async {
    for (final label in labels) {
      await tester.tap(find.text(label).first);
      await tester.pump();
    }
  }

  Widget wrapWithCubit() {
    return BlocProvider<CalculatorCubit>(
      create: (_) => CalculatorCubit(),
      child: const MaterialApp(home: CalculatorExample()),
    );
  }

  testWidgets('muestra "0" al arrancar', (tester) async {
    await tester.pumpWidget(wrapWithCubit());
    expect(displayText(tester), '0');
  });

  testWidgets('pulsar "7" muestra "7.0"', (tester) async {
    await tester.pumpWidget(wrapWithCubit());
    await tester.tap(find.text('7'));
    await tester.pump();
    expect(displayText(tester), '7.0');
  });

  testWidgets('suma: 7 + 5 = 12', (tester) async {
    await tester.pumpWidget(wrapWithCubit());
    await tapSequence(tester, ['7', '+', '5', '=']);
    expect(displayText(tester), '7.0 + 5.0 = 12.0');
  });

  testWidgets('resta: 9 - 4 = 5', (tester) async {
    await tester.pumpWidget(wrapWithCubit());
    await tapSequence(tester, ['9', '-', '4', '=']);
    expect(displayText(tester), '9.0 - 4.0 = 5.0');
  });

  testWidgets('multiplicación: 6 * 7 = 42', (tester) async {
    await tester.pumpWidget(wrapWithCubit());
    await tapSequence(tester, ['6', '*', '7', '=']);
    expect(displayText(tester), '6.0 * 7.0 = 42.0');
  });

  testWidgets('división: 8 / 2 = 4', (tester) async {
    await tester.pumpWidget(wrapWithCubit());
    await tapSequence(tester, ['8', '/', '2', '=']);
    expect(displayText(tester), '8.0 / 2.0 = 4.0');
  });

  testWidgets('AC resetea el display a "0"', (tester) async {
    await tester.pumpWidget(wrapWithCubit());
    await tapSequence(tester, ['7', '+', '5', '=']);
    await tester.tap(find.text('AC').first);
    await tester.pump();
    expect(displayText(tester), '0');
  });

  testWidgets('concatenación de dígitos: 1, 2, 3 → 123', (tester) async {
    await tester.pumpWidget(wrapWithCubit());
    await tapSequence(tester, ['1', '2', '3']);
    expect(displayText(tester), '123.0');
  });

  testWidgets('encadenamiento: 2 + 3 = + 10 = 15', (tester) async {
    await tester.pumpWidget(wrapWithCubit());
    await tapSequence(tester, ['2', '+', '3', '=']);
    await tapSequence(tester, ['+', '1', '0', '=']);
    expect(displayText(tester), '5.0 + 10.0 = 15.0');
  });

  testWidgets('número de varios dígitos: 12 + 30 = 42', (tester) async {
    await tester.pumpWidget(wrapWithCubit());
    await tapSequence(tester, ['1', '2', '+', '3', '0', '=']);
    expect(displayText(tester), '12.0 + 30.0 = 42.0');
  });
}