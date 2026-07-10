import 'package:flutter/foundation.dart';
import 'package:mi_app/model/calculator_data.dart';

class CalculatorProvider extends ChangeNotifier {
  final CalculatorData _calculatorData = CalculatorData();

  CalculatorData get calculatorData => _calculatorData;

  void updateCalculator(CalculatorData newCalculatorData) {
    _calculatorData.number1 = newCalculatorData.number1;
    _calculatorData.number2 = newCalculatorData.number2;
    _calculatorData.operation = newCalculatorData.operation;
    _calculatorData.result = newCalculatorData.result;
    _calculatorData.display = newCalculatorData.display;
    _calculatorData.state = newCalculatorData.state;

    notifyListeners();
  }
}
