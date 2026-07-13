import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

class ReorderableExample extends StatefulWidget {
  const ReorderableExample({super.key});

  @override
  State<ReorderableExample> createState() => _ReorderableExampleState();
}

class _ReorderableExampleState extends State<ReorderableExample> {
  final List<String> _originalItems = [
    'Rojo',
    'Verde',
    'Azul',
    'Amarillo',
    'Naranja',
    'Morado',
    'Cyan',
    'Rosa',
  ];

  late List<String> _items;

  final List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow.shade700,
    Colors.orange,
    Colors.purple,
    Colors.cyan,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _items = List.from(_originalItems);
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'ReorderableListView',
      description:
          'ReorderableListView permite reordenar elementos arrastrándolos. '
          'Mantén pulsado un elemento y arrástralo para cambiar su posición. '
          'El callback onReorder actualiza el estado con el nuevo orden.',
      code: '''ReorderableListView(
  onReorder: (oldIndex, newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);
    });
  },
  children: [
    for (final item in items)
      ListTile(
        key: ValueKey(item),
        title: Text(item),
      ),
  ],
)''',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Mantén pulsado y arrastra para reordenar',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 360,
            child: ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _items.removeAt(oldIndex);
                  _items.insert(newIndex, item);
                });
              },
              children: [
                for (int i = 0; i < _items.length; i++)
                  Card(
                    key: ValueKey(_items[i]),
                    color: _colors[i % _colors.length].withOpacity(0.15),
                    child: ListTile(
                      leading: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _colors[i % _colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(_items[i]),
                      trailing: const Icon(Icons.drag_handle),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Orden actual: ${_items.join(' > ')}',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => setState(() => _items = List.from(_originalItems)),
            icon: const Icon(Icons.refresh),
            label: const Text('Restablecer orden'),
          ),
        ],
      ),
    );
  }
}
