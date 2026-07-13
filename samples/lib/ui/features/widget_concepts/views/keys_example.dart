import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Demuestra la importancia de las Keys al reordenar widgets con estado.
///
/// Muestra dos listas lado a lado: una SIN keys (pierde estado al reordenar)
/// y otra CON ValueKeys (mantiene el estado correctamente).
class KeysExample extends StatefulWidget {
  const KeysExample({super.key});

  @override
  State<KeysExample> createState() => _KeysExampleState();
}

class _KeysExampleState extends State<KeysExample> {
  List<_ColoredItem> _itemsWithoutKeys = [
    _ColoredItem(id: 'a', color: Colors.red, label: 'Rojo'),
    _ColoredItem(id: 'b', color: Colors.blue, label: 'Azul'),
    _ColoredItem(id: 'c', color: Colors.green, label: 'Verde'),
  ];

  List<_ColoredItem> _itemsWithKeys = [
    _ColoredItem(id: 'a', color: Colors.red, label: 'Rojo'),
    _ColoredItem(id: 'b', color: Colors.blue, label: 'Azul'),
    _ColoredItem(id: 'c', color: Colors.green, label: 'Verde'),
  ];

  void _shuffleLists() {
    setState(() {
      _itemsWithoutKeys = List.from(_itemsWithoutKeys.reversed);
      _itemsWithKeys = List.from(_itemsWithKeys.reversed);
    });
  }

  @override
  Widget build(BuildContext context) {
    const code = '''
// SIN keys: Flutter reutiliza por posición.
// Al reordenar, el estado se queda en la posición equivocada.
Column(
  children: items.map((item) =>
    _StatefulBox(color: item.color, label: item.label),
  ).toList(),
)

// CON ValueKey: Flutter identifica por key.
// Al reordenar, el estado sigue al widget correcto.
Column(
  children: items.map((item) =>
    _StatefulBox(
      key: ValueKey(item.id),  // ← CLAVE
      color: item.color,
      label: item.label,
    ),
  ).toList(),
)
''';

    return ExampleScreen(
      title: 'Keys — Identidad de widgets',
      description: 'Sin keys, Flutter identifica widgets por su posición en el árbol. '
          'Al reordenar, el estado se queda en la posición equivocada. Con ValueKey, '
          'Flutter identifica widgets por su clave, así el estado sigue al widget '
          'correcto. Pulsa "+1" en cada caja y luego "Invertir orden" para ver la diferencia.',
      code: code,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: _shuffleLists,
            icon: const Icon(Icons.swap_vert),
            label: const Text('Invertir orden'),
          ),
          const SizedBox(height: 16),
          // Sin Keys
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '❌ SIN Keys',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const Text(
                  'El contador se queda en la posición,\nno sigue al widget.',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),
                const SizedBox(height: 8),
                ..._itemsWithoutKeys.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    // SIN key: Flutter identifica por posición
                    child: _StatefulBox(color: item.color, label: item.label),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Con Keys
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✅ CON ValueKey',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const Text(
                  'El contador sigue al widget,\nporque la key identifica su identidad.',
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
                const SizedBox(height: 8),
                ..._itemsWithKeys.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    // CON key: Flutter identifica por la key
                    child: _StatefulBox(
                      key: ValueKey(item.id),
                      color: item.color,
                      label: item.label,
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

class _ColoredItem {
  _ColoredItem({required this.id, required this.color, required this.label});
  final String id;
  final Color color;
  final String label;
}

class _StatefulBox extends StatefulWidget {
  const _StatefulBox({super.key, required this.color, required this.label});

  final Color color;
  final String label;

  @override
  State<_StatefulBox> createState() => _StatefulBoxState();
}

class _StatefulBoxState extends State<_StatefulBox> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: widget.color),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(widget.label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Text('$_counter', style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 4),
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => setState(() => _counter++),
              icon: const Icon(Icons.add, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}