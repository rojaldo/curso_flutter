enum CalculatorState { init, firstFigure, secondFigure, resolve }

class Calculator {

  double firstNumber = 0;
  double secondNumber = 0;
  double result = 0;
  String operator = '';

  String displayText = '';

  CalculatorState currentState = CalculatorState.init; // can be 'first', 'operator', 'second', 'result'

  Calculator();

  String processInput(String input) {
    // if its number cast it to int  
    if (int.tryParse(input) != null) {
      int number = int.parse(input);
      processNumber(number);
    } else {
      // if its an operation return the operation
      processSymbol(input);
    }      
    
    return displayText;

  }

  void processNumber(int number) {
    var doubleNumber = number.toDouble();
    switch (currentState) {
      case CalculatorState.init:
        firstNumber = doubleNumber;
        currentState = CalculatorState.firstFigure;
        displayText = firstNumber.toString();
        break;
      case CalculatorState.firstFigure:
        firstNumber = firstNumber * 10 + doubleNumber;
        displayText = firstNumber.toString();
        break;
      case CalculatorState.secondFigure:
        secondNumber = secondNumber * 10 + doubleNumber;
        displayText = '$firstNumber $operator $secondNumber'; 
        break;
      case CalculatorState.resolve:
        // reset calculator
        reset();
        firstNumber = doubleNumber;
        currentState = CalculatorState.firstFigure;
        displayText = firstNumber.toString();
        break;
    }
  }

  void processSymbol(String symbol) {
    if (symbol == 'AC') {
      reset();
      displayText = '';
      return;
    } 
    switch (currentState) {
      case CalculatorState.init:
        // do nothing
        break;
      case CalculatorState.firstFigure:
        if (symbol == '+' || symbol == '-' || symbol == '*' || symbol == '/') {
          operator = symbol;
          displayText = '$firstNumber $operator';
          currentState = CalculatorState.secondFigure;
        }
        break;
      case CalculatorState.secondFigure:
        if (symbol == '=') {
          resolve();
          displayText = '$firstNumber $operator $secondNumber = $result';
          currentState = CalculatorState.resolve;
        } 
        break;
      case CalculatorState.resolve:
        if (symbol == '+' || symbol == '-' || symbol == '*' || symbol == '/') {
          double temp = result;
          reset();
          firstNumber = temp;
          operator = symbol;
          displayText = '$firstNumber $operator';
          currentState = CalculatorState.secondFigure;
        }
        break;
    }
  }

  void resolve() {
    switch (operator) {
      case '+':
        result = firstNumber + secondNumber;
        break;
      case '-':
        result = firstNumber - secondNumber;
        break;
      case '*':
        result = firstNumber * secondNumber;
        break;
      case '/':
        if (secondNumber != 0) {
          result = firstNumber / secondNumber; // floating-point division
        } else {
          // handle division by zero
          result = 0; // or throw an error
        }
        break;
    }
  }

  void reset() {
    firstNumber = 0;
    secondNumber = 0;
    result = 0;
    operator = '';
    currentState = CalculatorState.init;
  }
}