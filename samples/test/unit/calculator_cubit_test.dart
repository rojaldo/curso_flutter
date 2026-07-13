// Tests unitarios del CalculatorCubit.
//
// Verifica la lógica de estado (processInput, AC, encadenamiento) y la
// persistencia con SharedPreferences.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sample_app/ui/features/exercises/view_models/calculator_cubit.dart';

void main() {
  group('CalculatorCubit — lógica de estado', () {
    late CalculatorCubit cubit;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      cubit = CalculatorCubit();
    });

    tearDown(() => cubit.close());

    test('estado inicial de la maquina de estados de la calculadora', () {
      expect(cubit.state.displayText, '');
      expect(cubit.state.step, CalculatorStep.init);
      expect(cubit.state.firstNumber, 0);
      expect(cubit.state.secondNumber, 0);
      expect(cubit.state.result, 0);
      expect(cubit.state.operator, '');
    });

    test('processInput con número muestra el número', () {
      cubit.processInput('5');
      expect(cubit.state.displayText, '5.0');
      expect(cubit.state.firstNumber, 5);
      expect(cubit.state.step, CalculatorStep.firstFigure);
    });

    test('concatenación de dígitos: 1, 2, 3 → 123', () {
      '123'.split('').forEach(cubit.processInput);
      expect(cubit.state.firstNumber, 123);
      expect(cubit.state.displayText, '123.0');
    });

    test('suma: 7 + 5 = 12', () {
      ['7', '+', '5', '='].forEach(cubit.processInput);
      expect(cubit.state.result, 12);
      expect(cubit.state.displayText, '7.0 + 5.0 = 12.0');
      expect(cubit.state.step, CalculatorStep.resolve);
    });

    test('resta: 9 - 4 = 5', () {
      ['9', '-', '4', '='].forEach(cubit.processInput);
      expect(cubit.state.result, 5);
    });

    test('multiplicación: 6 * 7 = 42', () {
      ['6', '*', '7', '='].forEach(cubit.processInput);
      expect(cubit.state.result, 42);
    });

    test('división: 20 / 4 = 5', () {
      ['2', '0', '/', '4', '='].forEach(cubit.processInput);
      expect(cubit.state.result, 5);
    });

    test('división por cero devuelve 0', () {
      ['5', '/', '0', '='].forEach(cubit.processInput);
      expect(cubit.state.result, 0);
    });

    test('AC resetea todo al estado inicial', () {
      ['9', '+', '8', '='].forEach(cubit.processInput);
      expect(cubit.state.result, 17);
      cubit.processInput('AC');
      expect(cubit.state.firstNumber, 0);
      expect(cubit.state.secondNumber, 0);
      expect(cubit.state.result, 0);
      expect(cubit.state.operator, '');
      expect(cubit.state.step, CalculatorStep.init);
      expect(cubit.state.displayText, '');
    });

    test('encadenamiento: 2+3=+10= usa resultado anterior', () {
      ['2', '+', '3', '='].forEach(cubit.processInput);
      expect(cubit.state.result, 5);
      ['+', '1', '0', '='].forEach(cubit.processInput);
      expect(cubit.state.result, 15);
      expect(cubit.state.displayText, '5.0 + 10.0 = 15.0');
    });

    test('operador en init no hace nada', () {
      cubit.processInput('+');
      expect(cubit.state.step, CalculatorStep.init);
    });
  });

  group('CalculatorCubit — persistencia', () {
    test('restaura estado guardado en SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final saved = CalculatorState(
        firstNumber: 42,
        secondNumber: 0,
        result: 0,
        operator: '',
        displayText: '42.0',
        step: CalculatorStep.firstFigure,
      );
      await prefs.setString('calculator_state',
          '{"firstNumber":42.0,"secondNumber":0.0,"result":0.0,"operator":"","displayText":"42.0","step":1}');

      final cubit = CalculatorCubit(prefs: prefs);
      addTearDown(cubit.close);

      expect(cubit.state.firstNumber, 42);
      expect(cubit.state.displayText, '42.0');
      expect(cubit.state.step, CalculatorStep.firstFigure);
    });

    test('persiste estado tras processInput', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final cubit = CalculatorCubit(prefs: prefs);
      addTearDown(cubit.close);

      cubit.processInput('7');
      cubit.processInput('+');
      cubit.processInput('5');
      cubit.processInput('=');

      final raw = prefs.getString('calculator_state');
      expect(raw, isNotNull);
      expect(raw, contains('7.0'));
      expect(raw, contains('5.0'));
      expect(raw, contains('12.0'));
    });

    test('estado corrupto en prefs → queda en estado inicial', () async {
      SharedPreferences.setMockInitialValues({
        'calculator_state': 'not-valid-json',
      });
      final prefs = await SharedPreferences.getInstance();

      final cubit = CalculatorCubit(prefs: prefs);
      addTearDown(cubit.close);

      expect(cubit.state.step, CalculatorStep.init);
      expect(cubit.state.displayText, '');
    });
  });
}