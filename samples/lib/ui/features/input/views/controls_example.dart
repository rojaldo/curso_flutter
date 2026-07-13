import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

class ControlsExample extends StatefulWidget {
  const ControlsExample({super.key});

  @override
  State<ControlsExample> createState() => _ControlsExampleState();
}

class _ControlsExampleState extends State<ControlsExample> {
  bool _isChecked = false;
  bool _isSwitched = false;
  String _selectedColor = 'Rojo';
  double _sliderValue = 50;

  final List<String> _colors = ['Rojo', 'Verde', 'Azul'];
  final Map<String, Color> _colorMap = {
    'Rojo': Colors.red,
    'Verde': Colors.green,
    'Azul': Colors.blue,
  };

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Controles',
      description:
          'Ejemplo interactivo de Checkbox, Switch, Radio y Slider. '
          'Interactúa con cada control y observa cómo cambia el estado en tiempo real.',
      code: '''Checkbox(
  value: _isChecked,
  onChanged: (value) {
    setState(() => _isChecked = value!);
  },
)

Switch(
  value: _isSwitched,
  onChanged: (value) {
    setState(() => _isSwitched = value);
  },
)

Radio<String>(
  value: 'Rojo',
  groupValue: _selectedColor,
  onChanged: (value) {
    setState(() => _selectedColor = value!);
  },
)

Slider(
  value: _sliderValue,
  min: 0,
  max: 100,
  onChanged: (value) {
    setState(() => _sliderValue = value);
  },
)''',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Checkbox
          Card(
            child: ListTile(
              leading: Checkbox(
                value: _isChecked,
                onChanged: (value) {
                  setState(() {
                    _isChecked = value!;
                  });
                },
              ),
              title: const Text('Checkbox'),
              subtitle: Text(_isChecked ? 'Marcado' : 'Desmarcado'),
            ),
          ),
          const SizedBox(height: 8),

          // Switch
          Card(
            child: ListTile(
              leading: Switch(
                value: _isSwitched,
                onChanged: (value) {
                  setState(() {
                    _isSwitched = value;
                  });
                },
              ),
              title: const Text('Switch'),
              subtitle: Text(_isSwitched ? 'Activado' : 'Desactivado'),
            ),
          ),
          const SizedBox(height: 8),

          // Radio buttons
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Radio buttons',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Seleccionado: $_selectedColor'),
                  const SizedBox(height: 8),
                  Row(
                    children: _colors.map((color) {
                      return Expanded(
                        child: Row(
                          children: [
                            Radio<String>(
                              value: color,
                              groupValue: _selectedColor,
                              onChanged: (value) {
                                setState(() {
                                  _selectedColor = value!;
                                });
                              },
                            ),
                            Text(color),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Slider
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Slider',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Valor: ${_sliderValue.toStringAsFixed(1)}'),
                  Slider(
                    value: _sliderValue,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: _sliderValue.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _sliderValue = value;
                      });
                    },
                  ),
                  Container(
                    height: 24,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _colorMap[_selectedColor]!.withOpacity(
                        _sliderValue / 100,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Resumen del estado',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text('Checkbox: ${_isChecked ? "Sí" : "No"}'),
          Text('Switch: ${_isSwitched ? "Encendido" : "Apagado"}'),
          Text('Color seleccionado: $_selectedColor'),
          Text('Opacidad del slider: ${(_sliderValue / 100).toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}
