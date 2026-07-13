import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

class GridviewExample extends StatefulWidget {
  const GridviewExample({super.key});

  @override
  State<GridviewExample> createState() => _GridviewExampleState();
}

class _GridviewExampleState extends State<GridviewExample> {
  bool _useExtent = false;
  int _crossAxisCount = 3;

  final List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.cyan,
    Colors.indigo,
    Colors.lime,
    Colors.deepOrange,
  ];

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'GridView',
      description:
          'GridView organiza elementos en una cuadrícula scrollable. '
          'SliverGridDelegateWithFixedCrossAxisCount fija la cantidad de columnas. '
          'GridView.extent limita el ancho máximo de cada celda.',
      code: '''GridView.count(
  crossAxisCount: 3,
  children: List.generate(20, (index) {
    return Container(
      color: Colors.primaries[index % Colors.primaries.length],
      child: Center(child: Text('\$index')),
    );
  }),
)

GridView.extent(
  maxCrossAxisExtent: 100,
  children: [...],
)''',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Controls
          Row(
            children: [
              Expanded(
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('count')),
                    ButtonSegment(value: true, label: Text('extent')),
                  ],
                  selected: {_useExtent},
                  onSelectionChanged: (set) =>
                      setState(() => _useExtent = set.first),
                ),
              ),
            ],
          ),
          if (!_useExtent) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Columnas:'),
                Expanded(
                  child: Slider(
                    value: _crossAxisCount.toDouble(),
                    min: 2,
                    max: 5,
                    divisions: 3,
                    label: '$_crossAxisCount',
                    onChanged: (v) =>
                        setState(() => _crossAxisCount = v.toInt()),
                  ),
                ),
                SizedBox(width: 24, child: Text('$_crossAxisCount')),
              ],
            ),
          ],
          const SizedBox(height: 8),
          SizedBox(
            height: 320,
            child: _buildGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    if (_useExtent) {
      return GridView.extent(
        maxCrossAxisExtent: 100,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: List.generate(24, (index) {
          return Container(
            color: _colors[index % _colors.length],
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      );
    }

    return GridView.count(
      crossAxisCount: _crossAxisCount,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: List.generate(24, (index) {
        return Container(
          color: _colors[index % _colors.length],
          child: Center(
            child: Text(
              '$index',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }
}
