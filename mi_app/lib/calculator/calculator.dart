import 'package:flutter/material.dart';
import 'package:mi_app/calculator/calculator_display.dart';
import 'package:mi_app/calculator/calculator_keyboard.dart';
import 'package:mi_app/calculator/calculator_provider.dart';
import 'package:mi_app/model/calculator_model.dart';
import 'package:provider/provider.dart';

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculator')),
      body: const SafeArea(
        child: Padding(padding: EdgeInsets.all(12), child: CalculatorWidget()),
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
  void _onButtonPressed(String value) {
    setState(() {
      final calculator = Calculator.fromData(
        context.read<CalculatorProvider>().calculatorData,
      );
      calculator.processInput(value);
      context.read<CalculatorProvider>().updateCalculator(calculator.toData());
    });
  }

  @override
  Widget build(BuildContext context) {
    final display = context.watch<CalculatorProvider>().calculatorData.display;

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
          Expanded(child: KeyboardWidget(onButtonPressed: _onButtonPressed)),
        ],
      ),
    );
  }
}
