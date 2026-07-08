import 'package:flutter/material.dart';
import 'package:mi_app/calculator/calculator_display.dart';
import 'package:mi_app/calculator/calculator_keyboard.dart';
import 'package:mi_app/model/calculator_model.dart';

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CalculatorWidget(),
        ),
      ),
    );
  }
}

//stateful widget calculator
class CalculatorWidget extends StatefulWidget {
  
  const CalculatorWidget({super.key});

  @override
  State<CalculatorWidget> createState() => _CalculatorWidgetState();
}

class _CalculatorWidgetState extends State<CalculatorWidget> {

  String display = '';
  Calculator calculator = Calculator();

  void _onButtonPressed(String value) {
    setState(() {
      display = calculator.processInput(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          DisplayWidget(display: display),
          const SizedBox(height: 16),
          Expanded(
            child: KeyboardWidget(onButtonPressed: _onButtonPressed),
          ),
        ],
      ),
    );
  }
}




