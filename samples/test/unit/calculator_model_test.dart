// Tests unitarios del modelo Calculator.
//
// Cubren la máquina de estados (init → firstFigure → secondFigure → resolve),
// las cuatro operaciones, el encadenamiento de resultados y la división por
// cero (que el modelo decide devolver 0 en lugar de lanzar).

import 'package:flutter_test/flutter_test.dart';
import 'package:sample_app/model/calculator_model.dart';

void main() {
  late Calculator calc;

  setUp(() {
    calc = Calculator();
  });

  group('Estados iniciales', () {
    test('recién construido muestra texto vacío y estado init', () {
      expect(calc.displayText, '');
      expect(calc.currentState, CalculatorState.init);
      expect(calc.firstNumber, 0);
      expect(calc.secondNumber, 0);
      expect(calc.result, 0);
      expect(calc.operator, '');
    });
  });

  group('Entrada de números (processNumber)', () {
    test('primer número pasa de init a firstFigure', () {
      calc.processInput('5');
      expect(calc.currentState, CalculatorState.firstFigure);
      expect(calc.firstNumber, 5);
      expect(calc.displayText, '5.0');
    });

    test('segundo dígito concatena (firstNumber * 10 + n)', () {
      calc.processInput('5');
      calc.processInput('3');
      expect(calc.firstNumber, 53);
      expect(calc.displayText, '53.0');
    });

    test('tercer dígito sigue concatenando', () {
      '123'.split('').forEach(calc.processInput);
      expect(calc.firstNumber, 123);
    });
  });

  group('Operaciones básicas (resolve)', () {
    test('suma: 2 + 3 = 5', () {
      ['2', '+', '3', '='].forEach(calc.processInput);
      expect(calc.result, 5);
      expect(calc.displayText, '2.0 + 3.0 = 5.0');
      expect(calc.currentState, CalculatorState.resolve);
    });

    test('resta: 10 - 4 = 6', () {
      ['1', '0', '-', '4', '='].forEach(calc.processInput);
      expect(calc.result, 6);
      expect(calc.displayText, '10.0 - 4.0 = 6.0');
    });

    test('multiplicación: 7 * 6 = 42', () {
      ['7', '*', '6', '='].forEach(calc.processInput);
      expect(calc.result, 42);
    });

    test('división: 20 / 4 = 5', () {
      ['2', '0', '/', '4', '='].forEach(calc.processInput);
      expect(calc.result, 5);
    });

    test('división por cero devuelve 0 (decisión del modelo)', () {
      ['5', '/', '0', '='].forEach(calc.processInput);
      expect(calc.result, 0);
    });
  });

  group('Reset (AC)', () {
    test('AC borra todo y vuelve a init', () {
      ['9', '+', '8', '='].forEach(calc.processInput);
      expect(calc.result, 17);
      calc.processInput('AC');
      expect(calc.firstNumber, 0);
      expect(calc.secondNumber, 0);
      expect(calc.result, 0);
      expect(calc.operator, '');
      expect(calc.currentState, CalculatorState.init);
      expect(calc.displayText, '');
    });
  });

  group('Encadenamiento tras resolver', () {
    test('tras "=" pulsar operador usa el resultado como primer número', () {
      ['2', '+', '3', '='].forEach(calc.processInput);
      expect(calc.result, 5);
      calc.processInput('+');
      expect(calc.firstNumber, 5);
      expect(calc.operator, '+');
      expect(calc.currentState, CalculatorState.secondFigure);
      expect(calc.displayText, '5.0 +');
    });

    test('tras "=" pulsar dígito resetea y empieza nuevo cálculo', () {
      ['2', '+', '3', '='].forEach(calc.processInput);
      calc.processInput('7');
      expect(calc.firstNumber, 7);
      expect(calc.secondNumber, 0);
      expect(calc.currentState, CalculatorState.firstFigure);
      expect(calc.displayText, '7.0');
    });
  });

  group('Operadores inválidos / fuera de estado', () {
    test('pulsar operador en init no hace nada', () {
      calc.processInput('+');
      expect(calc.currentState, CalculatorState.init);
      expect(calc.operator, '');
    });

    test('pulsar "=" en secondFigure sin operador no resuelve', () {
      calc.processInput('5');
      calc.processInput('=');
      expect(calc.currentState, CalculatorState.firstFigure);
      expect(calc.result, 0);
    });

    test('pulsar símbolo desconocido se ignora', () {
      calc.processInput('5');
      calc.processInput('%');
      expect(calc.firstNumber, 5);
      expect(calc.operator, '');
    });
  });

  group('displayText refleja cada paso', () {
    test('primer número muestra solo el número', () {
      calc.processInput('8');
      expect(calc.displayText, '8.0');
    });

    test('tras operador muestra "n op"', () {
      ['8', '+'].forEach(calc.processInput);
      expect(calc.displayText, '8.0 +');
    });

    test('con segundo número muestra "n op m"', () {
      ['8', '+', '2'].forEach(calc.processInput);
      expect(calc.displayText, '8.0 + 2.0');
    });

    test('tras "=" muestra "n op m = r"', () {
      ['8', '+', '2', '='].forEach(calc.processInput);
      expect(calc.displayText, '8.0 + 2.0 = 10.0');
    });
  });
}