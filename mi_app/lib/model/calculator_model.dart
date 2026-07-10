import 'package:mi_app/model/calculator_data.dart';

enum CalculatorState { init, firstNumber, secondNumber, result }

class Calculator {
  double number1 = 0;
  double number2 = 0;
  String operation = '';
  double result = 0;
  String display = '';

  CalculatorState state = CalculatorState.init;

  Calculator({
    this.number1 = 0,
    this.number2 = 0,
    this.operation = '',
    this.result = 0,
    this.display = '',
    this.state = CalculatorState.init,
  });

  static Calculator fromData(CalculatorData calculatorData) {
    return Calculator(
      number1: calculatorData.number1,
      number2: calculatorData.number2,
      operation: calculatorData.operation,
      result: calculatorData.result,
      display: calculatorData.display,
      state: calculatorData.state,
    );
  }

  String processInput(String input) {
    // check if is number
    if (double.tryParse(input) != null) {
      _processNumber(double.parse(input));
    } else {
      _processSymbol(input);
    }

    return display;
  }

  void _processNumber(double number) {
    switch (state) {
      case CalculatorState.init:
        number1 = number;
        display = number1.toString();
        state = CalculatorState.firstNumber;
        break;
      case CalculatorState.firstNumber:
        number1 = number1 * 10 + number;
        display = number1.toString();
        break;
      case CalculatorState.secondNumber:
        number2 = number2 * 10 + number;
        display = "$number1 $operation $number2";
        break;
      case CalculatorState.result:
        // reset calculator
        _resetCalculator();
        number1 = number;
        display = number1.toString();
        state = CalculatorState.firstNumber;
        break;
    }
  }

  void _processSymbol(String symbol) {
    if (symbol == 'AC') {
      _resetCalculator();
      return;
    }
    switch (state) {
      case CalculatorState.init:
        // do nothing
        break;
      case CalculatorState.firstNumber:
        if (symbol == '+' || symbol == '-' || symbol == '*' || symbol == '/') {
          operation = symbol;
          display = "$number1 $operation";
          state = CalculatorState.secondNumber;
        }
        break;
      case CalculatorState.secondNumber:
        if (symbol == '=') {
          if (_calculateResult()) {
            display = "$number1 $operation $number2 = $result";
          }
          state = CalculatorState.result;
        }
        break;
      case CalculatorState.result:
        if (symbol == '+' || symbol == '-' || symbol == '*' || symbol == '/') {
          var temp = result;
          _resetCalculator();
          number1 = temp;
          operation = symbol;
          display = "$number1 $operation";
          state = CalculatorState.secondNumber;
        }
        break;
    }
  }

  bool _calculateResult() {
    switch (operation) {
      case '+':
        result = number1 + number2;
        if (result >= 1000000) {
          display = 'Error: Overflow';
          return false;
        }
        break;
      case '-':
        result = number1 - number2;
        if (result >= 1000000) {
          display = 'Error: Overflow';
          return false;
        }
        break;
      case '*':
        result = number1 * number2;
        if (result >= 1000000) {
          display = 'Error: Overflow';
          return false;
        }
        break;
      case '/':
        if (number2 != 0) {
          result = number1 / number2;
        } else {
          display = 'Error: Division by zero';
          return false;
        }
        if (result >= 1000000) {
          display = 'Error: Overflow';
          return false;
        }

        break;
    }
    return true;
  }

  void _resetCalculator() {
    number1 = 0;
    number2 = 0;
    operation = '';
    result = 0;
    display = '';
    state = CalculatorState.init;
  }

  CalculatorData toData() {
    return CalculatorData(
      number1: number1,
      number2: number2,
      operation: operation,
      result: result,
      display: display,
      state: state,
    );
  }


}
