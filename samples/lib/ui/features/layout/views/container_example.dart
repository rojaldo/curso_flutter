import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

class ContainerExample extends StatefulWidget {
  const ContainerExample({super.key});

  @override
  State<ContainerExample> createState() => _ContainerExampleState();
}

class _ContainerExampleState extends State<ContainerExample> {
  bool _showColor = true;
  bool _showBorder = true;
  bool _showRadius = true;
  bool _showGradient = false;
  bool _showShadow = true;
  bool _showPadding = true;
  bool _showMargin = true;

  double _borderWidth = 2;
  double _radius = 16;
  double _padding = 16;
  double _margin = 8;

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Container & BoxDecoration',
      description:
          'Container es el widget más versátil para dibujar cajas. '
          'Explora cómo cada propiedad afecta su apariencia: color, borde, '
          'esquinas redondeadas, degradado, sombra, padding y margin.',
      code: '''Container(
  margin: const EdgeInsets.all(8),
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.blue,
    border: Border.all(color: Colors.indigo, width: 2),
    borderRadius: BorderRadius.circular(16),
    gradient: const LinearGradient(
      colors: [Colors.blue, Colors.purple],
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 8,
        offset: Offset(4, 4),
      ),
    ],
  ),
  child: const Text('Hola Container'),
)''',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Demo container
          Container(
            margin: _showMargin ? EdgeInsets.all(_margin) : EdgeInsets.zero,
            padding: _showPadding ? EdgeInsets.all(_padding) : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: _showGradient ? null : (_showColor ? Colors.blue : null),
              border: _showBorder
                  ? Border.all(
                      color: Colors.indigo,
                      width: _borderWidth,
                    )
                  : null,
              borderRadius: _showRadius
                  ? BorderRadius.circular(_radius)
                  : BorderRadius.zero,
              gradient: _showGradient
                  ? const LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              boxShadow: _showShadow
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(4, 4),
                      ),
                    ]
                  : null,
            ),
            child: const Text(
              'Hola Container',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          // Controls
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildToggle('Color', _showColor, (v) => setState(() => _showColor = v)),
              _buildToggle('Borde', _showBorder, (v) => setState(() => _showBorder = v)),
              _buildToggle('Radio', _showRadius, (v) => setState(() => _showRadius = v)),
              _buildToggle('Degradado', _showGradient, (v) => setState(() => _showGradient = v)),
              _buildToggle('Sombra', _showShadow, (v) => setState(() => _showShadow = v)),
              _buildToggle('Padding', _showPadding, (v) => setState(() => _showPadding = v)),
              _buildToggle('Margin', _showMargin, (v) => setState(() => _showMargin = v)),
            ],
          ),
          if (_showBorder) ...[
            const SizedBox(height: 8),
            _buildSlider('Ancho borde', _borderWidth, 0, 8,
                (v) => setState(() => _borderWidth = v)),
          ],
          if (_showRadius) ...[
            _buildSlider('Radio esquinas', _radius, 0, 40,
                (v) => setState(() => _radius = v)),
          ],
          if (_showPadding) ...[
            _buildSlider('Padding', _padding, 0, 40,
                (v) => setState(() => _padding = v)),
          ],
          if (_showMargin) ...[
            _buildSlider('Margin', _margin, 0, 40,
                (v) => setState(() => _margin = v)),
          ],
        ],
      ),
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: onChanged,
    );
  }

  Widget _buildSlider(String label, double value, double min, double max,
      ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(width: 110, child: Text(label)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt() * 2,
            label: value.toStringAsFixed(1),
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 40, child: Text(value.toStringAsFixed(1))),
      ],
    );
  }
}
