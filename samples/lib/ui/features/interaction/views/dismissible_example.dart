import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

class DismissibleExample extends StatefulWidget {
  const DismissibleExample({super.key});

  @override
  State<DismissibleExample> createState() => _DismissibleExampleState();
}

class _DismissibleExampleState extends State<DismissibleExample> {
  final List<String> _items = [
    'Manzana',
    'Banana',
    'Cereza',
    'Durazno',
    'Frutilla',
    'Kiwi',
    'Mango',
    'Naranja',
    'Pera',
    'Uva',
  ];

  String? _lastRemoved;
  int? _lastRemovedIndex;

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Dismissible',
      description:
          'Dismissible permite deslizar un elemento para eliminarlo. '
          'Puedes personalizar el fondo que aparece al deslizar y confirmar '
          'la acción con un SnackBar de deshacer.',
      code: '''Dismissible(
  key: Key(item),
  direction: DismissDirection.endToStart,
  background: Container(
    color: Colors.red,
    alignment: Alignment.centerRight,
    child: Icon(Icons.delete, color: Colors.white),
  ),
  confirmDismiss: (direction) async {
    return await showDialog(...);
  },
  onDismissed: (direction) {
    setState(() => items.removeAt(index));
  },
  child: ListTile(title: Text(item)),
)''',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Desliza un elemento hacia la izquierda o derecha para eliminarlo.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 380,
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Dismissible(
                  key: ValueKey(item + index.toString()),
                  direction: DismissDirection.horizontal,
                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    color: Colors.orange,
                    child: const Row(
                      children: [
                        Icon(Icons.archive, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Archivar',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  secondaryBackground: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Eliminar',
                            style: TextStyle(color: Colors.white)),
                        SizedBox(width: 8),
                        Icon(Icons.delete, color: Colors.white),
                      ],
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Eliminar'),
                          content: Text('¿Eliminar "$item"?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(true),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      );
                      return confirm == true;
                    }
                    return true;
                  },
                  onDismissed: (direction) {
                    setState(() {
                      _lastRemoved = _items.removeAt(index);
                      _lastRemovedIndex = index;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          direction == DismissDirection.endToStart
                              ? '$_lastRemoved eliminado'
                              : '$_lastRemoved archivado',
                        ),
                        action: SnackBarAction(
                          label: 'Deshacer',
                          onPressed: () {
                            setState(() {
                              if (_lastRemovedIndex != null &&
                                  _lastRemoved != null) {
                                _items.insert(
                                    _lastRemovedIndex!, _lastRemoved!);
                                _lastRemoved = null;
                                _lastRemovedIndex = null;
                              }
                            });
                          },
                        ),
                      ),
                    );
                  },
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.primaries[
                            index % Colors.primaries.length],
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: Text(item),
                      trailing: const Icon(Icons.drag_handle),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Todos los elementos eliminados',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          if (_items.isEmpty)
            ElevatedButton.icon(
              onPressed: () => setState(() {
                _items.addAll([
                  'Manzana', 'Banana', 'Cereza', 'Durazno', 'Frutilla',
                  'Kiwi', 'Mango', 'Naranja', 'Pera', 'Uva',
                ]);
              }),
              icon: const Icon(Icons.refresh),
              label: const Text('Restablecer lista'),
            ),
        ],
      ),
    );
  }
}
