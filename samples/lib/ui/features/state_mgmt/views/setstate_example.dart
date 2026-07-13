import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico del patrón clásico setState.
///
/// Muestra un contador, una lista editable y un toggle de color,
/// además de un contador de reconstrucciones para evidenciar
/// que setState redibuja todo el árbol.
class SetStateExample extends StatefulWidget {
  const SetStateExample({super.key});

  @override
  State<SetStateExample> createState() => _SetStateExampleState();
}

class _SetStateExampleState extends State<SetStateExample> {
  int _counter = 0;
  final List<String> _items = ['Elemento 1', 'Elemento 2'];
  bool _isActive = false;
  int _rebuildCount = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  void _decrement() {
    setState(() {
      _counter--;
    });
  }

  void _addItem() {
    setState(() {
      _items.add('Elemento ${_items.length + 1}');
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _toggleColor() {
    setState(() {
      _isActive = !_isActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    _rebuildCount++;

    return ExampleScreen(
      title: 'setState',
      description:
          'setState es el mecanismo más básico de Flutter para gestionar '
          'estado local. Cada llamada reconstruye todo el widget. '
          'Observa cómo el contador de reconstrucciones aumenta con cualquier cambio.',
      code: _codeString,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Contador de reconstrucciones
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              'Reconstrucciones de build(): $_rebuildCount',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Demo 1: Contador
          _SectionTitle('1. Contador'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                onPressed: _decrement,
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: 16),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(width: 16),
              IconButton.filledTonal(
                onPressed: _increment,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const Divider(height: 32),

          // Demo 2: Lista editable
          _SectionTitle('2. Lista editable'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < _items.length; i++)
                Chip(
                  label: Text(_items[i]),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _removeItem(i),
                ),
              ActionChip(
                avatar: const Icon(Icons.add),
                label: const Text('Agregar'),
                onPressed: _addItem,
              ),
            ],
          ),
          const Divider(height: 32),

          // Demo 3: Toggle de color
          _SectionTitle('3. Cambio de color'),
          Center(
            child: FilledButton.icon(
              onPressed: _toggleColor,
              icon: Icon(_isActive ? Icons.toggle_on : Icons.toggle_off),
              style: FilledButton.styleFrom(
                backgroundColor: _isActive ? Colors.green : Colors.grey,
              ),
              label: Text(_isActive ? 'Activo' : 'Inactivo'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

const String _codeString = '''
class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _count = 0;

  void _increment() {
    setState(() {
      _count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Valor: \$_count'),
        ElevatedButton(
          onPressed: _increment,
          child: const Text('Incrementar'),
        ),
      ],
    );
  }
}
'''
;
