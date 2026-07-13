import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sample_app/ui/features/exercises/view_models/calculator_cubit.dart';

class CalculatorExample extends StatelessWidget {
  const CalculatorExample({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                alignment: Alignment.bottomRight,
                child: BlocBuilder<CalculatorCubit, CalculatorState>(
                  builder: (context, state) {
                    return Text(
                      state.displayText.isEmpty ? '0' : state.displayText,
                      key: const Key('calculator_display'),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.end,
                    );
                  },
                ),
              ),
            ),
            ..._buildRows(colorScheme, context.read<CalculatorCubit>()),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRows(ColorScheme colorScheme, CalculatorCubit cubit) {
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
                    onTap: () => cubit.processInput(label),
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