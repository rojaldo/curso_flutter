import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

class ChipsExample extends StatefulWidget {
  const ChipsExample({super.key});

  @override
  State<ChipsExample> createState() => _ChipsExampleState();
}

class _ChipsExampleState extends State<ChipsExample> {
  final List<String> _tags = ['Flutter', 'Dart', 'Mobile'];
  final Set<String> _selectedFilters = {};
  String _selectedChoice = 'Pequeño';
  int _inputChipCounter = 1;

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Chips',
      description:
          'Los Chips son elementos compactos que representan entradas, '
          'atributos o acciones. Existen varios tipos: Chip (información), '
          'InputChip (entrada con eliminación), FilterChip (filtro), '
          'ChoiceChip (selección única) y ActionChip (acción).',
      code: '''Chip(
  avatar: Icon(Icons.label),
  label: Text('Etiqueta'),
)

InputChip(
  label: Text('Entrada'),
  onDeleted: () {},
)

FilterChip(
  label: Text('Filtro'),
  selected: isSelected,
  onSelected: (value) {},
)

ChoiceChip(
  label: Text('Opción'),
  selected: isSelected,
  onSelected: (value) {},
)''',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Chip
          const Text(
            'Chip (información)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _tags
                .map((tag) => Chip(
                      avatar: const Icon(Icons.label, size: 18),
                      label: Text(tag),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),

          // InputChip
          const Text(
            'InputChip (con eliminación)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(_inputChipCounter, (index) {
              return InputChip(
                avatar: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text('${index + 1}',
                      style: const TextStyle(fontSize: 12)),
                ),
                label: Text('Elemento ${index + 1}'),
                onDeleted: () {
                  setState(() {
                    if (_inputChipCounter > 1) _inputChipCounter--;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => setState(() => _inputChipCounter++),
            icon: const Icon(Icons.add),
            label: const Text('Añadir InputChip'),
          ),
          const SizedBox(height: 20),

          // FilterChip
          const Text(
            'FilterChip (filtros toggleables)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Rojo', 'Verde', 'Azul', 'Amarillo'].map((color) {
              final isSelected = _selectedFilters.contains(color);
              return FilterChip(
                label: Text(color),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedFilters.add(color);
                    } else {
                      _selectedFilters.remove(color);
                    }
                  });
                },
              );
            }).toList(),
          ),
          if (_selectedFilters.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Filtrados: ${_selectedFilters.join(', ')}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 20),

          // ChoiceChip
          const Text(
            'ChoiceChip (selección única)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Pequeño', 'Mediano', 'Grande'].map((size) {
              return ChoiceChip(
                label: Text(size),
                selected: _selectedChoice == size,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedChoice = size);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text('Seleccionado: $_selectedChoice',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),

          // ActionChip
          const Text(
            'ActionChip (acción al tocar)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                avatar: const Icon(Icons.email, size: 18),
                label: const Text('Enviar correo'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Abriendo correo...')),
                  );
                },
              ),
              ActionChip(
                avatar: const Icon(Icons.share, size: 18),
                label: const Text('Compartir'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Compartiendo...')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
