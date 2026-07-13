import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

class RowColumnExample extends StatefulWidget {
  const RowColumnExample({super.key});

  @override
  State<RowColumnExample> createState() => _RowColumnExampleState();
}

class _RowColumnExampleState extends State<RowColumnExample> {
  MainAxisAlignment _rowAlignment = MainAxisAlignment.start;
  CrossAxisAlignment _columnAlignment = CrossAxisAlignment.start;

  final List<MainAxisAlignment> _rowAlignments = [
    MainAxisAlignment.start,
    MainAxisAlignment.center,
    MainAxisAlignment.end,
    MainAxisAlignment.spaceAround,
    MainAxisAlignment.spaceBetween,
    MainAxisAlignment.spaceEvenly,
  ];

  final List<CrossAxisAlignment> _columnAlignments = [
    CrossAxisAlignment.start,
    CrossAxisAlignment.center,
    CrossAxisAlignment.end,
    CrossAxisAlignment.stretch,
  ];

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Row & Column',
      description:
          'Row y Column organizan widgets horizontal y verticalmente. '
          'Juega con MainAxisAlignment, CrossAxisAlignment, Expanded y Flexible '
          'para ver cómo se distribuye el espacio.',
      code: '''Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Icon(Icons.star, color: Colors.amber),
    Expanded(
      child: Text('Expanded ocupa el espacio sobrante'),
    ),
    Flexible(
      child: Text('Flexible se adapta'),
    ),
  ],
)

Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    Text('Arriba'),
    Expanded(child: Center(child: Text('Centro'))),
    Text('Abajo'),
  ],
)''',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row demo
          Text('Row - MainAxisAlignment',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: _rowAlignments.map((a) {
              return ChoiceChip(
                label: Text(a.name.substring(0, 1).toUpperCase() + a.name.substring(1)),
                selected: _rowAlignment == a,
                onSelected: (_) => setState(() => _rowAlignment = a),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Container(
            color: Colors.blue.shade50,
            height: 80,
            child: Row(
              mainAxisAlignment: _rowAlignment,
              children: [
                Container(width: 40, height: 40, color: Colors.red),
                Container(width: 40, height: 40, color: Colors.green),
                Container(width: 40, height: 40, color: Colors.blue),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          // Column demo
          Text('Column - CrossAxisAlignment',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: _columnAlignments.map((a) {
              final name = a.name.substring(0, 1).toUpperCase() + a.name.substring(1);
              return ChoiceChip(
                label: Text(name),
                selected: _columnAlignment == a,
                onSelected: (_) => setState(() => _columnAlignment = a),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Container(
            color: Colors.orange.shade50,
            height: 140,
            child: Column(
              crossAxisAlignment: _columnAlignment,
              children: [
                Container(width: 80, height: 24, color: Colors.red),
                Container(width: 120, height: 24, color: Colors.green),
                Container(width: 60, height: 24, color: Colors.blue),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          // Expanded / Flexible demo
          Text('Expanded & Flexible',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Container(
            color: Colors.purple.shade50,
            height: 80,
            child: Row(
              children: [
                Container(width: 40, color: Colors.red, child: const Center(child: Text('Fijo', style: TextStyle(color: Colors.white, fontSize: 10)))),
                Expanded(
                  child: Container(
                    color: Colors.green,
                    child: const Center(
                      child: Text('Expanded', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    color: Colors.blue,
                    child: const Center(
                      child: Text('Flexible', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
