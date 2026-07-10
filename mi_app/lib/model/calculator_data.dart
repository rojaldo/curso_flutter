

import 'package:mi_app/model/calculator_model.dart';

class CalculatorData {
    double number1;
    double number2;
    String operation;
    double result;
    String display;
    CalculatorState state;


    CalculatorData({
        this.number1 = 0,
        this.number2 = 0,
        this.operation = '',
        this.result = 0,
        this.display = '',
        this.state = CalculatorState.init,
    });
}