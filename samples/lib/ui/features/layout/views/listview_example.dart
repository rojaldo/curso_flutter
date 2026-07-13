import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

class ListviewExample extends StatefulWidget {
  const ListviewExample({super.key});

  @override
  State<ListviewExample> createState() => _ListviewExampleState();
}

class _ListviewExampleState extends State<ListviewExample> {
  int _selectedTab = 0;

  final List<String> _fruits = [
    'Manzana',
    'Banana',
    'Cereza',
    'Durazno',
    'Frutilla',
    'Kiwi',
    'Limón',
    'Mango',
    'Naranja',
    'Pera',
    'Sandía',
    'Uva',
  ];

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'ListView',
      description:
          'ListView construye listas scrollables. ListView.builder solo crea '
          'los elementos visibles (ideal para listas largas). ListView.separated '
          'añade divisores automáticamente.',
      code: '''ListView.builder(
  itemCount: 100,
  itemBuilder: (context, index) {
    return ListTile(
      leading: CircleAvatar(child: Text('\$index')),
      title: Text('Elemento \$index'),
      subtitle: Text('Subtítulo'),
    );
  },
)

ListView.separated(
  itemCount: items.length,
  separatorBuilder: (_, __) => const Divider(),
  itemBuilder: (context, index) => ListTile(...),
)''',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tabs
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Builder')),
              ButtonSegment(value: 1, label: Text('Separado')),
              ButtonSegment(value: 2, label: Text('Horizontal')),
            ],
            selected: {_selectedTab},
            onSelectionChanged: (set) =>
                setState(() => _selectedTab = set.first),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 280,
            child: _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    switch (_selectedTab) {
      case 0:
        return ListView.builder(
          itemCount: 100,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.primaries[index % Colors.primaries.length],
                child: Text('$index', style: const TextStyle(fontSize: 12, color: Colors.white)),
              ),
              title: Text('Elemento $index'),
              subtitle: const Text('Construido bajo demanda'),
              trailing: const Icon(Icons.chevron_right),
            );
          },
        );
      case 1:
        return ListView.separated(
          itemCount: _fruits.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(
                Icons.eco,
                color: Colors.green.shade700,
              ),
              title: Text(_fruits[index]),
              trailing: Text('#${index + 1}'),
            );
          },
        );
      case 2:
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 20,
          itemBuilder: (context, index) {
            return Container(
              width: 100,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: Colors.primaries[index % Colors.primaries.length],
              child: Center(
                child: Text(
                  'Card $index',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
