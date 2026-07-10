import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/model/calculator_model.dart';

void main() {
  group('Calculator', () {
    late Calculator calculator;

    setUp(() {
      // Configuración antes de cada prueba si es necesario
      calculator = Calculator();
    });

    test('suma números de varios dígitos', () {
      for (final input in ['1', '2', '+', '3', '=']) {
        calculator.processInput(input);
      }

      expect(calculator.display, '12.0 + 3.0 = 15.0');
    });

    test('continúa calculando desde el resultado anterior', () {
      for (final input in ['8', '-', '3', '=', '*', '2', '=']) {
        calculator.processInput(input);
      }

      expect(calculator.display, '5.0 * 2.0 = 10.0');
    });

    test('AC reinicia la calculadora', () {
      for (final input in ['9', '+', '1', 'AC']) {
        calculator.processInput(input);
      }

      expect(calculator.display, '');
      expect(calculator.state, CalculatorState.init);
    });

    test('muestra error al dividir por cero', () {
      for (final input in ['7', '/', '0', '=']) {
        calculator.processInput(input);
      }

      expect(calculator.display, 'Error: Division by zero');
    });

    test('ingresar un operador sin un número previo, lo ignora', () {
      for (final input in ['+', '5', '=']) {
        calculator.processInput(input);
      }

      expect(calculator.display, '5.0');
    });

    test('0/0', () {
      for (final input in ['0', '/', '0', '=']) {
        calculator.processInput(input);
      }

      expect(calculator.display, 'Error: Division by zero');
    });

    test('overflow: no dejo por encima o igual de 1M', () {
      for (final input in [
        '1',
        '0',
        '0',
        '0',
        '0',
        '*',
        '1',
        '0',
        '0',
        '0',
        '0',
        '=',
      ]) {
        calculator.processInput(input);
      }

      expect(calculator.display, 'Error: Overflow');
    });
  });
}
