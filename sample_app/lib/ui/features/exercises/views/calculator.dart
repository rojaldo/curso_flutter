// this is a flutter page that demonstrates a simple calculator with basic operations: addition, subtraction, multiplication, and division. It uses a stateful widget to manage the input and output of the calculator. 
import 'package:flutter/material.dart';

class CalculatorExample extends StatefulWidget {
  const CalculatorExample({super.key});

  @override
  State<CalculatorExample> createState() => _CalculatorExampleState();
}

class _CalculatorExampleState extends State<CalculatorExample> {
  // Add your state variables and methods here

  // create state for variable displayText that will hold the text to be displayed in the calculator display
  String displayText = '';



  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora')),
      body: SafeArea(
        child: Column(
          children: [
            // Display: se expande para empujar el teclado hacia abajo
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                alignment: Alignment.bottomRight,
                child: Text(
                  displayText.isEmpty ? '0' : displayText,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ),
            // Teclado 4×4 que llena el ancho
            ..._buildRows(colorScheme),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRows(ColorScheme colorScheme) {
    const rows = [
      ['7', '8', '9', '/'],
      ['4', '5', '6', '*'],
      ['1', '2', '3', '-'],
      ['AC', '0', '=', '+'],
    ];
    const operations = {'/', '*', '-', '+', '=', 'AC'};

    return rows.map((row) {
      return Expanded(
        child: Row(
          children: row.map((label) {
            final isOp = operations.contains(label);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Material(
                  color: isOp
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      setState(() {
                        if (label == 'AC') {
                          displayText = '';
                        } else {
                          displayText += label;
                        }
                      });
                    },
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: isOp ? FontWeight.bold : FontWeight.w400,
                          color: isOp
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    }).toList();
  }
}
